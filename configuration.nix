# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # IP config

  networking.interfaces.enp5s0.ipv4.addresses  = [ {
    address = "192.168.1.5";
    prefixLength = 24;
  } ];

  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "9.9.9.9" "1.1.1.1"];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "es_ES.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "es";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "es";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.daat = {
    isNormalUser = true;
    description = "daat";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    createHome = true; 
    linger = true; # Keep user services running after logout
  };

  # GNOME UI

  # services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;

  # To disable installing GNOME's suite of applications
  # and only be left with GNOME shell.
  # services.gnome.core-apps.enable = true;
  # services.gnome.core-developer-tools.enable = false;
  # services.gnome.games.enable = false;
  # environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The>
  #  wget
     caddy nodejs_24 git pnpm openssl pocketbase
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Pocketbase
  systemd.services.pocketbase = {
    script = "${pkgs.pocketbase}/bin/pocketbase serve --encryptionEnv=PB_ENCRYPTION_KEY --dir /home/daat/pb_data";
    serviceConfig = {
      LimitNOFILE = 4096;
      EnvironmentFile = ["/home/daat/pocketbase.env"];
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.caddy = {
    enable = true;
    virtualHosts = {
      "santeleco.uvigo.es" = {
        extraConfig = ''
          request_body {
                  max_size 10MB
          }
          
          handle /api/* {
            reverse_proxy 127.0.0.1:8090 {
                transport http {
                    read_timeout 360s
                }
            }
          }
          
          handle {
            reverse_proxy :4321
          }
        '';
      };
      "daat.uvigo.es" = {
        extraConfig = ''
          root /var/www/html/daat/dist
          file_server
        '';
      };
    };
  };

  systemd.user.services.pull_reservassanteleco = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ]; # Start at boot
    description = "Pull reservas santeleco";
    startAt = "*-*-* 00:00:00";
    serviceConfig = {
      RemainAfterExit = true; # Prevents the service from automatically starting on rebuild. See https://discourse.nixos.org/t/how-to-prevent-custom-systemd-service-from-restarting-on-nixos-rebuild-switch/43431
      Type = "simple";
      ExecStart = "${pkgs.git}/bin/git pull";
      WorkingDirectory = ''/home/daat/WebEntradasSanTeleco/'';
    };
    unitConfig.ConditionUser = "daat"; # Only enable service for "daat"
  }
  
  systemd.user.services.reservassanteleco = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ]; # Start at boot
    description = "Web reservas santeleco";
    startAt = "*-*-* 00:01:00";
    environment = {
      HOST = "127.0.0.1";
      PORT = "4321";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.nodejs_24}/bin/node ./dist/server/entry.mjs";
      WorkingDirectory = ''/home/daat/WebEntradasSanTeleco/'';
    };
    unitConfig.ConditionUser = "daat"; # Only enable service for "daat"
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 22];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
