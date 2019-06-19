# Wgconf

## Wut?
Ruby gem to generate configuration for wireguard to build a mesh VPN of multiple nodes. Currently it's very messy and it's a work-in-progress.

## Should I use it?
No, you should wait. It's **really** messy right now.

## How to use it?
Run `wgconf example config.yml`, which will generate an example configuration with 3 nodes. Remove the private keys to generate new ones. Don't touch the `psk_map` section, it will be automatically generated and kept up-to-date. When you're done, run `wgconf generate config.yml --outdir configs`. The tool will write all configuration files in the `configs` directory.

## How/What to edit?
The only things you can do right now is customize some global variables and add your own nodes instead of the example ones. Don't add private keys manually, the tool will do that for you. Give your nodes descriptive names. It will also generate unique preshared keys for each node connection.

## Is this secure?
Your YAML configuration contains private and preshared keys for all of your nodes. Keep it in a secure place.

## Can I contribute?
Please do.
