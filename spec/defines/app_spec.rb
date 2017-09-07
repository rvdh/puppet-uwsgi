require 'spec_helper'

describe 'uwsgi::app' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:hiera_config) { 'hiera.yaml' }
      let(:title) { 'test' }
      let(:params) do
        {
          'uid' => 'test',
          'gid' => 'test'
        }
      end

      context 'with parameters uid and gid' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('uwsgi') }

        case facts[:osfamily]
        when 'Debian'
          it do
            is_expected.to contain_file('/etc/uwsgi/apps-enabled/test.ini')
              .with({
                      'ensure' => 'present',
                      'owner' => 'test',
                      'group' => 'test',
                      'mode' => '0644'
                    })
          end
        when 'RedHat'
          it do
            is_expected.to contain_file('/etc/uwsgi.d/test.ini')
              .with({
                      'ensure' => 'present',
                      'owner' => 'test',
                      'group' => 'test',
                      'mode' => '0644'
                    })
          end
        end
      end
    end
  end
end
