ASM      	:= nasm
CC       	:= gcc
ECHO     	:= echo
RM       	:= rm
EMU   	 	:= qemu-system-x86_64
DD       	:= dd
TOUCH 		:= touch

CFLAGS   	:= -ffreestanding -mno-red-zone -std=gnu99 -m32 -mcmodel=kernel -nostdlib
CFLAGS		+= -Wall -Werror -Wextra -Wparentheses -Wmissing-declarations -Wunreachable-code -Wunused 
CFLAGS		+= -Wmissing-field-initializers -Wmissing-prototypes -Wpointer-arith -Wswitch-enum
CFLAGS		+= -Wredundant-decls -Wshadow -Wstrict-prototypes -Wswitch-default -Wuninitialized
ASMFLAGS 	:=
BOOTFLAG 	:= -fbin -g

ISO   		:= img/SOS.iso
SRC   		:= src
DUMMY 		:= img/load.flp

BUILD_DIR    := build
#BOOT_FILES  := $(wildcard boot/*.S)
BOOT_FILES  := $(wildcard boot/*.S)
SYM_FILE    := build/load.elf
BOOT_OBJS   := $(patsubst boot/%.S,build/%.bin,$(BOOT_FILES))
IMG_DIR 	:= img

ifeq ($(DEBUG),0)
	CFLAGS += -O3 -flto
else
	CFLAGS += -fsanitize=undefined -Og -g -DDEBUG -fstack-protector
endif 

.PHONY: all clean qemu_run

all : $(BOOT_OBJS)

qemu_run : $(DUMMY) 
	@$(EMU) -fda $(DUMMY)

qemu_debug : $(DUMMY) $(SYM_FILE)
	@gdb -x .gdbinit -q

$(BOOT_OBJS) : $(BOOT_FILES) $(BUILD_DIR)/
	$(ASM) $(BOOTFLAG) $(ASM_FLAGS) $(BOOT_FILES) -o $(BOOT_OBJS)

$(DUMMY) : img/%.flp : build/%.bin $(IMG_DIR)/
	@dd status=noxfer conv=notrunc if=$< of=$@

$(SYM_FILE) : %.elf : %.bin
	objcopy -Ibinary -Oelf32-little $< $@


$(BUILD_DIR)/%.o : $(BUILD_DIR)/%.elf $(BUILD_DIR)/
	$(CC) $(CFLAGS) $< -o $@ -T linker.ld

$(BUILD_DIR)/ :
	@mkdir $(BUILD_DIR)

$(IMG_DIR)/ :
	@mkdir $(IMG_DIR)

clean :
	@$(RM) -rf build
	@$(RM) -rf img
	@$(RM) -rf sym