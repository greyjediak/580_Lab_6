## Project Overview
This project contains a UART datapath with a parameterized baud rate generator

## File Hierarchy
src/baud_rate_generator     // baud tick generator
src/uart_frame_shift        //Frame/shift register for UART controller
src/uart_tx_controller      //controller for transmissions, shifting, and outputs.
src/uart_tx                 // datapath for UART transmitter, instantiates baud tick generator, frame/shift register, and controller.
src/lab6_top                // top level wrapper for hardware implementation
src/ext_write_interface     // interface to send write enable signals to the fifo
src/fifo                    // fifo module to interface with UART transmitter
src/ext_write_inteface      // top level write enables
src/fifo_uart_interface     // interface for the fifo -> uart controller

## AI Disclosure and Overview
No AI was used to generate the lab report, figures, README, or code solutions.