{ pkgs, user, hostname, ... }:

{

  imports = [
    ./programs/neovim.nix
    ./programs/hyprland.nix
    ./programs/waybar.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = user;
  home.homeDirectory = "/home/${user}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # home.file.".zshrc" = {
  #   source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.zshrc";
  # };


  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    keybinds-menu
    git
    rustup
    rustc
    go
    python311
    python311Packages.pip
    python311Packages.virtualenv
    javaPackages.compiler.openjdk21
    luajit_2_0
    luajitPackages.luarocks
    love
    gcc
    gnumake
    gnused
    curl
    wget
    jq
    unzip
    opencode
    ghostty
    gh
    jetbrains-toolbox
    godot_4_6

    # zsh
    zsh
    oh-my-zsh
    nix-zsh-completions

    # deps
    pkg-config
    # pkgs.wayland-client
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/nvim".enable = false;
  };

  xdg.configFile."nvim".enable = false;

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/noah/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # The command to rebuild your Flake-based system
      nix-switch = "sudo nixos-rebuild switch --flake /etc/nixos#${hostname}";
      nix-check = "nixos-rebuild dry-activate --flake /etc/nixos#${hostname}";
    };

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "z" "fzf" "nvm" "urltools" ];
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # VARIABLES
      "$terminal" = "ghostty";
      "$mainMod" = "SUPER";

      monitor = ",preferred,auto,1.5"; # Setup for Framework screen

      exec-once = [
        "hyprpm reload -n"
        "waybar"
        "swww init"
        "waybar"                 # Starts your top bar
        "nm-applet --indicator"  # Starts the Wi-Fi icon
        "blueman-applet"         # Starts the Bluetooth icon
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true; # Feels better on Framework
          tap-to-click = true;
        };
      };
      bind = [
        # Terminal & Browser
        "$mainMod, Q, exec, $terminal"
        "$mainMod, B, exec, firefox"

        # KEYBINDINGS HELPER
        "$mainMod SHIFT, K, exec, keybinds-menu"

        # SETTINGS PANEL SHORTCUTS
        "$mainMod, S, exec, nwg-look"             # Appearance Settings
        "$mainMod SHIFT, S, exec, pavucontrol"    # Audio Settings
        "$mainMod, W, exec, nm-connection-editor" # Network Settings

        # Application Launcher
        "$mainMod, R, exec, rofi -show drun"

        # Window management
        "$mainMod, C, killactive,"
        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreen,"

        # Focus movement
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
      ];
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Atom One Dark";
      font-size = 14;
      window-decoration = false;
      font-family = "JetBrainsMono Nerd Font";
      background-opacity = 0.95;
      cursor-style = "block";
      shell-integration-features = "true";
    };
  };

# Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
