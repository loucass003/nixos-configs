{ config, lib, pkgs, ... }:

let

in
{
  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "llelievr";
  home.homeDirectory = "/home/llelievr";

  programs.git = {
    enable = true;
    userName = "loucass003";
    userEmail = "loucass003@gmail.com";
  };

  home.packages = (with pkgs; [
    oh-my-zsh
    gnome.eog    # image viewer
    evince       # pdf reader

    # desktop look & feel
    gnome.gnome-tweaks

    # extensions
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.caffeine
    gnomeExtensions.screenshot-tool
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.bluetooth-quick-connect
    gnomeExtensions.refresh-wifi-connections
    gnomeExtensions.sound-output-device-chooser
    
    xorg.libXxf86vm    
    libpulseaudio
    postman
    filezilla
    jetbrains.datagrip
    htop
    google-chrome
    firefox
    openssl
    unrar
    unzip
    vscode
    docker-compose
    usbutils
    pciutils
    pavucontrol
    gimp
    spotify
    discord
    lutris
    gjs
    heroku
    (pkgs.writeShellScriptBin "upload-uat" ''
        cp linkaband-front/dist linkaband-front/package.json linkaband-front/package-lock.json -r lkb-uat
        rm -rf lkb-uat/dist/browser/stats-es2015.json lkb-uat/dist/browser/stats-es5.json 
        cd lkb-uat
        git add dist package.json package-lock.json
        git commit -m "$1"
        git push heroku master
    '')
    parsec-bin
    dbeaver
    mysql80
    obs-studio
    beekeeper-studio
    gcc
    gnumake
    cargo
    rustc
    pkgconfig
    steam
  ]);


  programs.zellij = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };


  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true; 
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git"
        "python"
        "man"
      ];
    };
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        file = "zsh-syntax-highlighting.zsh";
        src = pkgs.fetchFromGitHub {
    	  owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
        };
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.1.0";
          sha256 = "0snhch9hfy83d4amkyxx33izvkhbwmindy0zjjk28hih1a9l2jmx";
        };
      }
    ];
    localVariables = {
      LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:$HOME/.nix-profile/lib";
      EDITOR = "nvim";
    };
  };

  manual.manpages.enable = false;

  programs.neovim = {
    enable = true;
    vimAlias = true;
  };

  

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
