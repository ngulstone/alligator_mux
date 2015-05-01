//_____________________________________________________________________________
// Description
// Asynch FIFO Controller
//  
    

`timescale 1ns/1ns

module tx_fifo #(
   parameter DATA_WIDTH = 8,
   parameter ADDR_WIDTH = 10
  )
  (
  input  wire                     i_wclk, 
  input  wire                     i_wrst_n,
  input  wire                     i_push, 
  input  wire [DATA_WIDTH-1:0]    i_wdata, 
  input  wire                     i_rclk, 
  input  wire                     i_rrst_n, 
  input  wire                     i_pop, 
  output wire [DATA_WIDTH-1:0]    o_rdata,
  output wire                     o_afull,
  output wire                     o_aempty

  );

//_____________________________________________________________________________
// Declarations
   
  wire                 fifo_empty, fifo_full;

  wire [ADDR_WIDTH-1:0] wptr, rptr;

//_____________________________________________________________________________
// Logic
   

//_____________________________________________________________________________
// Instantiation

  async_fifo_ctlr tx_fifo_ctlr
    (
    .i_wclk              (i_wclk), 
    .i_wrst_n            (i_wrst_n),
    .o_wptr              (wptr), 
    .o_wren              (wren), 
    .i_push              (i_push), 
    .i_rclk              (i_rclk), 
    .i_rrst_n            (i_rrst_n), 
    .i_pop               (i_pop), 
    .o_rptr              (rptr),
    .o_rden              (),
    .o_afull             (o_afull),
    .o_aempty            (o_aempty)
  
    );
  
  dp_ram dp_ram 
  (
     .i_wclk             (i_wclk),
     .i_waddr            (wptr), 
     .i_wen              (wren), 
     .i_wdata            (i_wdata), 
     .i_rclk             (i_rclk),
     .i_raddr            (rptr), 
     .i_ren              (i_ren), 
     .o_rdata            (o_rdata)
  
     );
  

endmodule
