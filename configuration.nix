# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# Note: This configuration.nix is machine-independent.
# Hardware-specific options (RAID, fileSystems, CPU modules, etc.) live in:
# # /etc/nixos/hardware-configuration.nix → symlinked from ./hardware_configs/<machine>.nix

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  services.udisks2.enable = true; # automount optical drive

  nix.settings.experimental-features = [ "nix-command" ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.cockpit = {
    enable = true;
    port = 9090;
    settings = {
      WebService = {
        AllowUnencrypted = true;
      };
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dennis = {
    isNormalUser = true;
    description = "Dennis";
    extraGroups = [ "networkmanager" "wheel" "docker" "cdrom" ];
    linger = true; #User services (such as rootless docker) can run after logout or before login
  };

  #security.unprivilegedUsernsClone = true; #Major security hole (recommended by chatgpt)

  # Install firefox.
  #programs.firefox.enable = true;
  

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #atop #Performace checking tool for what could be slowing down a system
  environment.systemPackages = with pkgs; [
    cockpit
    mdadm
    vim 
  ];

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

#  systemd.user.services.docker = {
#    description = "Rootless Docker Daemon";
#    wantedBy = [ "multi-user.target" ]; # start this service at boot
#    serviceConfig = {
#      ExecStart = "${pkgs.docker}/bin/dockerd-rootless.sh";
#      Restart = "always";
#      Environment = [
#        "PATH=${pkgs.docker}/bin:/run/wrappers/bin:/usr/bin:/bin"
#        "DOCKER_HOST=unix:///run/user/1000/docker.sock"
#      ];
#    };
#  };

  # adding a line to try and have the mdadm service start automatically
  #boot.initrd.mdadm.enable = true;
  #services.mdadm = {
    #enable = true;
  #};
  #services.mdadm.enable = true;

  # trying to mount the raid disks
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
