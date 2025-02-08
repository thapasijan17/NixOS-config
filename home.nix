{
  config,
  lib,
  pkgs,
  username,
  gitUser,
  gitEmail,
  ...
}:

{

  home.username = username;
  home.homeDirectory = "/home/${username}";

  imports = [
    ./modules/hyprdots-build.nix
    ./modules/hyprdots-hyde.nix
  ];

  # TODO: hyprdots-build module
  # modules.hyprdots-build = {
  #   enable = true;
  #   cleanBuild = true;
  # };

  modules.hyprdots-hyde = {
    enable = true;
  };

  # enabling this will create files in .config/hypr
  # we will be replacing this with the hyprdots-build
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    extraConfig = ''
      exec-once = kitty $HOME/hyprdots-first-boot.sh
      exec-once = touch $HOME/.zshrc
    '';
  };

  # ===== Home Packages =====
  home.packages = with pkgs; [
    # Hyprdots dependencies
    dconf
    git
    gum
    coreutils
    findutils
    wget
    unzip
    jq
    kitty
    dunst
    lsd
    mangohud
    hyprland
    fastfetch
    qt5ct
    qt6ct
    rofi-wayland
    swaylock
    waybar
    wlogout
    nwg-look
    dolphin
    libinput-gestures
    (callPackage ./modules/pokemon-colorscripts.nix { })
  ];

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "${gitUser}";
      userEmail = "${gitEmail}";
    };
    waybar = {
      enable = true;
      package = pkgs.waybar;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  fonts.fontconfig.enable = true;
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.stateVersion = "24.11";
}
