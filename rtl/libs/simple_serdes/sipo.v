/*




//_____________________________________________________________________________
//Description
    * Simplified model of a SIPO
    * Differential serial I/O pins send data + tx serial clock, to simplify CDR
    * PWIDTH controls number of parallel bits in the datapath
    * Data is deserialized msbit first; this means the bit at WIDTH-1 is first
    
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module sipo #(
    parameter   PWIDTH          =   20,     //Parallel bits in datapath
    parameter   RXN_IS_SCLK     =   1       //1:rxn is used for sclk instead of complement data
)
(
    input   wire                    i_sclk,
    input   wire                    i_slock,
    output  wire                    o_pclk,
    output  reg                     o_plock,
    input   wire                    i_rst,
    output  reg     [PWIDTH-1:0]    o_pdata,
    input   wire                    i_rxp,
    input   wire                    i_rxn
);


//_____________________________________________________________________________
//Declarations
    
    localparam      CW  =   $clog2(WIDTH);
    
    reg     [CW-1:0]        divp;
    reg     [WIDTH-1:0]     pdata;
    
    wire                    sclk;
    wire                    cdrclk;


//_____________________________________________________________________________
//Main Body of code


    //=========================================================================
    //Clocks and locks
    
    //When running in simple mode, instead of trying to generate a serial clock by 
    //shifting the delay on the local serial clock to match the edges of the incoming 
    //data, we simply extract the serail clock from the rxn signal and use it.
    assign  sclk    =   RXN_IS_SCLK?    i_rxn: cdrclk;   
    
    
    //Clock Data Recovery (CDR) is the non-simple way of getting a serial clock to go
    //with the incoming serial data. For not we tie this off to 0. IN the future, we 
    //need to add a block to do clock data recovery
    assign  cdrclk  =   1'b0;
    
    //Generate a parallel clock based on the serial clock. Note that we use blocking
    //assignments to ensure clock assignment is evaluated before data switches.
    always @(posedge sclk or posedge i_rst)
    if(i_rst)   divp    =   {CW{1'b0}};
    else        divp    =   (divp == WIDTH-1)?  {CW{1'b0}}:
                                                (divp + 1);
                                                
    //Switch the parallel clock when at half width. We're ok with a non-50/50 duty cycle.
    //The clock will switch when the count goes to 0
    assign  o_pclk  =   (divp < WIDTH>>1);
    
    
    //For now, indicate parallel lock when the divp has cycled at least once and slock
    //is high
    always @(posedge o_pclk or posedge i_rst)
    if(i_rst)   o_plock <=  1'b0;
    else        o_plock <=  i_slock;
    
    
    //=========================================================================
    //Parallel data


    //Shift data into a chain of regisers using the serial clock
    always @(posedge sclk or posedge i_rst)
    if(i_rst)   pdata   <=  {WIDTH{1'b0}};
    else        pdata   <=  {pdata[WIDTH-2:1],i_rxp};
    
    
    //Register the parallel data using the posedge of o_pclk
    always @(posedge o_pclk or posedge i_rst)
    if(i_rst)   o_pdata <=  {WIDTH{1'b0}};
    else        o_pdata <=  pdata;
    

endmodule