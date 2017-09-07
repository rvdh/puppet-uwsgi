require 'spec_helper'

describe 'uwsgi::packages' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:hiera_config) { 'hiera.yaml' }

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('uwsgi::packages') }

        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_package('python-dev').with_ensure('present') }
          it { is_expected.to contain_package('python-pip').with_ensure('present') }
        when 'RedHat'
          it { is_expected.to contain_package('python-devel').with_ensure('present') }
          it { is_expected.to contain_package('python2-pip').with_ensure('present') }
        end
      end
    end
  end
end
