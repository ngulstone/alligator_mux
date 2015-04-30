//_____________________________________________________________________________
// Description
// Synchronizer flops
//  
    

`timescale 1ns/1ns

module synch_ff #(
   parameter WIDTH = 1
)
(
  input  wire               i_clk, 
  input  wire [WIDTH-1:0]   i_d, 
  output reg  [WIDTH-1:0]   o_q 

   );

//_____________________________________________________________________________
// Declarations
 reg [WIDTH-1:0] d0;


//_____________________________________________________________________________
// Logic

  always @(posedge i_clk) begin
    d0  <= i_d;
    o_q <= d0;
  end
   
//_____________________________________________________________________________
// Instantiation

endmodule
