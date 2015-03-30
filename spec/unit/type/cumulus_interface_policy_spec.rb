require 'spec_helper'

cl_iface_policy = Puppet::Type.type(:cumulus_interface_policy)

describe cl_iface_policy do
  let :params do
    [
      :name,
      :allowed,
      :location
    ]
  end

  let :properties do
    [:interface_list]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(cl_iface_policy.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(cl_iface_policy.parameters).to be_include(param)
    end
  end

  context 'interface_list property' do
    before do
      # call the ruby provider and assign it as the default provider
      # provider must be real. can't fake that.
      @provider = double 'provider'
      allow(@provider).to receive(:name).and_return(:cumulus)
      cl_iface_policy.stubs(:defaultprovider).returns @provider
      @ifacelist = cl_iface_policy.new(name: 'policy', allowed: 'swp1-3')
    end
    subject { allow(@ifacelist.provider).to receive(:list_changed?) }
    let(:iface_list_result) { @ifacelist.property(:interface_list).retrieve }

    context 'when provider config_changed? is false' do
      before do
        subject.and_return(false)
      end
      it { expect(iface_list_result).to eq(:insync) }
    end

    context 'when provider config_changed? is true' do
      before do
        subject.and_return(true)
      end
      it { expect(iface_list_result).to eq(:outofsync) }
    end

    context 'insync provider call' do
      let(:provider) { @ifacelist.provider }
      subject do
        @ifacelist.property(:interface_list).set_insync
      end
      it do
        expect(provider).to receive(:remove_interfaces).once
        subject
      end
    end
  end
end
