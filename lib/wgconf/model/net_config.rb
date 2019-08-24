module Wgconf
  module Model
    class NetConfig
      include Wgconf::Utils
      attr_accessor :interface_name, :listen_port, :nodes, :psk_map, :persistent_keepalive

      def initialize
        @interface_name = 'wg0'
        @listen_port = 51_820
        @persistent_keepalive = 0
        @nodes = []
        @psk_map = {}
      end

      def add_node(node)
        # TODO: NAME SHOULD BE UNIQUE!
        @nodes << node
      end

      def add_psk(node1, node2, psk)
        @psk_map[psk_map_key(node1, node2)] = psk
      end

      def psk?(node1, node2)
        @psk_map.key? psk_map_key(node1, node2)
      end

      def get_psk(node1, node2)
        if psk?(node1, node2)
          @psk_map[psk_map_key(node1, node2)]
        else
          add_psk(node1, node2, wg_genpsk)
        end
      end

      def finalize
        ensure_private_keys
        ensure_psks
      end

      private

      def ensure_private_keys
        @nodes.each do |node|
          node.private_key ||= wg_genkey
        end
      end

      def ensure_psks
        @nodes.each do |node|
          @nodes.each do |pair|
            next if node.name == pair.name

            get_psk(node.name, pair.name)
          end
        end
      end

      def psk_map_key(node1, node2)
        k1 = node1.instance_of?(Wgconf::Model::Node) ? node1.name : node1
        k2 = node2.instance_of?(Wgconf::Model::Node) ? node2.name : node2
        [k1, k2].sort.join(' - ')
      end
    end
  end
end
