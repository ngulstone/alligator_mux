/*




//_____________________________________________________________________________
//Description
    * Performs standard 3b/4b decoding for the upper 3 bits of an octet of data
    * reports the number of ones in the 4b word to indicate disparity for error checking
    * reports whether 4bit code is neutral to aid error checking
    * Used as part of a single byte 8B/10B encoder
    * To verify, compare input->output map with standard 8B/10B table
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module decoder_3b4b (
    input   wire    [3:0]   i_data10,
    input   wire            o_datak,    //1=corresponding i_data bytes is a k character
    output  reg     [2:0]   o_data3,
    output  wire            o_is_neutral,
    output  wire    [2:0]   o_ones,
    input   wire            i_run_disp,
    output  wire            o_run_disp
);


//_____________________________________________________________________________
//Declarations

    wire                    k28neg;
    wire                    k28pos;
    wire                    kneg;
    wire                    kpos;


//_____________________________________________________________________________
//Main Body of code


    //Decode the top 3 bits from the top 4 bits of the 10 bit input
    always @*
    case(i_data10[9:6])
        4'b0000:    o_data3 =   3'b111;
        4'b0001:    o_data3 =   3'b111;
        4'b0010:    o_data3 =   3'b000;
        4'b0011:    o_data3 =   3'b011;
        4'b0100:    o_data3 =   &(~i_data10[5:2])?   3'b011:3'b100;
        4'b0101:    o_data3 =   &(~i_data10[5:2])?   3'b010:3'b101;
        4'b0110:    o_data3 =   &(~i_data10[5:2])?   3'b001:3'b110;
        4'b0111:    o_data3 =   &(~i_data10[5:2])?   3'b000:3'b111;
        4'b1000:    o_data3 =   3'b111;
        4'b1001:    o_data3 =   &(~i_data10[5:2])?   3'b110:3'b001;
        4'b1010:    o_data3 =   &(~i_data10[5:2])?   3'b101:3'b010;
        4'b1011:    o_data3 =   3'b100;
        4'b1100:    o_data3 =   3'b011;
        4'b1101:    o_data3 =   3'b000;
        4'b1110:    o_data3 =   3'b111;
        4'b1111:    o_data3 =   3'b000;
        default:    o_data3 =   3'bxxx;
    endcase
    

    //Decode to determine whether the lower 6 bits of the 10-bit code are
    //a k-character, and if so, what type
    assign  k28neg  =   6'b110000 == i_data10[5:0];
    
    assign  k28pos  =   6'b001111 == i_data10[5:0];
    
    assign  kneg    =   6'b000101    == i_data10[5:0]
                        || 6'b001001 == i_data10[5:0]
                        || 6'b010001 == i_data10[5:0]
                        || 6'b100001 == i_data10[5:0];
    
    assign  kpos    =   6'b111010    == i_data10[5:0]   
                        || 6'b110110 == i_data10[5:0]
                        || 6'b101110 == i_data10[5:0]
                        || 6'b011110 == i_data10[5:0];


    //Decode the upper 4-bits to search for k-characters
    always @*
    case(i_data10[9:6])
        4'b0000:    o_datak =   1'b0;   
        4'b0001:    o_datak =   k28pos||kpos;       
        4'b0010:    o_datak =   k28pos;  
        4'b0011:    o_datak =   k28neg; 
        4'b0100:    o_datak =   k28pos; 
        4'b0101:    o_datak =   k28pos||k28neg; 
        4'b0110:    o_datak =   k28pos||k28neg;  
        4'b0111:    o_datak =   1'b0;  
        4'b1000:    o_datak =   1'b0; 
        4'b1001:    o_datak =   k28pos||k28neg; 
        4'b1010:    o_datak =   k28pos||k28neg;  
        4'b1011:    o_datak =   k28neg;    
        4'b1100:    o_datak =   k28pos; 
        4'b1101:    o_datak =   k28neg; 
        4'b1110:    o_datak =   k28neg||kneg; 
        4'b1111:    o_datak =   1'b0;    
        default:    o_datak =   1'bx;   //Illegal 
    endcase
    
    
    //Count the number of ones in the 4-bit code 
    assign  o_ones  =   i_data10[9] + i_data10[8]+i_data10[7]+i_data10[6];
    
    //Assert neutral if the number of ones is 2, indicating equal ones and zeros
    assign  o_is_neutral    =   o_ones == 3'd2;
    
    //Set running disparity positive if there are more ones than zeros, to negative
    //if there are fewer ones than zeros, and to the previous value if the number
    //of ones and zeros is equal
    assign  o_run_disp  =   (o_ones > 3'd2)?    1'b1:
                            o_is_neutral?       i_run_disp:
                                                1'b0;  


endmodule