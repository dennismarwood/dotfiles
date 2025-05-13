# This file is machine-specific (office nixos desktop) and maintained in the dotfiles/hardware_configs/ repository.
# Do not overwrite unless you're re-provisioning this machine.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" "sg" ]; # MakeMKV needs the scsi generic devices
  boot.extraModulePackages = [ ];
  boot.swraid.enable = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b77c3aa7-3c72-46f5-9478-fd002167d9de";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DA33-82B6";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/cbeccedc-422f-4f8d-a918-3b4ca710b82c"; }
    ];

  ####################################################################################################################
  #  RAID 1 Mounting and configure                                                                                   #
  ####################################################################################################################

  # mount the raid disks
  fileSystems."/mnt/raid" = {
    device = "/dev/disk/by-uuid/79155689-315b-4bed-8b94-de3c176dfd4e";
    fsType = "ext4";
    options = [ "nofail" ]; #Boot even if mount fails
  };
  fileSystems."/mnt/data" = {
   device = "/dev/disk/by-uuid/daddf5af-2e48-41f7-a559-9879586ec75f";
   fsType = "ext4";
   options = [ "nofail" ]; #Boot even if mount fails
  };

  # Override mdmonitor to log to syslog instead of emailing or alerting
  systemd.services."mdmonitor".environment = {
    MDADM_MONITOR_ARGS = "--scan --syslog";
  };

  # Have mdadm check the disks are in sync monthly
  #  systemd.timers."mdadm-checkarray" = {
  #    wantedBy = [ "timers.target" ];
  #    timerConfig = {
  #      OnBootSec = "10min"; #10 minutes after boot
  #      OnUnitActiveSec = "1month"; #Re-run only after a succesful check
  #      Persistent = true;
  #    };
  #  };

  #  systemd.services."mdadm-checkarray" = {
  #    script = ''
  #      /run/current-system/sw/bin/mdadm --check /dev/md127
  #    '';
  #    serviceConfig = {
  #      Type = "oneshot";
  #      Nice = 19;
  #      IOSchedulingClass = "idle";
  #    };
  #    after = [ "local-fs.target" ];
  #     wants = [ "local-fs.target" ];
  #  };

  # Just going to do manual checks for now. Waiting on merge of
  # https://github.com/NixOS/nixpkgs/pull/204713
  # https://github.com/NixOS/nixpkgs/pull/373222


  ####################################################################################################################
  ####################################################################################################################
  ####################################################################################################################


  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
