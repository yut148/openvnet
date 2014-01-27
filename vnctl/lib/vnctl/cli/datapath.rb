# -*- coding: utf-8 -*-

module Vnctl::Cli
  class Datapath < Base
    namespace :datapaths
    api_suffix "/api/datapaths"

    add_modify_shared_options {
      option_display_name
      option :ipv4_address, :type => :string, :desc => "Ipv4 address for the datapath."
      option :is_connected, :type => :boolean, :desc => "Flag that detemines if the datapath is connected or not."
      option :dpid, :type => :string, :desc => "Hexadecimal id for the datapath."
      option :dc_segment_uuid, :type => :string, :desc => "The datapath's dc segment uuid."
      option :node_id, :type => :string, :desc => "The node id for the datapath."
    }
    set_required_options [:display_name, :dpid, :node_id]

    define_standard_crud_commands

    rel_option :broadcast_mac_address, :type => :string, :required => true,
      :desc => "The broadcast mac address for mac2mac to use in this network."
    rel_option :interface_uuid, :type => :string, :required => true,
      :desc => "The host interface uuid to use for this network."
    define_relation :networks

    rel_option :mac_address, :type => :string, :required => true,
      :desc => "The mac address to use for this link"
    rel_option :interface_uuid, :type => :string, :required => true,
      :desc => "The host interface uuid to use for this route link."
    define_relation(:route_links)
  end
end
