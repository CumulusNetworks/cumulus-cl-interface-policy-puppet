Puppet::Type.type(:cumulus_interface_policy).provide :ruby do

  confine operatingsystem: [:cumulus_linux]

  def get_current_iface_list
  end

  def get_allowed_iface_list
  end

  def list_changed?
    current_list = get_current_iface_list
    allowed_list = get_allowed_iface_list
    current_list != allowed_list
  end

  def remove_interfaces
  end
end
