cat /etc/nixos/configuration.nix 
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
     oldPkgs = import (builtins.fetchGit {
         # Descriptive name to make the store path easier to identify                
         name = "node-10";                                             
         url = "https://github.com/NixOS/nixpkgs/";                       
         ref = "refs/heads/nixpkgs-unstable";                     
         rev = "80bda4933272f7e244dc9702f39d18433988cdd0";                                           
     }) {};
     nodejs10 = oldPkgs.nodejs;
     php73 = oldPkgs.php73;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    kernelModules = [ "v4l2loopback" ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1
    '';
    loader = {
      grub = {
        useOSProber = true;
      };
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "ntfs" ]; 
  };
  
  networking = {
    firewall.allowedTCPPorts = [
	    25565
    ];
  };

  fonts.fonts = with pkgs; [
    nerdfonts
  ];

  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm = {
         enable = true;
         wayland = false;
      };
      layout = "us";
    };
    dbus.packages = [ pkgs.gnome.dconf-editor ];
    udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
    teamviewer.enable = true;
  };
  
   hardware = {
    opengl = {
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };
    pulseaudio = {
      enable = true;
      extraConfig = ''
      	# Automatically switch to newly connected devices.
        # load-module module-switch-on-connect
        default-sample-rate = 48000
      '';
    };
  };
  
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      logDriver = "json-file";
      extraOptions = "--log-opt max-size=10m --log-opt max-file=3";
    };
  };
  
   programs = {
    zsh.enable = true;
  };


  users = {
    mutableUsers = true;
    defaultUserShell = pkgs.zsh;
    users = {
      llelievr = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "docker" "dialout" "adbusers" "video" ];
      };
    };
  };
  nix.settings.allowed-users = [ "@wheel" ];

  sound = {
    enable = true;
    mediaKeys = {
      enable = true;
      volumeStep = "5%";
    };
  };

  time.timeZone = "Europe/Paris";
  
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-10.24.1"
  ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget·
  environment.systemPackages = with pkgs; [
    nodejs10
    php73
    git
    gnome.gnome-tweaks
    wget 
    vim
    firefox
    google-chrome
    pciutils
    gparted
    htop
    unrar
    unzip
    vscode
    zsh
    lm_sensors
    docker-compose
    usbutils
    pavucontrol
    home-manager
    libva
    xorg.xhost
    teamviewer
    droidcam
  ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
