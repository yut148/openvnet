# -*- coding: utf-8 -*-

module Vnet::Models

  class LeasePolicyBaseInterface < Base

    many_to_one :lease_policy

    subset(:alives, {})  # TODO, understand this

  end

end
