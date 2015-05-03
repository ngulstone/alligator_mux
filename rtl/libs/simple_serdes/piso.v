/*




//_____________________________________________________________________________
//Description
    * Simplified model of a PISO
    * Differential serial I/O pins send data + tx serial clock, to simplify CDR
    * PWIDTH controls number of parallel bits in the datapath
    * Data is serialized msbit first; this means the bit at WIDTH-1 is first
    
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module piso #(
    parameter   PWIDTH          =   20,     //Parallel bits in datapath
    parameter   TXN_IS_SCLK     =   1       //1:txn is used for sclk instead of complement data
)
(
    input   wire                    i_sclk,
    input   wire                    i_slock,
    output  wire                    o_pclk,
    output  wire                    o_plock,
    input   wire                    i_rst,
    input   wire    [PWIDTH-1:0]    i_pdata,
    output  reg                     o_txp,
    output  wire                    o_txn
);


//_____________________________________________________________________________
//Declarations
    
    localparam      CW  =   $clog2(WIDTH);
    
    reg     [CW-1:0]        divp;
    reg     [CW-1:0]        bit;
    reg     [WIDTH-1:0]     pdata;


//_____________________________________________________________________________
//Main Body of code


    //=========================================================================
    //Clocks and locks
    
    //Use a counter to divide the serial clock down to the parallel rate. Note 
    //that we use a blocking assignment to make sure that the clock assignment
    //occurs before data switching in simulation
    always @(posedge i_sclk or posedge i_rst)
    if(i_rst)   divp    =   {CW{1'b0}};
    else        divp    =   (divp == WIDTH-1)?  {CW{1'b0}}:
                                                (divp + 1);
                                                
    //Switch the parallel clock when at half width. We're ok with a non-50/50 duty cycle.
    //The clock will switch when the count goes to 0
    assign  o_pclk  =   (divp < WIDTH>>1);
                                                
    //For now, indicate parallel lock when serial lock is high and reset is low
    assign  o_plock =   i_slock && !i_rst;
    
    
    //=========================================================================
    //Parallel data
    
    //Register parallel data on the posedge of oclk
    always @(posedge o_pclk or posedge i_rst)
    if(i_rst)   pdata   <=  {WIDTH{1'b0}};
    else        pdata   <=  i_pdata;
    
    
    //Create a counter running on the serial clock to select the next bit to serialize
    //Note that we do not use divp for this count, to avoid assignment issues. We use
    //a downcounter because we want to serialize msb first
    always @(posedge o_sclk or posedge i_rst)
    if(i_rst)   bit <=  (WIDTH-1);
    else        bit <=  (bit == {CW{1'b0}})?    (WIDTH-1):
                                                (bit-1);
       
    //Use the bit counter to select a bit to transmit. 
    assign  sdata   =   pdata[bit];
 
 
    //Register the serial data on the serial clock and transmit it
    always @(posedge i_sclk or posedge i_rst)
    if(i_rst)   o_txp   <=  1'b0;
    else        o_txp   <=  sdata;
    
    
    //We use the complementary serial output to send either the serial clock 
    //(for our simple mode of operation) or the complement of the serial data
    //(for interoperation with other models)
    assign  o_txn   =   TXN_IS_SCLK?    i_sclk: !o_txp;
    

endmodule