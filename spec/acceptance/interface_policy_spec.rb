require 'spec_helper_acceptance'

describe 'interface_policy' do

  context 'providing a valid set of interfaces' do

    it 'should remove an interface not in the set' do
      pp = <<-EOS
        cumulus_interface { 'lo':
          addr_method => 'loopback',
        }

        cumulus_interface { 'eth0':
          addr_method => 'dhcp',
        }

        cumulus_interface { 'swp2':
          ipv4 => ['10.30.1.1'],
          notify => Service['networking'],
        }

        cumulus_interface { 'swp3':
          ipv4 => ['10.30.1.2'],
          notify => Service['networking'],
        }

        file { '/etc/network/interfaces':
          content => "source /etc/network/interfaces.d/*\n",
        }

        service { 'networking':
          ensure     => running,
          hasrestart => true,
          restart    => '/sbin/ifreload -a',
          enable     => true,
          hasstatus  => false,
          require    => File['/etc/network/interfaces'],
        }

        cumulus_interface_policy{ 'policy':
          allowed => ['lo', 'eth0', 'swp2'],
          notify => Service['networking'],
          require => [Cumulus_interface['lo'], Cumulus_interface['eth0'], Cumulus_interface['swp2'], Cumulus_interface['swp3']],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    ['lo', 'eth0', 'swp2'].each do |intf|
      describe interface(intf) do
        it { should exist }
        it { should be_up } if intf != 'lo'
      end

      describe file("/etc/network/interfaces.d/#{intf}") do
        it { should be_file }
      end
    end

    describe interface('swp3') do
      it { should_not be_up }
    end

    describe file('/etc/network/interfaces/swp3') do
      it { should_not exist }
    end

    #it 'should retain interfaces that are in the set' do
    #end

  end

end
