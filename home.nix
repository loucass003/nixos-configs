{ config, pkgs, ... }:

let
  screamOverride = pkgs.scream.override { pulseSupport = true; };
  wrappedObs = pkgs.runCommand "obs-studio" { buildInputs = [ pkgs.makeWrapper ]; } ''
    makeWrapper ${pkgs.obs-studio}/bin/obs $out/bin/obs \
      --set QT_SCALE_FACTOR 1.2
  '';
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
    evince # pdf reader

    # desktop look & feel
    gnome.gnome-tweak-tool

    # extensions
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.caffeine
    
    xorg.libXxf86vm    
    libpulseaudio
    minecraft
    lutris
    qlcplus
    postman
    mongodb-compass
    filezilla
    jetbrains.idea-community
    jetbrains.datagrip
    gradleGen.gradle_4_10
    htop
    google-chrome
    firefox
    unrar
    unzip
    vscode
    lm_sensors
    docker-compose
    usbutils
    pciutils
    pavucontrol
    screamOverride
    spice_gtk
    transmission-qt
    etcher
    pulseeffects-legacy
    winusb
    blender
    (makeDesktopItem {
      name = "obs";
      desktopName = "Obs Studio";
      icon = "${obs-studio}/share/icons/hicolor/256x256/apps/com.obsproject.Studio.png";
      exec = "${wrappedObs}/bin/obs";
      categories = "System";
    })
    droidcam
    gjs
  ]);


  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  
  programs.obs-studio = {
    enable = true;
    package = wrappedObs;
    plugins = [
    ];

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
    };
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
