Puppet::Type.type(:cumulus_interface_policy).provide :ruby do
  confine operatingsystem: [:cumulus_linux]

  def current_iface_list
    Dir.entries(resource[:location])
  end

  def add_port_range(m0)
    port_range_arr = []
    if m0[5].nil?
      allowed_list_arr.push(m0[0])
    else
      (m0[2]..m0[5]).to_a.each do |portint|
        port_range_arr.push(m0[1] + portint)
      end
    end
    port_range_arr
  end

  def allowed_iface_list
    allowed_list_arr = []
    allowed_list = resource[:allowed]
    # put allowed_list(string) into an array if string
    allowed_list = allowed_list.class == String ? [allowed_list] : allowed_list
    regex_str = /(\w+[a-z])(\d+)((\-)(\d+))?/
    allowed_list.each do |port_range|
      m0 = port_range.match(regex_str)
      allowed_list_arr += add_port_range(m0)
    end
    allowed_list_arr
  end

  # List changed only when current port list, i.e what is in
  # /etc/network/interface.d lists a port that is not in the allowed list
  # If the allowed list has a port that is not yet created, that's okay..pass
  def list_changed?
    current_list = current_iface_list
    allowed_list = allowed_iface_list
    (current_list - allowed_list).length > 0
  end

  # resource param :location can have '/'
  # or not at the end..will check to see what
  # user configured, and fix it according. Only one
  # slash should be after the location path.
  def cleaned_up_file_prefix
    if resource[:location].match(/\/$/)
      fileprefix = resource[:location]
    else
      fileprefix = resource[:location] + '/'
    end
    fileprefix
  end

  # remove interface files that are found /etc/network/interface.d directory
  # but are not in the allowed list
  def remove_interfaces
    current_port_set = current_iface_list
    allowed_list_set = allowed_iface_list
    list_to_remove = current_port_set - allowed_list_set
    if list_to_remove.include?('lo')
      Puppet.warning 'Loopback iface in iface removal list. ' \
                     'It will be UNCONFIGURED(DOWN state). Are You Sure?'
    end
    list_to_remove.each do |portfile|
      File.unlink(cleaned_up_file_prefix + portfile)
    end
  end
end
