require 'spec_helper'
require 'pry'

provider_resource = Puppet::Type.type(:cumulus_interface_policy)
provider_class = provider_resource.provider(:ruby)

describe provider_class do
  before(:all) do
    @location = '/etc/network/interface.d/'
    # resource parameters require to be in arrays!!
    # wonder if I can get away from this requirement
    @resource = provider_resource.new(
      name: 'policy',
      allowed: 'swp1-10',
      location: @location
    )
    @provider = provider_class.new(@resource)
  end

  context 'operating system confine' do
    subject do
      provider_class.confine_collection.summary[:variable][:operatingsystem]
    end
    it { is_expected.to eq ['cumulus_linux'] }
  end

  context 'get current list of interfaces' do
    before do
      allow(Dir).to receive(:entries).with(@location).and_return(['swp1', 'swp2', 'swp3'])
    end
    subject { @provider.get_current_iface_list }
    it { is_expected.to eq ['swp1', 'swp2', 'swp3'] }
  end

  context 'get allowed list' do
    before do
      @resource2 = provider_resource.new(
        name: 'policy',
        allowed: ['swp1-2', 'swp12s10-12', 'bond0-1']
      )
      @provider2 = provider_class.new(@resource2)
    end
    subject { @provider2.get_allowed_iface_list }
    it { is_expected.to eq ['swp1', 'swp2', 'swp12s10', 'swp12s11', 'swp12s12', 'bond0', 'bond1'] }
  end
end
