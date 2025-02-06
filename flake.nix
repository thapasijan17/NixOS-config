{
  description = "NixOS configuration for Hyprdots";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";

      username = "editme";
      gitUser = "editme";
      gitEmail = "editme";
      host = "editme";
      defaultPassword = "editme";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowUnfreePredicate = _: true;
      };

      mkVM =
        { nixosSystem, ... }:
        nixosSystem.extendModules {
          modules = [
            (
              { config, pkgs, ... }:
              {
                virtualisation.libvirtd.enable = true;
                virtualisation.vmVariant = {
                  virtualisation = {
                    memorySize = 8192; # 8GB RAM
                    cores = 4;
                    qemu = {
                      options = [
                        "-vga none"
                        "-device virtio-gpu-gl-pci"
                        "-display gtk,gl=on"
                        "-device virtio-tablet-pci"
                        "-device virtio-keyboard-pci"
                        "-display gtk,gl=on,show-cursor=on"
                      ];
                    };
                  };
                  services.xserver.displayManager.autoLogin = {
                    enable = true;
                    user = username;
                  };

                  services.spice-vdagentd.enable = true;
                };
                environment.sessionVariables = {
                  WLR_NO_HARDWARE_CURSORS = "1";
                  WLR_RENDERER_ALLOW_SOFTWARE = "1";
                };
                users.users.${username} = {
                  initialPassword = defaultPassword;
                  extraGroups = [ "libvirtd" ];
                };
                environment.systemPackages = with pkgs; [
                  open-vm-tools
                  virt-manager
                  OVMF
                  qemu
                  virglrenderer
                  xorg.xf86inputvmmouse
                ];
                virtualisation.libvirtd.qemu.ovmf.enable = true;
                virtualisation.libvirtd.qemu.runAsRoot = true;
              }
            )
          ];
        };

    in
    {
      nixosConfigurations = {
        hyprdots-nix = nixpkgs.lib.nixosSystem {
          inherit system pkgs;

          specialArgs = {
            inherit
              username
              gitUser
              gitEmail
              host
              ;
          };

          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit username gitUser gitEmail;
              };
            }
          ];
        };

        hyprdots-nix-vm = mkVM {
          nixosSystem = nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            specialArgs = {
              inherit
                username
                gitUser
                gitEmail
                host
                defaultPassword
                ;
            };
            modules = [
              ./configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = import ./home.nix;
                home-manager.extraSpecialArgs = {
                  inherit username gitUser gitEmail;
                };
              }
            ];
          };
        };

      };
      packages.${system}.default = self.nixosConfigurations.hyprdots-nix-vm.config.system.build.vm;
    };
}
