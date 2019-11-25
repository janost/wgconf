module Wgconf
  module Model
    class NetConfig
      include Wgconf::Utils
      include Wgconf::Logging

      attr_accessor :interface_name, :listen_port, :nodes, :psk_map, :persistent_keepalive

      def initialize
        @interface_name = 'wg0'
        @listen_port = 51_820
        @ipv4_subnet = '172.30.0.0/24'
        @ipv6_subnet = 'fdf0:c12a:6673:b25f::/64'
        @persistent_keepalive = 0
        @nodes = []
        @psk_map = {}
      end

      def add_node(node)
        # TODO: NAME SHOULD BE UNIQUE!
        @nodes << node
      end

      def add_psk(node1, node2, psk)
        init_psk_map
        @psk_map[psk_map_key(node1, node2)] = psk
      end

      def psk?(node1, node2)
        init_psk_map
        @psk_map.key? psk_map_key(node1, node2)
      end

      def get_psk(node1, node2)
        init_psk_map
        @psk_map[psk_map_key(node1, node2)]
      end

      def validate(should_fix = false)
        validate_private_keys(should_fix)
        validate_psks(should_fix)
        validate_ips
      end

      def interface_cidr(address)
        cidr = NetAddr.parse_net(address)
        case cidr.version
        when 4
          network_cidr = NetAddr::IPv4Net.parse(@ipv4_subnet)
        when 6
          network_cidr = NetAddr::IPv6Net.parse(@ipv6_subnet)
        end
        "#{cidr.network}#{network_cidr.netmask}"
      end

      def ipv4?
        @ipv4_subnet.to_s != ''
      end

      def ipv6?
        @ipv6_subnet.to_s != ''
      end

      private

      def init_psk_map
        @psk_map ||= {}
      end

      def validate_private_keys(should_fix = false)
        @nodes.each do |node|
          unless node.private_key
            if should_fix
              log.info "[#{node.name}] Missing private key, assigning one."
              node.private_key ||= wg_genkey
            else
              log.info "[#{node.name}] Node doesn't have a private key assigned. This will be fixed automatically."
            end
          end
        end
      end

      def validate_psks(should_fix = false)
        @nodes.each do |node|
          @nodes.each do |pair|
            next if node.name == pair.name
            next if node.client_only && pair.client_only

            unless psk?(node, pair)
              if should_fix
                log.info "[PSK] Nodes (#{node.name} - #{pair.name}) don't have a PSK assigned, assigning one."
                add_psk(node, pair, wg_genpsk)
              else
                log.info "[PSK] Nodes (#{node.name} - #{pair.name}) don't have a PSK assigned. This will be fixed automatically."
              end
            end

            get_psk(node.name, pair.name)
          end
        end
      end

      def validate_ips
        # TODO: dupe IPs?
        @nodes.each do |node|
          if node.addresses.nil? || node.addresses.empty?
            validation_failure "[#{node.name}] Node has no IP addresses assigned."
          else
            node.addresses.each do |addr|
              net_addr = NetAddr.parse_net(addr).network
              case net_addr.version
              when 4
                unless NetAddr.parse_net(@ipv4_subnet).contains(net_addr)
                  validation_failure "[#{node.name}] Node's IPv4 address is not in the network's subnet (#{@ipv4_subnet})."
                end
              when 6
                unless NetAddr.parse_net(@ipv6_subnet).contains(net_addr)
                  validation_failure "[#{node.name}] Node's IPv6 address is not in the network's subnet (#{@ipv6_subnet})."
                end
              end
            end
          end
        end
      end

      def psk_map_key(node1, node2)
        k1 = node1.instance_of?(Wgconf::Model::Node) ? node1.name : node1
        k2 = node2.instance_of?(Wgconf::Model::Node) ? node2.name : node2
        [k1, k2].sort.join(' - ')
      end

      def validation_failure(message)
        log.error message
        raise Wgconf::Error::ValidationError, message
      end
    end
  end
end
