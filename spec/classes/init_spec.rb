require 'spec_helper'

describe 'uwsgi' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:hiera_config) { 'hiera.yaml' }

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('uwsgi') }
        it { is_expected.to contain_class('uwsgi::install') }
        it { is_expected.to contain_class('uwsgi::service') }
        it { is_expected.to contain_class('uwsgi::packages') }
        it { is_expected.to contain_class('uwsgi::config') }
      end

      context 'with app in parameters' do
        # simple app hash
        app_options = { 'uid' => '1000', 'gid' => '1001' }

        let(:params) do
          {
            app: { 'test1' => app_options }
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('uwsgi') }
        it { is_expected.to contain_uwsgi__app('test1') }

        case facts[:osfamily]
        when 'Debian'
          it {
            is_expected.to contain_file('/etc/uwsgi/apps-enabled/test1.ini')
              .with_ensure('present')
          }
        when 'RedHat'
          it {
            is_expected.to contain_file('/etc/uwsgi.d/test1.ini')
              .with_ensure('present')
          }
        end
      end
    end
  end
end
