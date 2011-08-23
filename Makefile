###############################################################################
# Makefile for the project gLogger
###############################################################################

## General Flags
PROJECT = gLogger
MCU = atmega88
TARGET = gLogger.elf
CC = avr-gcc

CPP = avr-g++

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -gdwarf-2 -std=gnu99 -DF_CPU=7372800UL -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS += -MD -MP -MT $(*F).o -MF dep/$(@F).d 

## Assembly specific flags
ASMFLAGS = $(COMMON)
ASMFLAGS += $(CFLAGS)
ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS +=  -Wl,-Map=gLogger.map


## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom -R .fuse -R .lock -R .signature

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0 --no-change-warnings


## Include Directories
INCLUDES = -I"./src" 

## Objects that must be built in order to link
OBJECTS = gLogger.o global.o gps.o nofs.o uart.o sdmmc.o spi.o 

## Objects explicitly added by the user
LINKONLYOBJECTS = 

## Build
all: $(TARGET) gLogger.hex gLogger.eep gLogger.lss size

## Compile
gLogger.o: ./src/gLogger.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

global.o: ./src/global.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

gps.o: ./src/modules/gps.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

nofs.o: ./src/modules/nofs.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

uart.o: ./src/protocols/uart.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

sdmmc.o: ./src/modules/sdmmc.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

spi.o: ./src/protocols/spi.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

##Link
$(TARGET): $(OBJECTS)
	 $(CC) $(LDFLAGS) $(OBJECTS) $(LINKONLYOBJECTS) $(LIBDIRS) $(LIBS) -o $(TARGET)

%.hex: $(TARGET)
	avr-objcopy -O ihex $(HEX_FLASH_FLAGS)  $< $@

%.eep: $(TARGET)
	-avr-objcopy $(HEX_EEPROM_FLAGS) -O ihex $< $@ || exit 0

%.lss: $(TARGET)
	avr-objdump -h -S $< > $@

size: ${TARGET}
	@echo
	@avr-size -C --mcu=${MCU} ${TARGET}

## Clean target
.PHONY: clean
clean:
	-rm -rf $(OBJECTS) gLogger.elf dep/* gLogger.hex gLogger.eep gLogger.lss gLogger.map


## Other dependencies
-include $(shell mkdir dep 2>/dev/null) $(wildcard dep/*)

