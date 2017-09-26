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
        case facts[:osfamily]
        when 'Debian'
          context 'on Debian' do
            case facts[:operatingsystemmajrelease]
            when '7', '14.04'
              it { is_expected.to contain_file('/etc/uwsgi.ini').with_ensure('present') }
            else
              it { is_expected.to contain_file('/etc/uwsgi-emperor/emperor.ini').with_ensure('present') }
            end
          end
        when 'RedHat'
          context 'on RedHat' do
            it { is_expected.to contain_file('/etc/uwsgi.ini').with_ensure('present') }
          end
        end
      end

      context 'with logrotate set true' do
        let(:params) { { 'log_rotate' => true } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('uwsgi::config') }
        # logrotate file
        it { is_expected.to contain_file('/etc/logrotate.d/uwsgi').with_ensure('present') }
      end

      # TODO: (09/12/2017)
      # the other case with log_rotate = true plus  package_ensure = absent
      # cannot be tested yet, as data in modules is not well supported in
      # rspec-puppet right now
    end
  end
end
