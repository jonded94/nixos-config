{
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-T-FORCE_TM8FFE001T_TPBF2401120050104232";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "32M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
              };
            };
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "raid1";
              };
            };
          };
        };
      };
      disk2 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-T-FORCE_TM8FFE001T_TPBF2503250100201600";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "32M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi-fallback";
              };
            };
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "raid1";
              };
            };
          };
        };
      };
    };
    mdadm = {
      raid1 = {
        type = "mdadm";
        level = 1;
        content = {
          type = "gpt";
          partitions = {
            primary = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
