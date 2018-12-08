# # encoding: utf-8

# Inspec test for recipe bluegreen::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe docker.containers.where { names == 'registry:latest' } do
  it { should_not be_running }  
end
describe docker.containers do
  its('ports') { should_not include '0.0.0.0:5000->5000/tcp' }
end