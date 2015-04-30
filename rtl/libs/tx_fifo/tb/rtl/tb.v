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
    fifo_push = 0;
    fifo_pop  = 0;
  end

  // Clocks and Resets
  always #(CLK_HALF_PER)  wclk = ~wclk;
  always #(CLK2_HALF_PER) rclk = ~rclk;

  // DUT
tx_fifo #(
   .DATA_WIDTH (8),
   .PTR_WIDTH  (10)
  )
  tx_fifo0 (
    .i_wclk             (wclk), 
    .i_wrst_n           (wrst_n),
    .i_push             (fifo_push), 
    .i_wdata            (fifo_in), 
    .i_rclk             (rclk), 
    .i_rrst_n           (rrst_n), 
    .i_pop              (fifo_pop), 
    .o_rdata            (fifo_out),
    .o_afull            (fifo_afull),
    .o_aempty           (fifo_aempty)

  );

  
  initial begin
    #10;
    wrst_n  = 1'b0;
    rrst_n  = 1'b0;
    #100;
    wrst_n  = 1'b1;
    rrst_n  = 1'b1;
    #60;
    for (iindx=0; iindx<1026; iindx=iindx+1) begin
      @(posedge wclk);
      fifo_in <= iindx+1;
      fifo_push <= 1'b1;
      @(posedge wclk);
      fifo_push <= 1'b0;
    end
    for (iindx=0; iindx<1026; iindx=iindx+1) begin
      @(posedge rclk);
      fifo_pop <= 1'b1;
      @(posedge rclk);
      fifo_pop <= 1'b0;
    end
    #1000;
    $stop;
  end

endmodule

