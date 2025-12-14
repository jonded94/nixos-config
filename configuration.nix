# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

let
  secrets = {
    sshKeys = import ./secrets/ssh-keys.nix;
  };
  powertop-master = pkgs.callPackage ./pkgs/powertop-master.nix { };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    ./disko.nix
  ];

  # Override powertop with our custom master branch version
  nixpkgs.overlays = [
    (self: super: {
      powertop = super.callPackage ./pkgs/powertop-master.nix { };
    })
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_testing;
    kernelParams = [
      "pcie_aspm=force"
      "pcie_aspm.policy=powersupersave"
      "pcie_port_pm=force"
      "intel_idle.max_cstate=10"
      "intel_pstate=passive"
    ];

    # Enable mdadm support
    swraid = {
      enable = true;
      mdadmConf = "PROGRAM ${pkgs.coreutils}/bin/true";
    };

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
  };

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
    htop
    git
    pciutils # provides lspci
    nvme-cli # provides nvme
    usbutils # provides lsusb
    powertop # powertop points to our custom master branch version via overlay
  ];

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [ secrets.sshKeys.root ];
    };
  };

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:81:00.0", ATTR{remove}="1"
      ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:80:1c.0", ATTR{remove}="1"
    '';
    k3s = {
      enable = true;
      role = "server";
      manifests = {
        fleet-gitrepo = {
          content = {
            apiVersion = "fleet.cattle.io/v1alpha1";
            kind = "GitRepo";
            metadata = {
              name = "nixos-config";
              namespace = "fleet-local";
            };
            spec = {
              repo = "https://github.com/jonded94/nixos-config.git";
              branch = "main";
              paths = [ "charts/fleet-root" ];
              pollingInterval = "1m0s";
              correctDrift = {
                enabled = true;
              };
            };
          };
        };
      };
      autoDeployCharts = {
        fleet-crd = {
          enable = true;
          name = "fleet-crd";
          version = "0.14.0";
          repo = "https://rancher.github.io/fleet-helm-charts/";
          targetNamespace = "cattle-fleet-system";
          createNamespace = true;
          hash = "sha256-CWEkR1e9TOao3CLje4TFX57WNuFiZXCkDxq5i+he2gY=";
        };
        fleet = {
          enable = true;
          name = "fleet";
          version = "0.14.0";
          repo = "https://rancher.github.io/fleet-helm-charts/";
          targetNamespace = "cattle-fleet-system";
          createNamespace = true;
          hash = "sha256-BsdFgm1ypCfsBwlqo0C8e+vyHqL09QgxqDEPepR8oEY=";
        };
      };
    };
  };

  # Power Management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil"; # EAS requires schedutil governor
    powertop.enable = true;
  };

  hardware = {
    intel-gpu-tools.enable = true;
    enableRedistributableFirmware = true;
  };

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
