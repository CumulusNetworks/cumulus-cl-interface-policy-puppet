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

  context 'list_changed?' do
    before do
      @portlist = %w('swp1', 'swp2','bond0','bond1')
      expect(@provider).to receive(:allowed_iface_list).and_return(@portlist)
    end
    subject { @provider.list_changed? }
    context 'if allowed list differs' do
      before do
        expect(@provider).to receive(:current_iface_list).and_return(
          %w('swp1', 'swp3'))
      end
      it { is_expected.to be true }
    end
    context 'if allowed list does not differ' do
      before do
        expect(@provider).to receive(:current_iface_list).and_return(
          %w('swp1','swp2','bond0'))
      end
      it { is_expected.to be false }
    end
  end

  context 'get current list of interfaces' do
    before do
      expect(Dir).to receive(:entries).with(@location).and_return(
        %w('swp1', 'swp2', 'swp3'))
    end
    subject { @provider.current_iface_list }
    it { is_expected.to eq %w('swp1', 'swp2', 'swp3') }
  end

  context 'remove_interfaces' do
    before do
      expect(File).to receive(:unlink).exactly(3).times
      allow(@provider).to receive(:current_iface_list).and_return(
        %w('swp10', 'swp1', 'swp2', 'swp4'))
      allow(@provider).to receive(:allowed_iface_list).and_return(
        %w('swp10', 'swp11', 'swp12'))
    end
    it 'should all the correct interfaces' do
      @provider.remove_interfaces
    end
  end

  context 'get allowed list' do
    before do
      @resource2 = provider_resource.new(
        name: 'policy',
        allowed: ['swp1-2', 'swp12s10-12', 'bond0-1']
      )
      @provider2 = provider_class.new(@resource2)
    end
    subject { @provider2.allowed_iface_list }
    it do
      is_expected.to eq %w('swp1', 'swp2', 'swp12s10',
                           'swp12s11', 'swp12s12', 'bond0', 'bond1')
    end
  end
end
