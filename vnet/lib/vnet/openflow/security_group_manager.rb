# -*- coding: utf-8 -*-

module Vnet::Openflow
  class SecurityGroupManager < Manager
    include Vnet::Openflow::FlowHelpers

    COOKIE_TAG_SG_RULE     = 0x1 << COOKIE_TAG_SHIFT
    COOKIE_TAG_SG_CONTRACK = 0x2 << COOKIE_TAG_SHIFT
    COOKIE_TAG_SG_ARP      = 0x3 << COOKIE_TAG_SHIFT
    COOKIE_TAG_SG_EGRESS   = 0x4 << COOKIE_TAG_SHIFT

    Connections = Vnet::Openflow::SecurityGroups::Connections

    def initialize(*args)
      super(*args)

      accept_all_egress
      accept_ingress_arp
    end

    def packet_in(message)
      case message.table_id
      when TABLE_INTERFACE_INGRESS_FILTER
        apply_rules(message)
      when TABLE_INTERFACE_EGRESS_FILTER
        open_connection(message)
      end
    end

    def cookie(interface)
      cookie = interface.id | COOKIE_TYPE_SECURITY_GROUP
    end

    def catch_ingress_packet(interface)
      flows = [
        flow_create(:default,
                    table: TABLE_INTERFACE_INGRESS_FILTER,
                    priority: 1,
                    match_metadata: { interface: interface.id },
                    cookie: cookie(interface),
                    actions: { output: Controller::OFPP_CONTROLLER }),
      ]

      @dp_info.add_flows(flows)
    end

    def catch_new_egress_connection(interface, mac_info, ipv4_info)
      flows = [IPV4_PROTOCOL_TCP, IPV4_PROTOCOL_UDP].map { |protocol|
        flow_create(:default,
                    table: TABLE_INTERFACE_EGRESS_FILTER,
                    priority: 20,
                    match: {
                      eth_src: mac_info[:mac_address],
                      eth_type: ETH_TYPE_IPV4,
                      ip_proto: protocol
                    },
                    match_metadata: { interface: interface.id },
                    cookie: cookie(interface),
                    actions: { output: Controller::OFPP_CONTROLLER })
      }

      @dp_info.add_flows(flows)
    end

    def uninstall(interface)
    end

    private
    def accept_all_egress
      @dp_info.add_flows [
        flow_create(:default,
                    table: TABLE_INTERFACE_EGRESS_FILTER,
                    priority: 1,
                    cookie: COOKIE_TYPE_SECURITY_GROUP | COOKIE_TAG_SG_EGRESS,
                    goto_table: TABLE_INTERFACE_CLASSIFIER)
      ]
    end

    def accept_ingress_arp
      @dp_info.add_flows [
        flow_create(:default,
                    table: TABLE_INTERFACE_INGRESS_FILTER,
                    priority: 100,
                    cookie: COOKIE_TYPE_SECURITY_GROUP | COOKIE_TAG_SG_ARP,
                    match: { eth_type: ETH_TYPE_ARP },
                    goto_table: TABLE_INTERFACE_VIF)
      ]
    end

    def open_connection(message)
      flows = if message.tcp?
        Connections::TCP.new.open(message)
      elsif message.udp?
        Connections::UDP.new.open(message)
      end

      @dp_info.add_flows(flows)
      @dp_info.send_packet_out(message, OFPP_TABLE)
    end

    def apply_rules(message)
      interface_id = message.cookie & COOKIE_ID_MASK
      interface = MW::Interface.batch[interface_id].commit

      groups = interface.batch.security_groups.commit.map { |g|
        Vnet::Openflow::SecurityGroups::SecurityGroup.new(g)
      }

      flows = groups.map { |g| g.install(interface) }.flatten

      @dp_info.add_flows(flows)
      @dp_info.send_packet_out(message, OFPP_TABLE)
    end
  end
end
