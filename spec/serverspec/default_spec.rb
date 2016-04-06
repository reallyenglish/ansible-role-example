require 'spec_helper'

describe package('zsh') do
  it { should be_installed }
end 

describe file('/tmp/foo') do
  it { should exist }
  it { should be_file }
  its(:content) { should match /Hello world/ }
end
