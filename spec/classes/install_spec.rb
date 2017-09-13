require 'spec_helper'

describe 'uwsgi::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:hiera_config) { 'hiera.yaml' }

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('uwsgi::install') }
        it { is_expected.to contain_class('uwsgi::packages') }

        # directory creation...
        it { is_expected.to contain_file('/var/log/uwsgi').with_ensure('directory') }

        case facts[:osfamily]
        when 'Debian'
          context 'on Debian' do
            case facts[:operatingsystemmajrelease]
            when '7', '14.04'
              it do
                is_expected.to contain_package('uwsgi').with(
                  'provider' => 'pip',
                  'ensure' => 'present'
                )
              end
              it { is_expected.to contain_exec('uwsgi-mkdir-app-dir') }
              it { is_expected.to contain_file('/etc/uwsgi/apps-enabled').with_ensure('directory') }
            else
              it do
                is_expected.to contain_package('uwsgi-emperor').with(
                  'provider' => 'apt',
                  'ensure' => 'present'
                )
              end
              it { is_expected.to contain_file('/etc/uwsgi-emperor/vassals').with_ensure('directory') }
            end
            it { is_expected.to contain_file('/run/uwsgi').with_ensure('directory') }
          end
        when 'RedHat'
          context 'on RedHat' do
            it do
              is_expected.to contain_package('uwsgi').with(
                'provider' => 'yum',
                'ensure' => 'present'
              )
            end
            it { is_expected.to contain_package('uwsgi').with_provider('yum') }
            it { is_expected.to contain_file('/etc/uwsgi.d').with_ensure('directory') }
            it { is_expected.to contain_file('/var/run/uwsgi').with_ensure('directory') }
            case facts[:operatingsystemmajrelease]
            when '7'
              it { is_expected.to contain_file('/run/uwsgi').with_ensure('directory') }
            end
          end
        end
      end
    end
  end
end
