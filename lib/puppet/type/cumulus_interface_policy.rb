Puppet::Type.newtype(:cumulus_interface_policy) do
  desc 'Enforce interface policy on Cumulus Linux'

  newproperty(:interface_list) do
    desc 'list of configurable interfaces'

    defaultto :insync

    def retrieve
      prov = @resource.provider
      if prov && prov.respond_to?(:list_changed?)
        result = @resource.provider.list_changed?
      else
        errormsg = 'unable to find a provider for cumulus_interface_policy ' \
        'that has a "list_changed?" function'
        fail Puppet::DevError, errormsg
      end
      # retrieve function sets the property value. if property value
      # doesn't match defaultto setting, then it will execute code
      # under the newvalue :insync section, in an attempt to reach
      # desired state
      result ? :outofsync : :insync
    end

    newvalue :outofsync
    newvalue :insync do
      prov = @resource.provider
      if prov && prov.respond_to?(:remove_interfaces)
        prov.remove_interfaces
      else
        errormsg = 'unable to find a provider for cumulus_interface_policy ' \
          ' that has a "update_config" function'
        fail Puppet::DevError, errormsg
      end
      nil
    end
  end

  newparam(:name) do
    desc 'used as the title for the module instantiation'
  end

  newparam(:allowed) do
    desc 'list of interfaces allowed'
  end

  newparam(:location) do
    desc 'force installation of license. Default: "/etc/network/interface.d" '
    defaultto '/etc/network/interface.d'
  end
end
