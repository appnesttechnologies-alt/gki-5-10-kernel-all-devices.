# Templar Kernel GKI 5.10 - garnet

Custom kernel for Redmi Note 13 Pro 5G (garnet) on HyperOS/MIUI Android 14.
Based on Steambot12's Templar Kernel GKI 5.10 (android12-5.10, KMI gen 9).

```
TemplarKernel-GKI5.10-garnet.zip
```

## Features

- Vorpal CPUFreq Governor v2.0 (by Steambot12)
- ThinLTO (Full LTO necesitaba ~12GB RAM, con ThinLTO uso ~4GB)
- SCHED_PREFER_SILVER (los 4xA55 se usan mas que los A78, mejor bateria)
- TCP BBR como congestion control por defecto
- Kyber I/O scheduler
- CAKE network QoS
- ZPOOL (zswap backend)
- F2FS compression
- EROFS per-CPU kthreads (HIPRI)
- Sin limite de wakelocks (PM_WAKELOCKS_LIMIT=0)

## Requirements

- Ubuntu 22.04+ o cualquier distro con packages actualizados
- Clang/LLVM 16
- aarch64-linux-gnu- cross compiler
- flex, bison, libncurses-dev, libelf-dev, libssl-dev

```
sudo apt install clang-16 lld-16 llvm-16 gcc-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu flex bison libncurses-dev python3 \
    libelf-dev libssl-dev
```

## Build

```
cd templar-kernel-garnet

# Para garnet solo
./build-garnet.sh

# Para cualquier GKI 5.10 (public build)
./build-public.sh
```

El script build-garnet.sh aplica el fragment con VORPAL governor y las optimizaciones especificas. build-public.sh usa solo cambios seguros (ThinLTO, BBR, Kyber, CAKE, ZPOOL, F2FS compression, EROFS kthreads).

Output:
- `~/kernel-output/TemplarKernel-GKI5.10-garnet.zip` (garnet build)
- `~/kernel-output-public/TemplarKernel-GKI5.10-Public.zip` (public build)
- `Image` sin comprimir tambien se copia

## Flash

Recovery (OrangeFox / TWRP):
- Flash el zip directamente
- Con device check para garnet, no te dejara flashear en otro dispositivo

Fastboot:
```
fastboot flash boot boot.img
fastboot reboot
```

**Siempre haz backup de tu boot.img original.**

## AnyKernel3

El build descarga AnyKernel3 automaticamente a /tmp/anykernel3.
Usa el template de osm0sis con dump_boot + write_boot.
Si ya lo tienes en ~/anykernel3, cambia la ruta en el script.

## Notes

- GKI 2.0 compatible (KMI generation 9, android12-5.10)
- Tested on HyperOS Android 14 (garnet)
- Unlocked bootloader required
- Compatible con Magisk + KPatch-Next-Module (KPM)
- Con 16GB RAM o menos, ThinLTO es obligatorio para no petar en el link

## Credits

- [Steambot12](https://github.com/Steambot12) — Templar Kernel base, Vorpal CPUFreq Governor v2.0
- Google / AOSP — android12-5.10 GKI common kernel
- [osm0sis](https://github.com/osm0sis) — AnyKernel3
- @kantsel1 — KPatch-Next para KPM modules

```
SrMatdroid - 2026
```
