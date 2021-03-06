# -*- coding: utf-8 -*-
require 'spec_helper'
require 'vnet'
Dir["#{File.dirname(__FILE__)}/shared_examples/*.rb"].map {|f| require f }
Dir["#{File.dirname(__FILE__)}/matchers/*.rb"].map {|f| require f }

def app
  Vnet::Endpoints::V10::VnetAPI
end

describe "/routes" do
  let(:api_suffix) { "routes" }
  let(:fabricator) { :route }
  let(:model_class) { Vnet::Models::Route }

  include_examples "GET /"
  include_examples "GET /:uuid"
  include_examples "DELETE /:uuid"

  describe "POST /" do
    let!(:interface) { Fabricate(:interface) { uuid "if-test"}  }
    let!(:network) { Fabricate(:network) { uuid "nw-test" } }
    let!(:route_link) { Fabricate(:route_link) { uuid "rl-test" } }
    accepted_params = {
      :uuid => "r-testrout",
      :interface_uuid => "if-test",
      :network_uuid => "nw-test",
      :route_link_uuid => "rl-test",
      :ipv4_network => "192.168.10.0",
      :ipv4_prefix => 16,
      :ingress => true,
      :egress => false
    }
    required_params = [:ipv4_network, :interface_uuid, :network_uuid, :route_link_uuid]
    uuid_params = [:interface_uuid, :interface_uuid, :network_uuid, :route_link_uuid]

    include_examples "POST /", accepted_params, required_params, uuid_params
  end

end
