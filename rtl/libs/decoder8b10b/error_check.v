/*




//_____________________________________________________________________________
//Description
    * Checks an incoming 8b/10b code group (10b data) for not-in-table and disparity errors
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module error_check (
    input   wire    [9:0]   i_data10,
    input   wire            i_neutral5b6b,
    input   wire            i_neutral3b4b,
    input   wire            i_run_disp5b6b,
    input   wire            i_run_disp3b4b,
    input   wire            i_run_disp,
    output  wire            o_run_disp,
    input   wire    [2:0]   i_ones5b6b,
    input   wire    [2:0]   i_ones3b4b,
    output  wire            o_not_in_table,
    output  wire            o_disp_err
);


//_____________________________________________________________________________
//Declarations
    
    localparam              RD_ERROR    =   2'b10;
    localparam              RD_PLUS     =   2'b01;
    localparam              RD_MINUS    =   2'b00;
    localparam              RD_BOTH     =   2'b11;
    
    reg     [1:0]           rdcol;

    wire    [2:0]           ones4;
    wire    [3:0]           ones;
    wire                    is_bad;
    wire                    is_bad38;

//_____________________________________________________________________________
//Main Body of code


    //=========================================================================
    // Detect not in table errors. 
    
    //Count the number of ones in the lower 4 bits. This value is used in a few
    //of the filters
    assign  ones4   =   i_data10[0] + i_data10[1] + i_data10[2] + i_data10[3];


    //Use a standard 8B/10B filter to catch bad runs and combinations    
    assign  is_bad  =   &i_data10[3:0]          
                        ||  &(~i_data10[3:0])   
                        ||  &i_data10[9:6]      
                        ||  &(~i_data10[9:6])   
                        ||  &i_data10[8:4]      
                        ||  &(~i_data10[8:4])   
                        ||  (ones4 == 2'd1) && !i_data10[4] && !i_data10[5]
                        ||  (ones4 == 2'd3) && i_data10[4] && i_data10[5]
                        ||  &i_data10[9:7] && !i_data10[5] && i_data10[4]
                        ||  &(~i_data10[9:7]) && i_data10[5] && !i_data10[4]
                        ||  &(~i_data10[9:7]) && &i_data10[5:4] && !(i_data10[2]==i_data10[3] && i_data10[3]==i_data10[4])
                        ||  &i_data10[9:7] && &(~i_data10[5:4]) && !(i_data10[2]==i_data10[3] && i_data10[3]==i_data10[4])
                        ||  !(ones == 2'd3) && i_data10[4] && !i_data10[5] && &(~i_data10[9:7])
                        ||  !(ones == 3'd1) && !i_data10[4] && i_data10[5] && &i_data10[9:7];
                                    
    
    //Use a second filter to look for bad codes that aren't caught by the filter, or by
    //counting total ones and zeros
                                          //jhgfiedcba
    assign  is_bad38    =  i_data10  == 10'b1100101000
                        || i_data10  == 10'b1100011000 
                        || i_data10  == 10'b1110111000 
                        || i_data10  == 10'b1101111000 
                        || i_data10  == 10'b0011111000 
                        || i_data10  == 10'b1011111000 
                        || i_data10  == 10'b1100100100 
                        || i_data10  == 10'b1100010100 
                        || i_data10  == 10'b1100001100 
                        || i_data10  == 10'b1000111100 
                        || i_data10  == 10'b0011111100 
                        || i_data10  == 10'b1100100010 
                        || i_data10  == 10'b1100010010 
                        || i_data10  == 10'b1100001010 
                        || i_data10  == 10'b0011111010 
                        || i_data10  == 10'b1100000110 
                        || i_data10  == 10'b0011110110 
                        || i_data10  == 10'b0011101110 
                        || i_data10  == 10'b0011011110 
                        || i_data10  == 10'b1100100001 
                        || i_data10  == 10'b1100010001 
                        || i_data10  == 10'b1100001001 
                        || i_data10  == 10'b0011111001 
                        || i_data10  == 10'b1100000101 
                        || i_data10  == 10'b0011110101 
                        || i_data10  == 10'b0011101101 
                        || i_data10  == 10'b0011011101 
                        || i_data10  == 10'b1100000011 
                        || i_data10  == 10'b0111000011 
                        || i_data10  == 10'b0011110011 
                        || i_data10  == 10'b0011101011 
                        || i_data10  == 10'b0011011011 
                        || i_data10  == 10'b0100000111 
                        || i_data10  == 10'b1100000111 
                        || i_data10  == 10'b0010000111 
                        || i_data10  == 10'b0001000111 
                        || i_data10  == 10'b0011100111 
                        || i_data10  == 10'b0011010111;
                        
    
    //The total number of ones in the 10bit code is used to filter out codes with too
    //many or too few ones
    assign  ones    =   i_ones5b6b + i_ones3b4b;  
    
    //Flag codes with the wrong number of ones, and codes that fail either filter
    assign  o_not_in_table  =   ones > 4'd6 || ones < 4'd4 || is_bad || is_bad38; 
                                
        
        
    //=========================================================================
    // Detect disparity errors                                

    //Determine which column the incoming code belongs to by combining its
    //6-bit and 4-bit neutral/run-disp information.
    always @*
    case({i_neutral6b5b,i_run_disp6b5b,i_neutral4b3b,i_run_disp4b3b}
        4'b0000:    rdcol = RD_ERROR;        
        4'b0001:    rdcol = RD_PLUS;
        4'b0010:    rdcol = RD_PLUS;
        4'b0011:    rdcol = RD_PLUS;
        4'b0100:    rdcol = RD_MINUS;  
        4'b0101:    rdcol = RD_ERROR;
        4'b0110:    rdcol = RD_MINUS;  
        4'b0111:    rdcol = RD_MINUS;
        4'b1000:    rdcol = RD_PLUS;
        4'b1001:    rdcol = RD_MINUS;
        4'b1010:    rdcol = (i_txdata[5:0]==6'b000111)? RD_MINUS:
                            (i_txdata[5:0]==6'b111000)? RD_PLUS:
                            (i_txdata[9:6]==4'b0011)?   RD_MINUS:
                            (i_txdata[9:6]==4'b1100)?   RD_PLUS:
                                                        RD_BOTH;
        4'b1011:    rdcol = (i_txdata[5:0]==6'b000111)? RD_MINUS:
                            (i_txdata[5:0]==6'b111000)? RD_PLUS:
                            (i_txdata[9:6]==4'b0011)?   RD_MINUS:
                            (i_txdata[9:6]==4'b1100)?   RD_PLUS:
                                                        RD_BOTH;
        4'b1100:    rdcol = RD_PLUS;
        4'b1101:    rdcol = RD_MINUS;
        4'b1110:    rdcol = (i_txdata[5:0]==6'b000111)? RD_MINUS:
                            (i_txdata[5:0]==6'b111000)? RD_PLUS:
                            (i_txdata[9:6]==4'b0011)?   RD_MINUS:
                            (i_txdata[9:6]==4'b1100)?   RD_PLUS:
                                                        RD_BOTH;
        4'b1111:    rdcol = (i_txdata[5:0]==6'b000111)? RD_MINUS:
                            (i_txdata[5:0]==6'b111000)? RD_PLUS:
                            (i_txdata[9:6]==4'b0011)?   RD_MINUS:
                            (i_txdata[9:6]==4'b1100)?   RD_PLUS:
                                                        RD_BOTH;  
        default:    rdcol = 2'bxx;   
    endcase

  
    //A disparity error occurs when the code provided is not found in the column that is expected based
    //on the running disparity of the previous running disparity
    assign  o_disp_err  =   (rdcol == RD_ERROR)?    1'b1:                   //Bad code
                            (rdcol == RD_MINUS)?    (i_run_disp == 1'b1):   //Error if run disp was positive
                            (rdcol == FROM_RDPLUS)? (i_run_disp == 1'b0):   //Error if run disp was negative
                                                    1'b0;   //No disparity error for codes that appear in both columns





endmodule