OUT ?= firmware
BUILD_DIR = build

SRCS = \
	gd32vf103v_eval.c \
	systick.c \
	main.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/system_gd32vf103.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_adc.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_crc.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_dma.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_exti.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_gpio.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_rcu.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_timer.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_bkp.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_dac.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_eclic.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_fmc.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_i2c.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_rtc.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_usart.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_can.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_dbg.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_exmc.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_fwdgt.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_pmu.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_spi.c \
	GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Source/gd32vf103_wwdgt.c \
	GD32VF103_Firmware_Library/RISCV/drivers/n200_func.c \
	GD32VF103_Firmware_Library/RISCV/env_Eclipse/init.c \
	GD32VF103_Firmware_Library/RISCV/env_Eclipse/handlers.c \
	GD32VF103_Firmware_Library/RISCV/env_Eclipse/your_printf.c \
	GD32VF103_Firmware_Library/RISCV/stubs/_exit.c \
	GD32VF103_Firmware_Library/RISCV/stubs/close.c \
	GD32VF103_Firmware_Library/RISCV/stubs/fstat.c \
	GD32VF103_Firmware_Library/RISCV/stubs/isatty.c \
	GD32VF103_Firmware_Library/RISCV/stubs/lseek.c \
	GD32VF103_Firmware_Library/RISCV/stubs/read.c \
	GD32VF103_Firmware_Library/RISCV/stubs/sbrk.c \
	GD32VF103_Firmware_Library/RISCV/stubs/write.c \
	GD32VF103_Firmware_Library/RISCV/stubs/write_hex.c

ASM_SRCS = \
	GD32VF103_Firmware_Library/RISCV/env_Eclipse/start.S \
	GD32VF103_Firmware_Library/RISCV/env_Eclipse/entry.S

OBJS = $(addprefix $(BUILD_DIR)/,$(notdir $(SRCS:.c=.o)))
vpath %.c $(sort $(dir $(SRCS)))

OBJS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SRCS:.S=.o)))
vpath %.S $(sort $(dir $(ASM_SRCS)))

LDSCRIPT = GD32VF103_Firmware_Library/RISCV/env_Eclipse/GD32VF103x6.lds

CFLAGS = -Os -Wall -march=rv32imac -mabi=ilp32 -mcmodel=medlow -fmessage-length=0 -fsigned-char -fdata-sections -ffunction-sections -fno-common -std=gnu11 -DGD32VF103V_EVAL -DUSE_STDPERIPH_DRIVER
LDFLAGS = -Wall -march=rv32imac -mabi=ilp32 -mcmodel=medlow -T $(LDSCRIPT) -Xlinker --gc-sections -nostartfiles #-nostdlib -specs=nano.specs
LIBS =

CC = riscv64-unknown-elf-gcc
CP = riscv64-unknown-elf-objcopy
AS = riscv64-unknown-elf-gcc -x assembler-with-cpp

INCDIRS = -I . \
	-I GD32VF103_Firmware_Library/GD32VF103_standard_peripheral \
	-I GD32VF103_Firmware_Library/GD32VF103_standard_peripheral/Include \
	-I GD32VF103_Firmware_Library/RISCV/drivers \
	-I GD32VF103_Firmware_Library/RISCV/stubs

all: $(BUILD_DIR) $(OUT)

$(OUT): $(OBJS)
	$(CC) $(LDFLAGS) $(LIBS) $^ -o $(BUILD_DIR)/$(OUT).elf
	$(CP) -O binary -S $(BUILD_DIR)/$(OUT).elf $(BUILD_DIR)/$(OUT).bin

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) $(INCDIRS) -c $< -o $@

$(BUILD_DIR)/%.o: %.S
	$(AS) $(CFLAGS) $(INCDIRS) -c $< -o $@

flash:
	dfu-util -d 28e9:0189 -a 0 --dfuse-address 0x08000000:leave -D $(BUILD_DIR)/$(OUT).bin

clean:
	rm -rf $(BUILD_DIR)
