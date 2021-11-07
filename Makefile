CC = iverilog
FLAGS = -Wall -Winfloop -g2005-sv -DTESTMODE=1

TARGET = stick

SRC = $(TARGET)_tb.v stick_main.v
EDIT_SRC := $(SRC)

PROJECT_ROOT = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

SRC += $(wildcard $(PROJECT_ROOT)dscope/*.v)
SRC += $(wildcard $(PROJECT_ROOT)eth/*.v)

SRC := $(patsubst $(PROJECT_ROOT)eth/send_frame_tb.v, , $(SRC))
SRC := $(patsubst $(PROJECT_ROOT)eth/eth_tx_fifo.v, , $(SRC))
SRC := $(patsubst $(PROJECT_ROOT)dscope/dscope_tb.v, , $(SRC))

INCLIDE_PATH = $(PROJECT_ROOT)eth/

$(TARGET) : $(SRC) Makefile
	$(CC) $(FLAGS) -I $(INCLIDE_PATH) -o $(TARGET) $(SRC)
	vvp $(TARGET)
	gtkwave dumpfile_$(TARGET).vcd cfg_$(TARGET).gtkw
	rm -f $(TARGET)

wave:
	gtkwave dumpfile_$(TARGET).vcd cfg_$(TARGET).gtkw
	
edit:
	gedit -s $(EDIT_SRC) Makefile desc.txt &
	
clean:
	rm -f $(TARGET)

