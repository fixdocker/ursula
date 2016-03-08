require 'spec_helper'


files = { "api-paste.ini"=> 640, "nova.conf"=> 640, "policy.json"=> 644, "rootwrap.conf"=> 640 }
files.each do |file, mode|
  describe file("/etc/nova/#{file}") do
    it { should be_mode mode }
    it { should be_owned_by 'nova' }
    it { should be_grouped_into 'nova' }
  end
end

files = ['api-metadata.filters' , 'baremetal-compute-ipmi.filters' , 'baremetal-deploy-helper.filters' , 'compute.filters', 'network.filters']
files.each do |file|
  describe file("/etc/nova/rootwrap.d/#{file}") do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_writable.by('owner') }
  end
end

describe file('/etc/nova/rootwrap.d') do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
end

files = {'nova-api.log'=> 'nova', 'nova-cert.log'=> 'nova' , 'nova-conductor.log'=> 'nova', 'nova-consoleauth.log'=> 'nova',
  'nova-manage.log'=> 'root', 'nova-novncproxy.log'=> 'nova' , 'nova-scheduler.log'=> 'nova', 'nova-compute.log'=> 'nova'}
files.each do |file, owner|
  if File.exist?("/var/log/nova/#{file}")
    describe file("/var/log/nova/#{file}") do
      it { should be_mode 644 }
      it { should be_owned_by owner }
      it { should be_grouped_into 'adm' }
    end
  end
end

describe file('/etc/logrotate.d/nova') do
  file_contents = [ '# Generated by Ansible.',
         '# Local modifications will be overwritten.',
         '',
         '/var/log/nova/*.log',
         '{',
         '  daily',
         '  missingok',
         '  rotate 7',
         '  compress',
         '}']

  file_contents.each do |file_line|
    it { should contain file_line}
  end
end

describe file('/etc/nova/nova.conf') do
  it { should contain 'debug = {{ nova.logging.debug }}' }
end

has_file = file('{{ nova.state_path }}/instances').exists?
describe file( '{{ nova.state_path }}/instances' ), :if => has_file do
  it { should be a directory }
end
