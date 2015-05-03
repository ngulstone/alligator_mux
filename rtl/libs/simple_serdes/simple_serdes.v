/*




//_____________________________________________________________________________
//Description
    * Simplified model of a PISO, SIPO, and PLL
    * Differential serial I/O pins send data + tx serial clock, to simplify CDR
    * PWIDTH controls number of parallel bits in the datapath
    * Currently uses SCLK_PS parameter to generate serial clock instead of refclk
    
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module simple_serdes #(
    parameter   PWIDTH      =   20,     //Parallel bits in datapath
    parameter   SCLK_PS     =   400,    //SCLK period in ps  
    parameter   MULT        =   10,     //Not currently used
    parameter   DIV         =   1       //Not currently used
)
(
    input   wire    [PWIDTH-1:0]    i_tx_data,
    output  wire                    o_tx_clk,
    output  wire                    o_tx_lock,
    input   wire                    i_tx_rst,
    output  wire                    o_txp,
    output  wire                    o_txn,
    
    output  wire    [PWIDTH-1:0]    i_rx_data,
    output  wire                    o_rec_clk,
    output  wire                    o_rx_lock,
    input   wire                    i_rx_rst,
    input   wire                    i_rxp,
    input   wire                    i_rxn,
    
    input   wire                    i_ref_clk,  //Not currently used
    input   wire                    i_pll_rst
);


//_____________________________________________________________________________
//Declarations
    
    wire                            sclk;
    wire                            lock;
    

//_____________________________________________________________________________
//Main Body of code


    pll #(
        .SCLK_PS    (SCLK_PS    ),
        .MULT       (MULT       ),
        .DIV        (DIV        )
    )
    pll_0 (
        .i_ref_clk  (i_ref_clk  ),
        .i_rst      (i_pll_rst  ),
        .o_sclk     (sclk       ),
        .o_lock     (lock       )
    );
    
    
    piso #(
        .PWIDTH     (PWIDTH     )
    )
    piso (
        .i_sclk     (sclk       ),
        ,i_slock    (lock       ),
        .o_pclk     (o_tx_clk   ),
        ,o_plock    (o_tx_lock  ),
        .i_rst      (i_tx_rst   ),
        .i_pdata    (i_tx_data  ),
        .o_txp      (o_txp      ),
        .o_txn      (o_txn      )
    );
    
    
    sipo #(
        .PWIDTH
    )
    sipo (
        .i_sclk     (sclk       ),
        .i_slock    (lock       ),
        .o_pclk     (o_rec_clk  ),
        .o_plock    (o_rx_lock  ),
        .i_rst      (i_rx_rst   ),
        .o_pdata    (o_rx_data  ),
        .i_rxp      (i_rxp      ),
        .i_rxn      (i_rxn      )
    );
    


endmodule