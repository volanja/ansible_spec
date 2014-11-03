require 'spec_helper'

set :backend, :ssh

describe 'ssh' do
  context 'with root user' do 
    before do
        set :ssh_options, :user => 'root'
        @ssh = double(:ssh, Specinfra.configuration.ssh_options)
    end

    it 'should not prepend sudo' do
      expect(@ssh.user).to eq 'root'
    end
  end
end
