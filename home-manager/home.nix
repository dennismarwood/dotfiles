{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dennis";
  home.homeDirectory = "/home/dennis";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    brave
    btop #very nice top alternative
    pkgs.cargo         # Rust Package manager
    cdrtools # general disc burning tools
    certbot
    #dvd+rw-tools # for DVD burning
    discord
    dmidecode
    docker-compose
    drawio
    epson-escpr
    gcc #C Compiler
    git
    gnome-boxes
    gparted
    gutenprint
    #htop #cpu focused top alternative
    #iftop #network device traffic monitor
    iotop #disk drive io usage monitor. additional sysdig and csysdig for more indepth
    libaacs
    libbdplus
    libbluray
    #libburn # alternative burning backend
    libreoffice
    makemkv
    #nvtop #GPU monitoring for amd intel nvidia apple. See also radeontop nvtop
    pciutils
    pkg-config #Used by some rust crates to build c scripts
    (pkgs.python3.withPackages (ps: with ps; [
      google-api-python-client
      google-auth
      google-auth-oauthlib
      google-auth-httplib2
    ]))
    qalculate-gtk
    qdirstat
    #rclone
    realvnc-vnc-viewer
    rustc         # Rust compiler
    rustdesk
    s-tui #Stress test new system
    simple-scan
    stress
    smartmontools
    spotify
    tailscale #The CLI, not the daemon (that is in configuration.nix)
    udftools # for UDF file systems (common on DVDs/Blu-ray)
    virt-manager
    vlc
    vscode
    wget
    xfce.thunar-archive-plugin
    xarchiver

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Optional: declarative config for supported programs
  programs.bash = {
    enable = true;
  };

  programs.git = {
    enable = true;

    userName = "Dennis Marwood test";
    userEmail = "DennisMarwood@gmail.com";
   # aliases = {
      #co = "checkout";
      #br = "branch";
      #ci = "commit";
      #st = "status";
  #};

  #extraConfig = {
    #init.defaultBranch = "main";
    #pull.rebase = true;
  #};

  };


  programs.ssh = {
    enable = true; # start the ssh-agent
    addKeysToAgent = "yes";

    matchBlocks = {
      "officepi" = {
        hostname = "192.168.2.10";
        user = "pi-office";
        port = 22;
        localForwards = [
          {
            # Format: bindAddress = "local-port remote-host:remote-port"
            bind.address = "127.0.0.1";   # Just the IP or hostname
            bind.port = 5900;             # Local port to bind
            host.address = "localhost";          # Remote destination host
            host.port = 5900;                 # Remote destination port
          }
        ];
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/cm-%r@%h:%p";
          ControlPersist = "10m";
        };
      };
    };

    # the next line will effectively include raw SSH config text in ~/.ssh/config
    extraConfig = ''
      IdentityFile ~/.ssh/id_ed25519
    '';
  };

  programs.vim.enable = true;

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      eamodio.gitlens
      jnoortheen.nix-ide
      ms-vscode-remote.remote-ssh
      ms-azuretools.vscode-docker
      #ms-vscode.vscode-container-tools
      tailscale.vscode-tailscale
    ];
  };


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # These files are generated in /nix/store and then symlinked into ~ (home)
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dennis/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # run a script
  # this one will set everything in ~/.secrets to be readable only by me
  home.activation.fixSecretPermissions = lib.hm.dag.entryAfter ["writeBoundary"] ''
    find $HOME/.secret -type f -exec chmod 600 {} +
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
