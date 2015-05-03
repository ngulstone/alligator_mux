/*




//_____________________________________________________________________________
//Description
    * Simplified model of a PLL
    * Currently uses SCLK_PS to generate clock
    
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ps/1ps

module pll #(
    parameter   SCLK_PS         =   400,
    parameter   MULT            =   20,     //Not currently used
    parameter   DIV             =   1       //Not currently used
)
(
    input   wire                    i_ref_clk,
    input   wire                    i_rst,
    output  wire                    o_sclk,
    output  reg                     o_lock
);


//_____________________________________________________________________________
//Declarations
    
    
    reg                     sclk    =   1'b0;
    reg                     gate;


//_____________________________________________________________________________
//Main Body of code

    //Generate a freerunning clock at the specified rate. Note that
    //it is initialized to 0
    always
        #SCLK_PS    sclk  =   !sclk;


    //Generate a gating signal that switches on the negative edge 
    //of the freerunning clock
    always @(negedge sclk or posedge i_rst)
    if(i_rst)   gate    <=  1'b0;
    else        gate    <=  1'b1;


    //Gate the clock when reset is high        
    assign  o_sclk  =   sclk && gate;


    //Assert lock after the clock output has started    
    always @(posedge sclk or posedge i_rst)
    if(i_rst)   o_lock  <=  1'b0;
    else        o_lock  <=  gate;
    
  

endmodule