# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/ebc0e6a0-c80c-444e-aa76-8b898fd531ae";
    fsType = "ext4";
  };

  fileSystems."/home" = {
     device = "/dev/disk/by-uuid/a078a3c7-3da2-40f5-95e5-a2798050b172";
     fsType = "ext4";
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/7E93-B77C";
    fsType = "vfat";
  };

  swapDevices = [
	#	{ device = "/dev/disk/by-uuid/7efa7eb4-d72a-4919-9ce4-e49f80e21e2c"; }
];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelParams = [ "amd_iommu=on"  "pcie_acs_override=downstream,multifunction" ];
    blacklistedKernelModules = [ "nvidia" "nouveau" ];
    kernelModules = [ "kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    extraModulePackages = [ ];
    loader = {
      systemd-boot.enable = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
    #nvidia card isolation
    extraModprobeConfig = ''
     options kvm ignore_msrs=1     
     options vfio-pci ids=10de:1c82,10de:0fb9
    '';
    #ACS patch to fix my crappy IOMMU groups
    kernelPatches = [
      {
        name = "add-acs-overrides";
        patch = pkgs.fetchurl {
          name = "add-acs-overrides.patch";
          url = "https://gitlab.com/Queuecumber/linux-acs-override/raw/master/workspaces/5.10.4/acso.patch";
          sha256 = "147fbdb1b7e30f323175f5d6701fc1fd0cfddc9fdd86275086284dc0f6754d8e";
        };
      }
    ];
  };

  # networking.interfaces.eno1.useDHCP = true;
  # networking.interfaces.br0.useDHCP = true;
  # networking.bridges = {
  #   "br0" = {
  #     interfaces = [ "eno1" ];
  #   };
  # };
  # networking.dhcpcd.denyInterfaces = [ "macvtap0@*" ];

  hardware = {
    firmware = [
      # Bluetooth patch, solves random disconnect
      (pkgs.runCommand "iwlwifi" {} ''
        mkdir -p $out/lib/firmware
        cp ${./iwlwifi-cc-a0-46.ucode} $out/lib/firmware/iwlwifi-cc-a0-46.ucode
      '')
    ];
    bluetooth.enable = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

}
