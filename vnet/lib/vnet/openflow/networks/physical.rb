# -*- coding: utf-8 -*-

module Vnet::Openflow::Networks

  class Physical < Base

    def network_type
      :physical
    end

    def install
      flows = []
      flows << flow_create(:default,
                           table: TABLE_NETWORK_SRC_CLASSIFIER,
                           goto_table: TABLE_ROUTE_INGRESS_INTERFACE,
                           priority: 30,
                           match_network: @id)
      flows << flow_create(:default,
                           table: TABLE_NETWORK_DST_CLASSIFIER,
                           goto_table: TABLE_PHYSICAL_DST,
                           priority: 30,
                           match_network: @id)

      @dp_info.add_flows(flows)
    end

    def update_flows
      local_actions = @interfaces.select { |interface_id, interface|
        interface[:port_number]
      }.collect { |interface_id, interface|
        { :output => interface[:port_number] }
      }

      # Include port LOCAL until we implement interfaces for local eth
      # ports.
      local_actions << { :output => OFPP_LOCAL }

      flows = []
      flows << flow_create(:default,
                           table: TABLE_FLOOD_LOCAL,
                           priority: 1,
                           match_network: @id,
                           actions: local_actions)

      @dp_info.add_flows(flows)
    end

  end

end
