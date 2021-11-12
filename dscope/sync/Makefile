CC = iverilog
FLAGS = -Wall -Winfloop -g2005-sv -DTESTMODE=1

TARGET = sync

SRC = $(TARGET)_tb.v synchronizer.v ext_sync.v

$(TARGET) : $(SRC) Makefile
	$(CC) $(FLAGS) -o $(TARGET) $(SRC)
	vvp $(TARGET)
	gtkwave dumpfile_$(TARGET).vcd cfg_$(TARGET).gtkw
	rm -f $(TARGET)

wave:
	gtkwave dumpfile_$(TARGET).vcd cfg_$(TARGET).gtkw
	
edit:
	gedit -s $(SRC) Makefile desc.txt &
	
clean:
	rm -f $(TARGET)

