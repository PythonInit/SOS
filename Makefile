ASM      	:= nasm
CC       	:= gcc
ECHO     	:= echo
RM       	:= rm
EMU   	 	:= qemu-system-x86_64
DD       	:= dd
TOUCH 		:= touch

CFLAGS   	:= -ffreestanding -mno-red-zone -std=gnu99 -m64 -nostdlib
CFLAGS		+= -Wall -Werror -Wextra -Wparentheses -Wmissing-declarations -Wunreachable-code -Wunused 
CFLAGS		+= -Wmissing-field-initializers -Wmissing-prototypes -Wswitch-enum
CFLAGS		+= -Wredundant-decls -Wshadow -Wswitch-default -Wuninitialized
CFLAGS      += -fstrength-reduce -fomit-frame-pointer -finline-functions -fno-builtin -fno-pie
ASMFLAGS 	:=
BOOTFLAG 	:= -felf64 -g

SRC   		:= src

BOOT_FILE   := kernel/boot.S
MAIN_FILE   := kernel/kmain.c
LIBK_FILES  := $(wildcard libk/*.c) 
DEP_FILES   := $(wildcard build/*.d)

AOUT_DIR    := aout
KERN_DIR    := kernel 
BUILD_DIR   := build

AOUT_TACOS  := aout/boot.o
AOUT_MAIN   := aout/kmain.o
LIBK_OBJS   := $(patsubst libk/%.c, build/%.o, $(LIBK_FILES))

KERN_BIN   := tacoOS.bin

.PHONY: all clean qemu_run

all : $(KERN_BIN)

qemu_run : $(KERN_BIN)
	$(EMU) -kernel $(KERN_BIN)

clean :
	@$(RM) -rf $(AOUT_DIR)
	@$(RM) -rf $(BUILD_DIR)
	@$(RM) -f $(KERN_BIN)
	

$(KERN_BIN) : $(AOUT_TACOS) $(AOUT_MAIN) $(KERN_DIR)/
	ld -T linker.ld -o $@ $(AOUT_TACOS) $(AOUT_MAIN) -melf_x86_64

$(AOUT_TACOS) : $(BOOT_FILE) $(AOUT_DIR)/
	$(ASM) $(BOOTFLAG) -o $@ $(BOOT_FILE) 

$(LIBK_OBJS) : build/%.o : libk/%.c $(BUILD_DIR)/
	$(CC) $(CFLAGS) -MMD -I./include $< -c -o $@

$(AOUT_MAIN) : $(MAIN_FILE) $(AOUT_DIR)/
	$(CC) $(CFLAGS) -I./include -c -o $@ $<

$(AOUT_DIR)/ :
	@mkdir $(AOUT_DIR)

$(KERN_DIR)/ :
	@mkdir $(KERN_DIR)

$(BUILD_DIR)/ :
	@mkdir $(BUILD_DIR)

-include $(DEP_FILES)