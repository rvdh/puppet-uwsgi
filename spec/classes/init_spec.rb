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
    end
  end
end
