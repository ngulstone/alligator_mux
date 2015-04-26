/*




//_____________________________________________________________________________
//Description
    * Performs standard 3b/4b encoding on the upper 3 bits of an octet of data
    * Used as part of a single byte 8B/10B encoder
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module encoder_3b4b (
    input   wire    [7:0]   i_data8,
    input   wire    [1:0]   i_dataie,   //top 2 bits (i,e) from 5b/6b are used in 3b/4b encode
    input   wire            i_datak,    //1=corresponding i_data bytes is a k character
    output  wire    [5:0]   o_data4,
    input   wire            i_run_disp,
    output  wire            o_run_disp
);


//_____________________________________________________________________________
//Declarations

    reg                     data4;
    
    wire                    is_k28;
    wire                    ei_rd_7;
    wire                    invert_k28;
    wire                    invert;


//_____________________________________________________________________________
//Main Body of code


    
    //Decode the lower 5 bits of data8 to determine whether the data is K.28
    assign  is_k28      =   (i_data8[4:0] == 5'd28) && i_datak;
        
    //Dx.7 uses the same code as Kx.7 when ie are both the opposite value of rd
    assign  ei_rd_7  =   ( &i_dataie && !i_run_disp ) || ( &(~i_dataie) && i_run_disp );        
    
    //Encode the upper 3 bits of data8 
    always @*
    case(i_data8[7:5])
        3'd0:       data4   =                           4'b0010;   // D.x.0,K.x.0
        3'd1:       data4   =                           4'b1001;   // D.x.1,K.x.1
        3'd2:       data4   =                           4'b1010;   // D.x.2,K.x.2
        3'd3:       data4   =                           4'b0011;   // D.x.3,K.x.3
        3'd4:       data4   =                           4'b0100;   // D.x.4,K.x.4
        3'd5:       data4   =                           4'b0101;   // D.x.5,K.x.5
        3'd6:       data4   =                           4'b0110;   // D.x.6,K.x.6
        3'd7:       data4   =   (i_datak ||ei_rd_7)?    4'b1110:   // D.x.7 special case, K.x.7
                                                        4'b0111;   // D.x.7 normal case  
        default:    data4   =                           4'bxxxx;   //Invalid        
    endcase
        

    //Select inversion for k28 codes based on running disparity
    assign  invert_k28   =  (i_data8[7:5] == 3'd3)? i_run_disp:
                            (i_data8[7:5] == 3'd7)? i_run_disp:
                                                    !i_run_disp;  
   
    
    //Here we determine inversions for the remaining codes
    assign  invert  =   (i_data8[7:5] == 3'd0)? !i_run_disp:
                        (i_data8[7:5] == 3'd3)? i_run_disp:
                        (i_data8[7:5] == 3'd4)? !i_run_disp:
                        (i_data8[7:5] == 3'd7)? i_run_disp:
                                                1'b0;


    //Select the final encoded output
    assign  data4    =  is_k28?     (data4 ^   {4{invert_k28}}):
                        i_datak?    (4'b1110 ^ {4{invert}}):     //All other valid K codes 
                                    (data4 ^   {4{invert}});
                                                    

    //Calculate the next running disparity
    assign  o_run_disp  =   (i_data8[7:5] == 3'd0)? !i_run_disp:  //Dx.0
                            (i_data8[7:5] == 3'd4)? !i_run_disp:  //Dx.4
                            (i_data8[7:5] == 3'd7)? !i_run_disp:  //Dx.7
                                                    i_run_disp;   //The rest are neutral

endmodule