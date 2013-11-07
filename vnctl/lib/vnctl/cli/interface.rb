# -*- coding: utf-8 -*-

module Vnctl::Cli
  class SecurityGroups < Base
    namespace :security_groups
    api_suffix "/api/interfaces"

    desc "add INTERFACE_UUID, SECURITY_GROUP_UUID(S)", "Adds one or more security groups to this interface."
    def add(interface_uuid, *secg_uuids)
      secg_uuids.each { |secg_uuid|
        query = { :security_group_uuid => secg_uuid }
        puts post("#{suffix}/#{interface_uuid}/security_groups", :query => query)
      }
    end
  end

  class Interface < Base
    namespace :interface
    api_suffix "/api/interfaces"

    add_modify_shared_options {
      option :network_uuid, :type => :string, :desc => "The uuid of the network this interface is in."
      option :mac_address, :type => :string, :desc => "The mac address for this interface."
      option :owner_datapath_uuid, :type => :string, :desc => "The uuid of the datapath that owns this interface."
      option :active_datapath_uuid, :type => :string, :desc => "The uuid of this interface's active datapath."
    }

    add_required_options [:mac_address]

    option_uuid
    option :ipv4_address, :type => :string, :desc => "The first ip lease for this interface."
    option :security_groups, :type => :array, :desc => "The security groups to put this interface in."
    add_modify_shared_options
    define_add

    add_modify_shared_options
    define_modify

    define_show
    define_del

    register(SecurityGroups, :security_groups, "security_groups OPTIONS",
      "subcommand to manage security groups for an interface")
  end
end
