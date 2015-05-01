`timescale 1ns/1ns
module tb ();

  parameter CLK_HALF_PER = 2.5;

  parameter CLK2_HALF_PER = 3.5;

  // Declarations
  reg wclk;
  reg wrst_n;
  reg fifo_push, fifo_pop;
  reg [7:0] fifo_in;

  reg rclk;
  reg rrst_n;

  wire [7:0] fifo_out;

  integer iindx;

  // Initial conditions
  initial begin
    wclk      = 0;
    wrst_n    = 1;
    rclk      = 0;
    rrst_n    = 1;
  end

  // Clocks and Resets
  always #(CLK_HALF_PER)  wclk = ~wclk;
  always #(CLK2_HALF_PER) rclk = ~rclk;

  // DUT
  
  initial begin
    #10;
    wrst_n  = 1'b0;
    rrst_n  = 1'b0;
    #100;
    wrst_n  = 1'b1;
    rrst_n  = 1'b1;
    #1000;
    $stop;
  end

endmodule

