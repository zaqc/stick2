CC = iverilog
FLAGS = -Wall -Winfloop -g2005-sv -DTESTMODE=1

TARGET = dscope

SRC = $(TARGET)_tb.v dscope_main.v frame_header.v dac_level.v spi_dac.v data_align.v control_param.v data_reader.v phy_channel.v adc_data.v time_slot.v pulse_channel.v clock_sync/clock_sync.v ch_mem_buf.v

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

