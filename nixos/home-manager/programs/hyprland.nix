{ pkgs, ... }:

let
  keybinds-menu = pkgs.writeShellScriptBin "keybinds-menu" ''
    # 1. Resolve the actual path of the config (following Nix symlinks)
    CONF_PATH=$(readlink -f "$HOME/.config/hypr/hyprland.conf")

    # 2. Check if the file exists
    if [ ! -f "$CONF_PATH" ]; then
        notify-send "Error" "Hyprland config not found at $CONF_PATH"
        exit 1
    fi

    # 3. Parse the file
    # We use 'grep' to find binds, 'sed' to clean up the formatting,
    # and 'rofi' to display it.
    grep -E '^bind[e]? =' "$CONF_PATH" | \
    sed 's/bind[e]* = //g' | \
    sed 's/\$mainMod/SUPER/g' | \
    sed 's/exec, //g' | \
    rofi -dmenu -i -p "󱕰 Keybinds" \
    -theme-str 'window { width: 50%; } listview { lines: 15; }'
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

      monitor = ",preferred,auto,1.567"; # Setup for Framework screen

      exec-once = [
        "hyprpm reload -n"
        "waybar"
        "swww init"
        "nm-applet --indicator"
        "blueman-applet"
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
        "$mainMod SHIFT, T, exec, nwg-look"             # Appearance Settings
        "$mainMod SHIFT, S, exec, pavucontrol"    # Audio Settings
        "$mainMod SHIFT, I, exec, nm-connection-editor" # Network Settings
        "$mainMod SHIFT ALT, M, exit,"

        # Application Launcher
        "$mainMod, R, exec, rofi -show drun"

        # Window management
        "$mainMod, W, killactive,"
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
