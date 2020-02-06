add-symbol-file build/load.elf 0x7c00
target remote | qemu-system-x86_64 -S -fda img/load.flp -gdb stdio