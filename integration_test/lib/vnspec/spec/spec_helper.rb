# -*- coding: utf-8 -*-

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'bundler/setup'
require 'pry'
require_relative '../../vnspec'

Dir[File.expand_path('./support/*.rb', File.dirname(__FILE__))].map {|f| require f }
Dir[File.expand_path('./shared_examples/*.rb', File.dirname(__FILE__))].map {|f| require f }

RSpec.configure do |c|
  c.include Vnspec::Logger
  c.include Vnspec::Config

  c.run_all_when_everything_filtered = true
  c.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #c.order = 'random'

  c.add_formatter(:documentation)
  #c.add_formatter(:json)

  c.before(:all) do
    # Disable 'vm7' by default.
    vm7.use_vm = false
  end

  c.before(:all, :vms_disable_dhcp => true) do
    vms.disable_dhcp
  end

  c.before(:all, :vms_enable_ifup => [:vm1]) do
    vms.disable_dhcp
    vm1.use_dhcp = true
  end

  c.before(:all, :vms_enable_ifup => [:vm1, :vm7]) do
    vms.disable_dhcp
    vm1.use_dhcp = true
    vm7.use_dhcp = true
  end

  c.before(:all, :vms_enable_vm => [:vm7]) do
    vms.disable_vm
    vm7.use_vm = true
  end

  c.before(:all, :vms_enable_vm => [:vm1, :vm7]) do
    vms.disable_vm
    vm1.use_vm = true
    vm7.use_vm = true
  end

  c.before(:all, :vms_enable_vm => :vm_1_7) do
    vms.disable_vm
    vm1.use_vm = true
    vm7.use_vm = true
  end

  c.before(:all, :vms_enable_vm => :vm_1_5_7]) do
    vms.disable_vm
    vm1.use_vm = true
    vm5.use_vm = true
    vm7.use_vm = true
  end

  c.before(:all) do
    vms.setup
  end

end
