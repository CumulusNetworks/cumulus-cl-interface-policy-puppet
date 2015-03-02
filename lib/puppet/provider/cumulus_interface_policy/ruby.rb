require 'set'
Puppet::Type.type(:cumulus_interface_policy).provide :ruby do

  confine operatingsystem: [:cumulus_linux]

  def get_current_iface_list
    Dir.entries(resource[:location])
  end

  def get_allowed_iface_list
    allowed_list_arr = []
    allowed_list = resource[:allowed]
    # put allowed_list(string) into an array if string
    if allowed_list.class == String
      allowed_list = [allowed_list]
    end
    regex_str = /(\w+[a-z])(\d+)((\-)(\d+))?/
    allowed_list.each do |port_range|
      m0 = port_range.match(regex_str)
      if m0[5] == nil
        allowed_list_arr.push(m0[0])
      else
        (m0[2]..m0[5]).to_a.each do |portint|
          allowed_list_arr.push(m0[1] + portint)
        end
      end
    end
    allowed_list_arr
  end

  def list_changed?
    current_list = get_current_iface_list
    allowed_list = get_allowed_iface_list
    current_list != allowed_list
  end

  def remove_interfaces
  end
end
