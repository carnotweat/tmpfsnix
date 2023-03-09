# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
    nixosRecentCommitTarball =
    builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/46ee37ca1d9cd3bb18633b4104ef21d9035aac89.tar.gz"; # 2021-09-18
      # to find this, click on "commits" at https://github.com/NixOS/nixpkgs and then follow nose to get e.g. https://github.com/NixOS/nixpkgs/commit/0e575a459e4c3a96264e7a10373ed738ec1d708f, and then change "commit" to "archive" and add ".tar.gz"
    };
# custom pinentry flavor

  cfg = config.programs.gnupg;

  xserverCfg = config.services.xserver;

  defaultPinentryFlavor =
    if xserverCfg.desktopManager.lxqt.enable
    || xserverCfg.desktopManager.plasma5.enable then
      "qt"
    else if xserverCfg.desktopManager.xfce.enable then
      "gtk2"
    else if xserverCfg.enable || config.programs.sway.enable then
      "gnome3"
    else
      null;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
# define recent commit 
    nixpkgs.config = {
      packageOverrides = pkgs: {
        nixosRecentCommit = import nixosRecentCommitTarball {
          config = config.nixpkgs.config;
        };
      };
    };
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
#  boot.loader.grub.enable = true;
#  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.extraHosts =
  ''
    185.199.108.133 raw.githubusercontent.com
  '';
    # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    #keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };


    
    services.xserver = {
      enable = true;
      libinput.enable = true;
      windowManager.fluxbox.enable = true;
    #   windowManager.xmonad.enableContribAndExtras = true;
    #   windowManager.xmonad.extraPackages = haskellPackages: [
    #   haskellPackages.dbus
    #   haskellPackages.List
    #   haskellPackages.monad-logger
    # ];
      displayManager.lightdm.enable = true;
      displayManager.lightdm.autoLogin = { enable = true; user = "xameer"; };
      desktopManager.default = "none+fluxbox";
     
    };
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
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
  users.mutableUsers = false;
  users.users.root.initialPassword = "password";
  users.users.xameer = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
  };
  
  
    environment.etc."machine-id".source
    = "/nix/persist/etc/machine-id";
  # environment.etc."ssh/ssh_host_rsa_key".source
  #   = "/nix/persist/etc/ssh/ssh_host_rsa_key";
  # environment.etc."ssh/ssh_host_rsa_key.pub".source
  #   = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
  environment.etc."ssh/ssh_host_ed25519_key".source
    = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
  environment.etc."ssh/ssh_host_ed25519_key.pub".source
    = "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  wget
  pass
  emacs
  git
  git-crypt
  #st
  #alacritty
  konsole
  foot
  nixosRecentCommit.etcher
  pinentry-curses 
  gnome.gnome-disk-utility

  ];
  services.pcscd.enable = true;
  programs.gnupg = {
      agent = {
        enable = true;
        enableExtraSocket = true;
        pinentryFlavor = "curses";
	enableSSHSupport = true;
      };
    };
  # nix-settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

