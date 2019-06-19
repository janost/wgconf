# frozen_string_literal: true

module Wgconf
  module Model
    class Node
      attr_accessor :name, :addresses, :private_key, :listen_endpoint, :listen_port, :client_only

      def initialize(name = nil)
        @name = name
        @addresses = []
        @listen_port = 51_820
        @client_only = false
      end

      def encode_with(coder)
        vars = instance_variables.map(&:to_s)
        vars -= ['@name']

        vars.each do |var|
          # rubocop:disable Security/Eval
          var_val = eval(var)
          # rubocop:enable Security/Eval
          coder[var.gsub('@', '')] = var_val
        end
      end
    end
  end
end
