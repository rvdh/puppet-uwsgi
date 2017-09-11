require 'spec_helper'

describe 'uwsgi::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:hiera_config) { 'hiera.yaml' }

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('uwsgi::config') }

        # config file
        it { is_expected.to contain_file('/etc/uwsgi.ini').with_ensure('present') }
        # logrotate file
        it { is_expected.to contain_file('/etc/logrotate.d/uwsgi').with_ensure('absent') }
      end
    end
  end
end
