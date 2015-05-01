//_____________________________________________________________________________
// Description
// Async FIFO Controller with almost-full and almost-empty flags
//  
    

`timescale 1ns/1ns

module async_fifo_ctlr #(
   parameter DATA_WIDTH    = 8,
   parameter PTR_WIDTH     = 10,
   parameter AFULL_THRESH  = 8,
   parameter AEMPTY_THRESH = 8
  )
  (
  input  wire                     i_wclk, 
  input  wire                     i_wrst_n,
  input  wire                     i_push, 
  output wire [PTR_WIDTH-1:0]     o_wptr, 
  output wire                     o_wren, 
  // input  wire [DATA_WIDTH-1:0]    i_wdata, 
  input  wire                     i_rclk, 
  input  wire                     i_rrst_n, 
  input  wire                     i_pop, 
  output wire [PTR_WIDTH-1:0]     o_rptr,
  output wire                     o_rden,
  output wire                     o_afull,
  output wire                     o_aempty

  );

//_____________________________________________________________________________
// Declarations
   
  wire                 fifo_empty, fifo_full;
  wire [PTR_WIDTH:0]   wptr_g, rptr_g, rptr_adv_g;
  wire [PTR_WIDTH:0]   wptr_g_sync, rptr_g_sync;
  wire [PTR_WIDTH:0]   rptr_sync_g2b;

  reg  [PTR_WIDTH:0]   wptr, rptr;
  reg  [PTR_WIDTH:0]   wptr_adv, rptr_adv;

//_____________________________________________________________________________
// Logic




  // write clock domain
  assign o_wren        = i_push & ~fifo_full;
  assign o_wptr        = wptr[PTR_WIDTH-1:0];
  assign wptr_g        = bin2gray(wptr);
  assign rptr_sync_g2b = gray2bin(rptr_g_sync);
  assign fifo_full     = ({~wptr[PTR_WIDTH],wptr[PTR_WIDTH-1:0]} == rptr_sync_g2b);
  assign o_afull       = ({~wptr_adv[PTR_WIDTH],wptr_adv[PTR_WIDTH-1:0]} == rptr_sync_g2b);

  always @(posedge i_wclk or negedge i_wrst_n) begin
    if (!i_wrst_n) begin
       wptr       <= 'd0;
       wptr_adv   <= 'd0;
    end
    else begin
      if (o_wren) begin
        wptr      <= wptr + 1'b1;
        wptr_adv  <= wptr + AFULL_THRESH;
      end
    end
  end
  
  
  // read clock domain
  assign o_rden        = i_pop  & ~fifo_empty;
  assign o_rptr        = rptr[PTR_WIDTH-1:0];
  assign rptr_adv_g    = bin2gray(rptr_adv);
  assign rptr_g        = bin2gray(rptr);
  assign fifo_empty    = (wptr_g_sync == rptr_g);
  assign o_aempty      = (wptr_g_sync == rptr_adv_g);

  always @(posedge i_rclk or negedge i_rrst_n) begin
    if (!i_rrst_n) begin
       rptr     <= 'd0;
       rptr_adv <= 'd0;
    end
    else begin
      if (o_rden) begin 
        rptr     <= rptr + 1'b1;
        rptr_adv <= rptr + AEMPTY_THRESH;
      end
    end
  end
   


//_____________________________________________________________________________
// Functions

  // bin2gray converts binary number to Gray code
  function [PTR_WIDTH:0] bin2gray;
    input [PTR_WIDTH:0] bin;
  
    reg [PTR_WIDTH:0] tmp_gray;
    integer indx;
  
    begin
      tmp_gray = bin;

      for (indx = 0; indx <= PTR_WIDTH-1; indx = indx + 1) begin
        tmp_gray[indx] = bin[indx] ^ bin[indx+1];
      end 

      bin2gray = tmp_gray;
    end
  
  endfunction
  
  // gray2bin converts Gray code to binary code
  function [PTR_WIDTH:0] gray2bin;
    input [PTR_WIDTH:0] gray;
  
    reg [PTR_WIDTH:0] tmp_bin;
    integer indx;
  
    begin
      tmp_bin = gray;

      for (indx = 0; indx <= PTR_WIDTH-1; indx = indx + 1) begin
        tmp_bin[indx] = gray[indx] ^ tmp_bin[indx+1];
      end 

      gray2bin = tmp_bin;
    end
  
  endfunction

//_____________________________________________________________________________
// Instantiation
//
  synch_ff #(.WIDTH(PTR_WIDTH+1)) rptr_sync
    ( .i_clk (i_wclk),
      .i_d   (rptr_g),
      .o_q   (rptr_g_sync)
    );  

  synch_ff #(.WIDTH(PTR_WIDTH+1)) wptr_sync
    ( .i_clk (i_rclk),
      .i_d   (wptr_g),
      .o_q   (wptr_g_sync)
    );  

endmodule
