# -*- coding: utf-8 -*-

module Vnctl
  class WebApi
    def initialize
      @webapi_uri = Vnctl.conf.webapi_uri
      @webapi_port = Vnctl.conf.webapi_port.to_i
      @webapi_version = Vnctl.conf.webapi_version
      @webapi_protocol = Vnctl.conf.webapi_protocol
      @output_format = Vnctl.conf.output_format

      @webapi_full_uri = "%s://%s:%s/api/%s" %
        [@webapi_protocol, @webapi_uri, @webapi_port, @webapi_version]
    end

    def send_request(verb, suffix, params = nil)
      uri = URI("#{@webapi_full_uri}/#{suffix}.#{@output_format}")

      uri.query = URI.encode_www_form(params) if params

      response = Net::HTTP.start(uri.host, uri.port) do |http|
        request = verb.new(uri.request_uri)
        http.request(request)
      end

      response.body
    end

    def post(suffix, params = nil)
      send_request(Net::HTTP::Post, suffix, params)
    end

    def get(suffix, params = nil)
      send_request(Net::HTTP::Get, suffix, params)
    end

    def put(suffix, params = nil)
      send_request(Net::HTTP::Put, suffix, params)
    end

    def delete(suffix, params = nil)
      send_request(Net::HTTP::Delete, suffix, params)
    end
  end
end
