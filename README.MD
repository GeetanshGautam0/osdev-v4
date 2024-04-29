# Operating System Development

![A screenshot of the OS](https://raw.githubusercontent.com/GeetanshGautam0/osdev-v4/master/lts_ss.png)

## The Basics

### Building and Booting

*Note: the OS has not been tested on real hardware.*

The following tools are required to build the OS:
* WATCOM C/C++ compiler (to build 16-bit C/C++ files)
* Make
* QEMU (for running the OS)
* Bochs (for debugging the OS)
* GCC/G++ (to build 32-bit C/C++ files)

To build the OS, ```cd``` to the root directory of the repo, then, run:
```sh
make all
```

Once built, the OS can be booted as follows:
```sh
make all
```

To debug the OS, run:
```sh
make all
```

As with all make commands, the targets can be combined:
```sh
make all run
# or,
make all debug
```

### Structuring 
* The operating system consists of three distinct sections:

    1. Bootloader 1
    2. Bootloader 2
    3. OS Kernel

* The first stage of the bootloader (bootloader 1) is a zero-padded, one-sector bootloader that:
    * Initializes the disk; 
    * Loads the second stage of the bootloader; and,
    * Jumps to the second stage of the bootloader.


* The second stage of the bootloader (bootloader 2) serves to:
    * Jump to a high-level language (16-BIT C/C++)
    * Initialize FAT12 disk
    * Load the kernel from the disk into memory.
    * (**Yet to be implemented**) Jump to 32-bit protected mode.
    * (**Yet to be implemented**) Jump to the kernel

* The kernel is the core of the operating system.

