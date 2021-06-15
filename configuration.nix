
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  screamOverride = pkgs.scream.override { pulseSupport = true; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  
  nixpkgs.config.allowUnfree = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_5_12;
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    kernelModules = [ "v4l2loopback" ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1
    '';
    loader.grub = {
      useOSProber = true;
    };
    supportedFilesystems = [ "ntfs" ]; 
  };
  
  networking = {
    useDHCP = false;
    interfaces = {
      eno1.useDHCP = true;
      # wlp9s0.useDHCP = true;
    };
    firewall.allowedTCPPorts = [
      9999
      8080
      8000
    ];
  };

  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      layout = "us";
    };
    dbus.packages = [ pkgs.gnome.dconf-editor ];
    udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
    printing.enable = true;
    blueman.enable = true;
    plex = {
      enable = true;
      openFirewall = true;
    };
  };

  hardware = {
    opengl = {
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };
    pulseaudio.enable = true;
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemuOvmf = true;
    };
    docker = {
      enable = true;
      autoPrune.enable = true;
      logDriver = "json-file";
      extraOptions = "--log-opt max-size=10m --log-opt max-file=3";
    };
  };

  programs = {
    zsh.enable = true;
    steam.enable = true;
    adb.enable = true;
  };

  users = {
    mutableUsers = true;
    defaultUserShell = pkgs.zsh;
    users = {
      llelievr = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "docker" "dialout" "adbusers" "video" "plex" ];
      };
    };
  };
  nix.allowedUsers = [ "@wheel" ];

  sound = {
    enable = true;
    mediaKeys = {
      enable = true;
      volumeStep = "5%";
    };
  };

  time.timeZone = "Europe/Paris";

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 llelievr qemu-libvirtd -"
   # "f /dev/shm/scream 0660 llelievr qemu-libvirtd -"
  ];

  #systemd.user.services.scream-ivshmem = {
  #  enable = true;
  #  description = "Scream IVSHMEM";
  #  serviceConfig = {
  #    ExecStart = "${pkgs.scream-receivers}/bin/scream-ivshmem-pulse /dev/shm/scream";
  #    Restart = "always";
  #  };
  #  wantedBy = [ "multi-user.target" ];
  #  requires = [ "pulseaudio.service" ];
  #};

  # List packages installed in system profile. To search, run:
  # $ nix search wget·
  environment.systemPackages = with pkgs; [
    git
    gnome.gnome-tweak-tool
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
    screamOverride 
    spice_gtk
    home-manager
    libva
    xorg.xhost
  ];

  security.wrappers.spice-client-glib-usb-acl-helper.source = "${pkgs.spice_gtk}/bin/spice-client-glib-usb-acl-helper";

  systemd.nspawn."Archlinux" = {
    enable = true;
    wantedBy = [ "machines.target" ];
    requiredBy = [ "machines.target" ];
    execConfig = {
      Boot = true;
      Timezone = "Europe/Paris";
      Hostname = "nixos-Archlinux";
      SystemCallFilter = "modify_ldt";
    };
    filesConfig = {
      Bind = [ 
        "/tmp/.X11-unix"
        "/run/user/1000/pulse/native"
        "/dev/dri"
        "/dev/shm"
      ];
      Volatile = false;
    };
    networkConfig.VirtualEthernet = false;
  };

  systemd.packages = [
    (pkgs.runCommandNoCC "machines" {
      preferLocalBuild = true;
      allowSubstitutes = false;
    } ''
      mkdir -p $out/etc/systemd/system/
      ln -s /etc/systemd/system/systemd-nspawn@.service $out/etc/systemd/system/systemd-nspawn@Archlinux.service
    '')
  ];

  systemd.services."systemd-nspawn@".serviceConfig = {
    ### Vulkan support
    DeviceAllow = [
      "char-drm rwx"
      "/dev/dri/renderD128"
    ];
  };


  system.stateVersion = "21.05";
}

