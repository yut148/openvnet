# -*- coding: utf-8 -*-

require "sinatra"
require "sinatra/vnet_api_setup"
require "sinatra/browse"

module Vnet::Endpoints::V10
  class VnetAPI < Sinatra::Base
    include Vnet::Endpoints::V10::Helpers
    include Vnet::Endpoints::V10::Helpers::UUID
    include Vnet::Endpoints::V10::Helpers::Parsers

    register Sinatra::VnetAPISetup
    register Sinatra::Browse

    M = Vnet::ModelWrappers
    E = Vnet::Endpoints::Errors
    R = Vnet::Endpoints::V10::Responses

    DEFAULT_PAGINATION_LIMIT = 30

    def config
      Vnet::Configurations::Webapi.conf
    end

    # Remove the splat and captures parameters so we can pass @params directly
    # to the model classes
    def remove_system_parameters
      @params.delete("splat")
      @params.delete("captures")
    end

    default_on_error do |error_hash|
      if error_hash[:reason] == :required
        raise E::MissingArgument, error_hash[:parameter]
      else
        raise E::ArgumentError, {
          error: "parameter validation failed",
          parameter: error_hash[:parameter],
          value: error_hash[:value],
          reason: error_hash[:reason]
        }
      end
    end

    def self.param_uuid(prefix, name = :uuid, options = {})
      #TODO: Make sure that the InvalidUUID error here is the same one as the check_uuid_syntax method
      #TODO: Allow access to default_on_error in here
      error_handler = proc { |result|
        case result[:reason]
        when :format
          raise(E::InvalidUUID, "Invalid format for #{name}: #{result[:value]}")
        when :required
          raise E::MissingArgument, result[:parameter]
        else
          raise E::ArgumentError, {
            error: "parameter validation failed",
            parameter: result[:parameter],
            value: result[:value],
            reason: result[:reason]
          }
        end
      }

      final_options = {
        format: /^#{prefix}-[a-z]{1,8}$/,
        on_error: error_handler
      }

      final_options.merge!(options)

      param name, :String, final_options
    end

    def delete_by_uuid(class_name)
      model_wrapper = M.const_get(class_name)
      uuid = @params[:uuid]
      # TODO don't need to find model here
      check_syntax_and_pop_uuid(model_wrapper, @params)
      model_wrapper.destroy(uuid)
      respond_with([uuid])
    end

    # TODO remove fill
    def get_all(class_name, fill = {})
      model_wrapper = M.const_get(class_name)
      response = R.const_get("#{class_name}Collection")
      limit = @params[:limit] || config.pagination_limit
      offset = @params[:offset] || 0
      total_count = model_wrapper.batch.count.commit
      items = model_wrapper.batch.dataset.offset(offset).limit(limit).all.commit(fill: fill)
      pagination = {
        "total_count" => total_count,
        "offset" => offset,
        "limit" => limit,
      }
      respond_with(response.generate_with_pagination(pagination, items))
    end

    def get_by_uuid(class_name, fill = {})
      model_wrapper = M.const_get(class_name)
      response = R.const_get(class_name)
      object = check_syntax_and_pop_uuid(model_wrapper, @params, "uuid", fill)
      respond_with(response.generate(object))
    end

    def update_by_uuid(class_name, fill = {})
      model_wrapper = M.const_get(class_name)
      response = R.const_get(class_name)

      model = check_syntax_and_pop_uuid(model_wrapper, params)

      # This yield is for extra argument validation
      yield(params) if block_given?

      remove_system_parameters

      updated_object = model_wrapper.batch.update(model.uuid, params).commit(:fill => fill)
      respond_with(response.generate(updated_object))
    end

    def post_new(class_name, fill = {})
      model_wrapper = M.const_get(class_name)
      response = R.const_get(class_name)

      check_and_trim_uuid(model_wrapper, params) if params["uuid"]

      # This yield is for extra argument validation
      yield(params) if block_given?
      object = model_wrapper.batch.create(params).commit(:fill => fill)
      respond_with(response.generate(object))
    end

    def show_relations(class_name, response_method)
      limit = @params[:limit] || config.pagination_limit
      offset = @params[:offset] || 0
      object = check_syntax_and_pop_uuid(M.const_get(class_name), @params)
      total_count = object.batch.send(response_method).count.commit
      items = object.batch.send("#{response_method}_dataset").offset(offset).limit(limit).all.commit
      pagination = {
        "total_count" => total_count,
        "offset" => offset,
        "limit" => limit,
      }

      response = R.const_get("#{response_method.to_s.classify}Collection")
      respond_with(response.generate_with_pagination(pagination, items))
    end

    respond_to :json, :yml

    load_namespace('datapaths')
    load_namespace('dns_services')
    load_namespace('interfaces')
    load_namespace('ip_leases')
    load_namespace('ip_ranges')
    load_namespace('lease_policies')
    load_namespace('mac_leases')
    load_namespace('networks')
    load_namespace('network_services')
    load_namespace('routes')
    load_namespace('route_links')
    load_namespace('security_groups')
    load_namespace('translations')
    load_namespace('vlan_translations')
  end
end
