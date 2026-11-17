# Yuri-Sherbet: Raspberry Pi 4 mainline kernel

Sherbet uses `features/raspberry-pi-4-mainline.nix` to retain nixos-hardware's
board/firmware support while selecting the unmodified `pkgs.linuxPackages`
AArch64 kernel. At the current lock, Linux 6.18.55 and its `modules` and `dev`
outputs are available from `https://cache.nixos.org`.

## Configuration

- U-Boot/extlinux loads the generation's explicit
  `broadcom/bcm2711-rpi-4-b.dtb`, including the build-time overlays.
- `/boot` stays on the root filesystem; the existing firmware partition is
  mounted at `/boot/firmware`.
- Vendor FKMS, Bluetooth pin, and dtmerge overrides are disabled. The mainline
  device tree already describes full KMS and onboard Bluetooth.
- The I²C overlay reserves `/dev/i2c-1` for GPIO2/3, as expected by the Argon
  daemon and its shutdown helper.
- The Argon overlay retains the fan curve and configures the GPIO4 button.
  The service discovers the `pinctrl-bcm2711` GPIO controller with `gpiodetect`
  and the `cpu-thermal` temperature sensor at startup. Its small userspace
  patch reads those discovered paths rather than assuming `gpiochip0`,
  `hwmon0`, or the vendor `/dev/vcio` interface.
- Wi-Fi is enabled through NetworkManager, including clearing the old software
  radio-disable state. Connection credentials are configured in NetworkManager.
- Serial, Wi-Fi, Bluetooth, thermal, Ethernet, and I²C modules are preloaded
  before kernel module loading is locked. CP210x and CDC ACM devices can be
  attached later.
- `yuri` has `gpio` and `dialout` access; I²C access for Argon remains through
  its root service. General GPIO tooling uses `libgpiod`.

## Verify after updating the lock

Use `path:.` when new modules have not yet been added to Git, so they are
included in the flake source.

```sh
nix eval --raw --no-write-lock-file \
  path:.#nixosConfigurations.Yuri-Sherbet.config.boot.kernelPackages.kernel.drvPath

nix path-info --store https://cache.nixos.org \
  "$(nix eval --raw --no-write-lock-file path:.#nixosConfigurations.Yuri-Sherbet.config.boot.kernelPackages.kernel.outPath)" \
  "$(nix eval --raw --no-write-lock-file path:.#nixosConfigurations.Yuri-Sherbet.config.boot.kernelPackages.kernel.modules.outPath)" \
  "$(nix eval --raw --no-write-lock-file path:.#nixosConfigurations.Yuri-Sherbet.config.boot.kernelPackages.kernel.dev.outPath)"

nix build --dry-run --no-link --no-write-lock-file \
  path:.#nixosConfigurations.Yuri-Sherbet.config.system.build.toplevel
```

The exact kernel derivation should remain substitutable. Device-tree overlays,
module-tree assembly, module shrinking, and initrd generation are expected small
builds. Changing kernel patches/configuration or cross-compiling can change the
derivation and lose the official-cache match.

## First physical boot

Retain a known-working generation and recoverable boot media. After a
user-managed deployment/reboot, check on the Pi:

```sh
uname -r
systemctl status argononed enable-wifi-on-boot NetworkManager
readlink -f /run/argononed/gpiochip /run/argononed/cpu-temperature
gpiodetect
gpioinfo -c /run/argononed/gpiochip
i2cdetect -F 1
nmcli device status
lsusb -t
ls -l /dev/serial/by-id /dev/serial/by-path
```

Verify fan response and CPU temperature, then the case button and clean
shutdown behavior. Test Wi-Fi association/DHCP and reconnect after reboot.
Plug/unplug a CP210x adapter after boot and verify serial communication; also
check the existing CDC ACM radio and OpenThread connectivity.

The OTBR configuration currently expects Ethernet `end0` and the USB radio
path recorded in `hosts/sherbet.nix`. Confirm both on the physical Pi and
update those settings if mainline exposes different names. QEMU builds do not
verify the Pi's boot firmware, attached devices, or physical pin behavior.
