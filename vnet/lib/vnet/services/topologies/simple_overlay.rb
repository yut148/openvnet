# -*- coding: utf-8 -*-

module Vnet::Services::Topologies
  class SimpleOverlay < Base
    include Celluloid::Logger

    def initialize(params)
      super

      @underlay_datapaths = {}
    end    

    def log_type
      'topology/simple_overlay'
    end

    [ [:network, :network_id],
      [:segment, :segment_id],
      [:route_link, :route_link_id]
    ].each { |other_name, other_key|

      define_method "handle_added_#{other_name}".to_sym do |assoc_id, assoc_map|
        debug log_format_h("handle added #{other_name}", assoc_map)

        other_id = get_param_id(assoc_map, other_key)

        @underlay_datapaths.each { |id, datapaths|
          debug log_format_h('trying underlay', datapaths)

          # TODO: Move to node_api.
          datapaths.each { |_, datapath|
            create_params = {
              datapath_id: datapath[:datapath_id],
              other_key => datapath[other_key],
              ip_lease_id: datapath[:ip_lease_id],
            }
            create_datapath_other(other_name, create_params)
          }
        }
      end

      define_method "handle_removed_#{other_name}".to_sym do |assoc_id, assoc_map|
      end

      define_method "updated_underlay_#{other_name}".to_sym do |datapath_id:, interface_id:, ip_lease_id:|
        other_list(other_name).each { |id, other_map|
          create_params = {
            datapath_id: datapath_id,
            other_key => other_map[other_key],
            interface_id: interface_id,
            ip_lease_id: ip_lease_id,
          }

          # TODO: Don't log errors when already exists.
          create_datapath_other(other_name, create_params)
        }
      end
    }

    def handle_added_underlay(assoc_id, assoc_map)
      debug log_format_h('handle added underlay', assoc_map)
    end

    def handle_removed_underlay(assoc_id, assoc_map)
      debug log_format_h('handle removed underlay', assoc_map)
    end

    def underlay_added_datapath(params)
      debug log_format_h('added underlay datapath', params)

      @underlays[get_param_id(params, :underlay_id)].tap { |tp_dp|
        if tp_dp.nil?
          debug log_format_h("no underlay found when adding updating underlay datapath", params)
          next
        end

        tp_id = get_param_id(params, :id)
        next if @underlay_datapaths[tp_id]

        dp = @underlay_datapaths[tp_id] = {
          datapath_id: get_param_id(params, :datapath_id),
          interface_id: get_param_id(params, :interface_id),
          ip_lease_id: get_param_id(params, :ip_lease_id),
        }

        updated_underlay_network(dp)
        updated_underlay_segment(dp)
        updated_underlay_route_link(dp)
      }
    end

    def underlay_removed_datapath(params)
      debug log_format_h('removed underlay datapath', params)
    end

  end
end
