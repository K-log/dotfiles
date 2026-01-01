{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Use the unwrapped version for better compatibility
    package = pkgs.neovim-unwrapped;

    # Enable providers
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    # Add extra packages that Neovim can use
    extraPackages = with pkgs; [
      # Language servers (if not using Mason for these)
      lua-language-server
      nil # Nix LSP
      
      # Formatters
      stylua
      nixpkgs-fmt
      
      # Build tools for Mason and native plugins
      gcc
      gnumake
      cmake
      pkg-config
      
      # Essential tools
      git
      curl
      wget
      unzip
      gzip
      gnutar

      # For Mason to work properly
      nodejs
      cargo
      go
      python311
      python311Packages.python
      
      # Tree-sitter CLI (for :TSInstall)
      tree-sitter
    ];

    # IF Lazy is not found, manually install it
    # Extra Lua configuration
    # extraLuaConfig = ''
    #   -- Ensure Mason and lazy.nvim can install to stdpath locations
    #   -- These paths are writable in home-manager
    #   local data_path = vim.fn.stdpath("data")
    #
    #   -- Add Mason binaries to PATH
    #   vim.env.PATH = data_path .. "/mason/bin:" .. vim.env.PATH
    #
    #   -- Ensure lazy.nvim can write to its directory
    #   -- This is automatically handled by lazy, but we set it explicitly
    #   vim.g.lazy_path = data_path .. "/lazy"
    #
    #   -- Optional: Set up some basic options before lazy loads
    #   vim.opt.number = true
    #   vim.opt.relativenumber = true
    #   vim.opt.expandtab = true
    #   vim.opt.shiftwidth = 2
    #   vim.opt.tabstop = 2
    #   require("${config.home.homeDirectory}/dotfiles/nvim")
    # '';
  };

  # Symlink your existing Neovim config
  # This allows you to edit your config without running home-manager switch
  # DOES NOT WORK
  # xdg.configFile."nvim" = {
  #   # Use mkOutOfStoreSymlink to avoid copying to nix store
  #   # This allows live editing of your config
  #   source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
  # };

  # Additional packages for Neovim ecosystem
  home.packages = with pkgs; [
    # Fuzzy finder and dependencies (for Telescope)
    ripgrep
    fd
    fzf
    
    # Git tools
    lazygit
    delta
    
    # Language specific tools
    # Add more based on your needs
    
    # Python
    python311Packages.pip
    python311Packages.pynvim
    
    # Node.js packages (optional, if not using Mason for these)
    nodePackages.npm
    nodePackages.neovim
    
    # Clipboard support
    xclip # for X11
    wl-clipboard # for Wayland
  ];

  # Optional: Set environment variables for Neovim
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    GIT_EDITOR = "nvim";
  };
}
