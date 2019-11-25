module Wgconf
  module Model
    class Node
      attr_accessor :name, :addresses, :private_key, :listen_endpoint, :listen_port, :client_only, :gateway

      def initialize(name = nil)
        @name = name
        @addresses = []
        @listen_port = 51_820
        @client_only = false
        @gateway = false
      end
    end
  end
end
