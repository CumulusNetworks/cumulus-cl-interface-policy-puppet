Puppet::Type.type(:cumulus_interface_policy).provide :cumulus do
  confine operatingsystem: [:cumuluslinux]

  def current_iface_list
    Dir.entries(resource[:location]).reject { |f| ['.', '..'].include? f }
  end

  def add_port_range(port_range)
    port_range_arr = []
    # split port range
    m0 = port_range.match(/(\w+[a-z.])(\d+)?-?(\d+)?(\w+)?/)
    return [port_range] if m0[3].nil?
    (m0[2]..m0[3]).to_a.each do |portint|
      port_range_arr.push(m0[1] + portint + m0[4].to_s)
    end
    port_range_arr
  end

  def build_allowed_iface_list
    allowed_list_arr = []
    allowed_list = resource[:allowed]
    # put allowed_list(string) into an array if string
    allowed_list = allowed_list.class == String ? [allowed_list] : allowed_list
    allowed_list.each do |port_range|
      allowed_list_arr += add_port_range(port_range)
    end
    allowed_list_arr
  end

  # List changed only when current port list, i.e what is in
  # /etc/network/interface.d lists a port that is not in the allowed list
  # If the allowed list has a port that is not yet created, that's okay..pass
  def list_changed?
    @current_list = current_iface_list
    @allowed_list = build_allowed_iface_list
    (@current_list - @allowed_list).length > 0
  end

  # resource param :location can have '/'
  # or not at the end..will check to see what
  # user configured, and fix it according. Only one
  # slash should be after the location path.
  def file_prefix
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
    list_to_remove = @current_list - @allowed_list
    if list_to_remove.include?('lo')
      Puppet.warning(
        'LOOPBACK iface will be UNCONFIGURED(DOWN state). Are you Sure?')
    end
    Puppet.info 'Unconfiguring ' + list_to_remove.join(', ')  + ' interfaces'
    list_to_remove.each { |portfile| File.unlink(file_prefix + portfile) }
  end
end
