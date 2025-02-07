# Evo-nix

Evo-nix is an experimental nixos configuration. The goal is to have a fully working home-manager module, with an optional nixos host configuration.

installation is available as a nixos host and vm.

## requirements

- nixos install
  - it may be possible to use nix the package manager on other operating systems. i haven't tried it.
  
- git

## installation as a vm / nixos host

1. clone this repository:

   ```bash
    git clone https://github.com/thapasijan17/evo-os.git
    cd evo-os
   ```

2. edit `flake.nix`:
   - replace `<username>`, `<host>`, and github settings with your info
   - a default password is given for sudo usage in the vm
   - feel free to change it with passwd when you login

3. generate hardware configuration:

   ```bash
   sudo nixos-generate-config --show-hardware-config > ./hardware-configuration.nix
   ```

4. build and switch to your new configuration:

   - using a vm (recommended):
     ```bash
     nix run .
     ```

   - or using nixos:
     ```bash
     sudo nixos-rebuild switch --flake
     reboot
     ```

## updating and development

To update and rebuild the vm (recommended) or host:

```bash
git pull
nix run .  
```

> **note:** any changes require the vm to be rebuilt. run `rm <host>.qcow2` to remove the old one.


## troubleshooting

if you encounter any issues, please check the nixos and home manager logs:

```
journalctl -b
journalctl --user -b
```
