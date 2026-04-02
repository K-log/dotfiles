{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 4;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "network" "cpu" "memory" "temperature" "battery" "pulseaudio" "tray" ];

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{name}";
        };

        "clock" = {
          format = " {:%I:%M %p}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-icons = [ "" "" "" "" "" ];
        };

        "network" = {
          format-wifi = " {essid}";
          format-disconnected = "⚠ Disconnected";
          on-click = "nm-connection-editor";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = { default = [ "" "" "" ]; };
          on-click = "pavucontrol";
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        border: none;
        border-radius: 0;
      }
      window#waybar {
        background-color: rgba(26, 27, 38, 0.85);
        color: #ffffff;
        transition-property: background-color;
        transition-duration: .5s;
      }
      #workspaces button {
        padding: 0 5px;
        color: #ffffff;
      }
      #workspaces button.active {
        background-color: #7aa2f7;
        color: #1a1b26;
      }
      #battery.critical:not(.charging) {
        background-color: #f7768e;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
    '';
  };
}
