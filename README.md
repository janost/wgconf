# Wgconf

## Wut?
Ruby gem to generate configuration for wireguard to build a mesh VPN of multiple nodes. Supports configuring gateway devices, keepalives, IPv4 and IPv6 subnets.

## Project status
It's usable, however I'm sure there are bugs. Please report if you find any.

## Should I use it?
Maybe. In my limited testing it works reliably.

## How to use it?
Run `wgconf example config.yml`, which will generate an example configuration with 3 nodes. Remove the private keys to generate new ones. Don't touch the `psk_map` section, it will be automatically generated and kept up-to-date. When you're done, run `wgconf generate config.yml --outdir configs`. The tool will write all configuration files in the `configs` directory.

## How/What to edit?
Don't add private keys manually, the tool will do that for you. Give your nodes descriptive names. It will also generate unique preshared keys for each node connection.

## Is this secure?
Your YAML configuration contains private and preshared keys for all of your nodes. Keep it in a secure place.

## What's up with [persistent keepalive][persistent-keepalive]?
You must set `persistent_keepalive` in your YAML configuration to a number greater than 0 to use this feature. Wgconf will automatically set up keepalive where it makes sense (one of the nodes have `client_only` set to `true` and the other one doesn't).

## Can I contribute?
Please do.


[persistent-keepalive]: https://www.wireguard.com/quickstart/#nat-and-firewall-traversal-persistence