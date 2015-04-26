/*




//_____________________________________________________________________________
//Description
    * Performs standard 5b/6b encoding on the lower 5 bits of an octet of data
    * Used as part of a single byte 8B/10B encoder
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module encoder_5b6b (
    input   wire    [4:0]   i_data5,     
    input   wire            i_datak,    //1=corresponding i_data bytes is a k character
    output  wire    [5:0]   o_data6,
    input   wire            i_run_disp,
    output  wire            o_run_disp
);


//_____________________________________________________________________________
//Declarations

    reg     [5:0]           data6;

    wire                    invert;


//_____________________________________________________________________________
//Main Body of code

    //Encode characters (EDCBA -> iedcba from 8B/10B tables
    always @*     
    case(i_data5)
        5'd0:       data6  =            6'b000110;   // D.0
        5'd1:       data6  =            6'b010001;   // D.1
        5'd2:       data6  =            6'b010010;   // D.2
        5'd3:       data6  =            6'b100011;   // D.3
        5'd4:       data6  =            6'b010100;   // D.4
        5'd5:       data6  =            6'b100101;   // D.5
        5'd6:       data6  =            6'b100110;   // D.6
        5'd7:       data6  =            6'b000111;   // D.7
        5'd8:       data6  =            6'b011000;   // D.8
        5'd9:       data6  =            6'b101001;   // D.9
        5'd10:      data6  =            6'b101010;   // D.10
        5'd11:      data6  =            6'b001011;   // D.11
        5'd12:      data6  =            6'b101100;   // D.12
        5'd13:      data6  =            6'b001101;   // D.13
        5'd14:      data6  =            6'b001110;   // D.14
        5'd15:      data6  =            6'b000101;   // D.15
        5'd16:      data6  =            6'b110110;   // D.16
        5'd17:      data6  =            6'b110001;   // D.17
        5'd18:      data6  =            6'b110010;   // D.18
        5'd19:      data6  =            6'b010011;   // D.19
        5'd20:      data6  =            6'b110100;   // D.20
        5'd21:      data6  =            6'b010101;   // D.21
        5'd22:      data6  =            6'b010110;   // D.22
        5'd23:      data6  =            6'b010111;   // D.23, K.23
        5'd24:      data6  =            6'b001100;   // D.24
        5'd25:      data6  =            6'b011001;   // D.25
        5'd26:      data6  =            6'b011010;   // D.26
        5'd27:      data6  =            6'b011011;   // D.27, K.27
        5'd28:      data6  =   i_datak? 6'b111100:   // K.28
                                        6'b011100;   // D.28
        5'd29:      data6  =            6'b011101;   // D.29, K.29
        5'd30:      data6  =            6'b011110;   // D.30, K.30
        5'd31:      data6  =            6'b110101;   // D.31   
        default :   data6  =            6'bxxxxxx;   // Invalid D
    endcase
    
    
    //For codes that invert depending on current running disparity, determine whether
    //inversion is required
    assign  invert  =   (i_data5 == 5'd0)?   !i_run_disp:              // D.0
                        (i_data5 == 5'd1)?   !i_run_disp:              // D.1
                        (i_data5 == 5'd2)?   !i_run_disp:              // D.2  
                        (i_data5 == 5'd4)?   !i_run_disp:              // D.4
                        (i_data5 == 5'd7)?   i_run_disp:               // D.7 
                        (i_data5 == 5'd8)?   !i_run_disp:              // D.8  
                        (i_data5 == 5'd15)?  !i_run_disp:              // D.15  
                        (i_data5 == 5'd16)?  i_run_disp:               // D.16  
                        (i_data5 == 5'd23)?  i_run_disp:               // D.23  
                        (i_data5 == 5'd24)?  !i_run_disp:              // D.24  
                        (i_data5 == 5'd27)?  i_run_disp:               // D.27  
                        (i_data5 == 5'd29)?  i_run_disp:               // D.29  
                        (i_data5 == 5'd30)?  i_run_disp:               // D.30  
                        (i_data5 == 5'd31)?  i_run_disp:               // D.31
                        (i_data5 == 5'd28)?  (i_run_disp && i_datak):  // K.28
                                            1'b0;
                                          
    //Invert the data if required
    assign  o_data6   =  {6{invert}}^data6;



    
    //Some data5 characters invert running disparity. 
    assign  o_run_disp  =   (i_data5 == 5'd0)?              !i_run_disp:  // D.0 
                            (i_data5 == 5'd1)?              !i_run_disp:  // D.1 
                            (i_data5 == 5'd2)?              !i_run_disp:  // D.2 
                            (i_data5 == 5'd4)?              !i_run_disp:  // D.4 
                            (i_data5 == 5'd8)?              !i_run_disp:  // D.8    
                            (i_data5 == 5'd15)?             !i_run_disp:  // D.15   
                            (i_data5 == 5'd16)?             !i_run_disp:  // D.16   
                            (i_data5 == 5'd23)?             !i_run_disp:  // D.23   
                            (i_data5 == 5'd24)?             !i_run_disp:  // D.24   
                            (i_data5 == 5'd27)?             !i_run_disp:  // D.27   
                            (i_data5 == 5'd29)?             !i_run_disp:  // D.29   
                            (i_data5 == 5'd30)?             !i_run_disp:  // D.30   
                            (i_data5 == 5'd31)?             !i_run_disp:  // D.31 
                            (i_data5 == 5'd28 && i_datak)?  !i_run_disp:  // K.28 
                                                            i_run_disp;   // All others are neutral


endmodule