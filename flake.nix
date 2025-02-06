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

      # defaults
      defaultUsername = "sijan";
      defaultGitUser = "thapasijan171";
      defaultGitEmail = "56615615+thapasijan329@users.noreply.github.com";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        # allow all unfree packages no matter the license status, this is potentially dangerous and should be used with caution
        config.allowUnfreePredicate = _: true;
      };

      mkSystem =
        {
          host,
          home,
          username ? defaultUsername,
          gitUser ? defaultGitUser,
          gitEmail ? defaultGitEmail,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;

          specialArgs = {
            inherit
              username
              gitUser
              gitEmail
              host
              ;
          };
          modules = [
            ./hosts/${host}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./homes/${home}/home.nix;
              home-manager.extraSpecialArgs = {
                inherit
                  username
                  gitUser
                  gitEmail
                  ;
              };
            }
          ];
        };
      mkHome =
        {
          home,
          username ? defaultUsername,
          gitUser ? defaultGitUser,
          gitEmail ? defaultGitEmail,
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./homes/${home}/home.nix ];
          extraSpecialArgs = {
            inherit
              username
              gitUser
              gitEmail
              ;
          };
        };
    in
    {
      nixosConfigurations = {
        "sijan@cedar" = mkSystem {
          host = "cedar";
          home = "sijandots";
          username = "sijan";
        };

        # feel free to change the username
        "someone@hyprdots-host" = mkSystem {
          host = "hyprdots-host";
          home = "hyprdots";
          username = "someone";
        };

        # feel free to change the username
        "sijan@hyprdots-host" = mkSystem {
          host = "hyprdots-host";
          home = "sijandots";
          username = "sijan";
        };
      };

      homeConfigurations = {
        sijandots = mkHome { home = "sijandots"; };
        hyprdots = mkHome { home = "hyprdots"; };
      };

      nixosConfigurations.nixos = self.nixosConfigurations."sijan@cedar";
    };
}
