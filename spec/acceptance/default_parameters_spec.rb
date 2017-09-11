require 'spec_helper_acceptance'

describe 'uwsgi', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'installs with defaults' do
    pp = <<-EOS
      $app = { 'testapp' => { 'uid' => '1000', 'gid' => '1000', 'application_options' => { 'http-socket' => ':9090' } } }
      class { '::uwsgi':
        app => $app,
      }
    EOS
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe process('uwsgi') do
    it { is_expected.to be_running }
  end

  describe port(9090) do
    it { is_expected.to be_listening }
  end

  describe service('uwsgi') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end
end
