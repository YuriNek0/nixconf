{ inputs, ... }:
{
  flake.modules.features.raspberry-pi-4-mainline =
    { pkgs, ... }:
    {
      imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];

      # Keep the stock AArch64 derivation substitutable from cache.nixos.org.
      # I2C/GPIO configuration belongs in the device tree, not a kernel override.
      boot.kernelPackages = pkgs.linuxPackages;
      boot.loader.generic-extlinux-compatible.useGenerationDeviceTree = true;

      # Mainline's DT already describes Bluetooth and full KMS. These profile
      # options add overlays that depend on Raspberry Pi vendor-only symbols.
      hardware.raspberry-pi."4" = {
        bluetooth.enable = false;
        fkms-3d.enable = false;
        apply-overlays-dtmerge.enable = false;
      };

      hardware.deviceTree = {
        filter = "bcm2711-rpi-4-b.dtb";
        name = "broadcom/bcm2711-rpi-4-b.dtb";
        overlays = [
          {
            name = "rpi4-mainline-i2c1";
            dtsText = ''
              /dts-v1/;
              /plugin/;
              / {
                compatible = "raspberrypi,4-model-b";
                fragment@0 {
                  target-path = "/aliases";
                  __overlay__ {
                    // Mainline has no I2C aliases. Reserve bus 1 for Argon ONE.
                    i2c1 = "/soc/i2c@7e804000";
                  };
                };
                fragment@1 {
                  target = <&i2c1>;
                  __overlay__ {
                    status = "okay";
                    pinctrl-names = "default";
                    pinctrl-0 = <&i2c1_gpio2>;
                    clock-frequency = <100000>;
                  };
                };
              };
            '';
          }
        ];
      };

      # Preload drivers needed after security.lockKernelModules takes effect,
      # including serial adapters that may only be plugged in later.
      boot.kernelModules = [
        "i2c_bcm2835"
        "bcm2711_thermal"
        "genet"
        "brcmfmac"
        "brcmfmac_cyw"
        "brcmfmac_wcc"
        "hci_uart"
        "cp210x"
        "cdc_acm"
      ];

      hardware.i2c.enable = true;
      environment.systemPackages = [ pkgs.libgpiod ];
      users.groups.gpio = { };
      services.udev.extraRules = ''
        SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
      '';
    };
}
