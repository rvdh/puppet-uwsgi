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
        it { is_expected.to contain_package('uwsgi').with_ensure('present') }
        it { is_expected.to contain_package('uwsgi').with_provider('pip') }

        # directory creation...
        it { is_expected.to contain_file('/var/log/uwsgi').with_ensure('directory') }

        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_file('/etc/uwsgi/apps-enabled').with_ensure('directory') }
          it { is_expected.to contain_file('/run/uwsgi').with_ensure('directory') }
        when 'RedHat'
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
