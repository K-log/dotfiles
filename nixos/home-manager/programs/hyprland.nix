{ pkgs, ... }:

let
  keybinds-menu = pkgs.writeShellScriptBin "keybinds-menu" ''
    CONF=$HOME/.config/hypr/hyprland.conf
    if [ ! -f "$CONF" ]; then
        CONF=$(readlink -f $HOME/.config/hypr/hyprland.conf)
    fi
    grep -E '^bind =' "$CONF" | \
    sed 's/bind = //g; s/\$mainMod/SUPER/g; s/exec, //g' | \
    rofi -dmenu -i -p "󱕰 Keybinds"
  '';
in
{
  home.packages = [ keybinds-menu ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
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
        "$mainMod SHIFT ALT, M, exit,"

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
}
