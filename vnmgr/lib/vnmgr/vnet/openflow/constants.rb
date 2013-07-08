# -*- coding: utf-8 -*-

module Vnmgr::VNet::Openflow

  MW = Vnmgr::ModelWrappers

  module Constants
    # Default table used by all incoming packets.
    TABLE_CLASSIFIER = 0

    # Handle matching of incoming packets on host ports.
    TABLE_HOST_PORTS = 2

    # Straight-forward routing of packets to the port tied to the
    # destination mac address, which includes all non-virtual
    # networks.
    TABLE_TUNNEL_PORTS = 3
    #TABLE_ROUTE_DIRECTLY = 3

    # Routing to non-virtual networks with filtering applied.
    #
    # Due to limitations in the rules we can use the filter rules
    # for the destination must be applied first, and its port number
    # loaded into a registry.
    #
    # The source will then apply filtering rules and output to the
    # port number found in registry 1.
    TABLE_PHYSICAL_DST = 4
    TABLE_PHYSICAL_SRC = 5

    # Routing to virtual networks.
    #
    # Each port participating in a virtual network will load the
    # virtual network id to registry 2 in the classifier table for
    # all types of packets.
    #
    # The current filtering rules are bare-boned and provide just
    # routing.
    TABLE_VIRTUAL_SRC = 6
    TABLE_VIRTUAL_DST = 7

    # The ARP antispoof table ensures no ARP packet SHA or SPA field
    # matches the mac address owned by another port.
    #
    # If valid, the next table routes the packet to the right port.
    TABLE_ARP_ANTISPOOF = 10
    TABLE_ARP_ROUTE = 11

    TABLE_MAC_ROUTE = 14

    # Output to port based on the metadata field. OpenFlow 1.3 does
    # not seem to have any action allowing us to output to a port
    # using the metadata field directly, so a separate table is
    # required.
    TABLE_METADATA_LOCAL = 15
    TABLE_METADATA_ROUTE = 16
    TABLE_METADATA_SEGMENT = 17
    TABLE_METADATA_TUNNEL = 18

    COOKIE_NETWORK_SHIFT = 32

    METADATA_FLAGS_MASK = (0xffff << 48)
    METADATA_FLAGS_SHIFT = 48

    METADATA_FLAG_LOCAL  = (0x1 << 48)
    METADATA_FLAG_REMOTE = (0x2 << 48)

    METADATA_PORT_MASK = 0xffffffff
    METADATA_NETWORK_MASK = (0xffff << 32)
    METADATA_NETWORK_SHIFT = 32
    
    TUNNEL_FLAG = (0x1 << 31)
    TUNNEL_FLAG_MASK = 0x80000000
    TUNNEL_NETWORK_MASK = 0x7fffffff
  end

end
