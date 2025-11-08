# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
      ./disko.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Enable mdadm support
    swraid.enable = true;

    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = false;
      # Mirror EFI bootloader to both ESP partitions
      mirroredBoots = [
        {
          devices = [ "nodev" ];
          path = "/boot";
          efiSysMountPoint = "/boot/efi";
        }
        {
          devices = [ "nodev" ];
          path = "/boot";
          efiSysMountPoint = "/boot/efi-fallback";
        }
      ];
    };

    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "jonas-nixos";
    networkmanager.enable = true;
  }

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  console = {
  #   font = "Lat2-Terminus16";
      keyMap = "de";
  #   useXkbConfig = true; # use xkb.options in tty.
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
      git
  ];

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "yes";
    }
    gitea = {
      enable = true;
    };
  };

  # Power Management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  hardware = {
    intel-gpu-tools.enable = true;
    enableRedistributableFirmware = true;
  }

  nixpkgs.config.allowUnfree = true;

  networking.firewall.enable = false;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
