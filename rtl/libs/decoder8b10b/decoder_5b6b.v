/*




//_____________________________________________________________________________
//Description
    * Performs standard 5b/6b decoding for the lower 5 bits of an octet of data
    * reports the number of ones in the 6b word to indicate disparity for error checking
    * reports whether 6bit code is neutral to aid error checking
    * Used as part of a single byte 8B/10B encoder
    * To verify, compare input->output map with standard 8B/10B table
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module decoder_5b6b (
    input   wire    [5:0]   i_data6,
    output  reg     [2:0]   o_data5,
    output  wire            o_is_neutral,
    output  wire    [2:0]   o_ones,
    input   wire            i_run_disp,
    output  wire            o_run_disp
);


//_____________________________________________________________________________
//Declarations

    wire    [2:0]           ones4;


//_____________________________________________________________________________
//Main Body of code


    //Count the number of 1s in the lower 4 bits of the code. This is used for the 
    //decodes on each of the individual output bits
    assign  ones4   =   i_data6[3]+i_data6[2]+i_data6[1]+i_data6[0];
    
    
    //The total number of ones is used as output for the error checker as well as to 
    //calculate running disparity
    assign  o_ones  =   i_data6[5] + i_data6[4] + ones4;
    
    
    //Decode 5bit output. .The decodes here are extracted from the standard 8B/10B tables
    assign  o_data5[4]  =   (  (ones4 == 3'd2) && !i_data6[1] && !i_data6[2] && (i_data6[4]==i_data6[5])
                            || (ones4 == 3'd1) && !i_data6[5]
                            || (ones4 == 3'd1) && i_data6[3] && i_data6[4] && i_data6[5]        
                            || (ones4 == 3'd2) && !i_data6[0] && !i_data6[2] && (i_data6[4]==i_data6[5])
                            || (ones4 == 3'd1) && !i_data6[4]
                            || !i_data6[0] && !i_data6[1] && !i_data6[4] && !i_data6[5]
                            || !i_data6[2] && !i_data6[3] && !i_data6[4] && !i_data6[5] ) ^ i_data6[4];
                            
    assign  o_data5[3]  =   (  (ones4 == 3'd2) && !i_data6[1] && !i_data6[2] && (i_data6[4]==i_data6[5])
                            || (ones4 == 3'd3) &&  i_data6[5]
                            || (ones4 == 3'd1) &&  i_data6[3] &&  i_data6[4] && i_data6[5] 
                            || (ones4 == 3'd2) &&  i_data6[0] &&  i_data6[2] && (i_data6[4]==i_data6[5])
                            || (ones4 == 3'd1) && !i_data6[4]
                            || i_data6[0] && i_data6[1] && i_data6[4] && i_data6[5]
                            || !i_data6[2] && !i_data6[3] && !i_data6[4] && !i_data6[5] ) ^ i_data6[3];
                            
    assign  o_data5[2]  =   (  (ones4 == 3'd2) && i_data6[1] && i_data6[2] && (i_data6[4]==i_data6[5])
                            || (ones4 == 3'd3) && i_data6[5]
                            || (ones4 == 3'd1) && i_data6[3] && i_data6[4] && i_data6[5]
                            || (ones4 == 3'd2) && !i_data6[0] && !i_data6[2] && (i_data6[4]==i_data6[5])
                            || (ones4 == 3'd1) && !i_data6[4]
                            || !i_data6[0] && !i_data6[1] && !i_data6[4] && !i_data6[5]
                            || !i_data6[2] && !i_data6[3] && !i_data6[4] && !i_data6[5] ) ^ i_data6[2];
                            
    assign  o_data5[1]  =   (   (ones4 == 3'd2) && i_data6[1] && i_data6[2] && (i_data6[4]==i_data6[5]))
                            ||  (ones4 == 3'd3) && i_data6[5]
                            ||  (ones4 == 3'd1) && i_data6[3] && i_data6[4] && i_data6[5]
                            ||  (ones4 == 3'd2) && i_data6[0] && i_data6[2] && (i_data6[4]==i_data6[5])
                            ||  (ones4 == 3'd1) && !i_data6[4]
                            ||  i_data6[0] && i_data6[1] && i_data6[4] && i_data6[5]
                            ||  !i_data6[2] && !i_data6[3] && !i_data6[4] && !i_data6[5]) ) ^ i_data6[1];

    assign  o_data5[0]  =   (   (ones4 == 3'd2) & ~i_data6[1] & ~i_data6[2] & (i_data6[4]==i_data6[5])) 
                            ||  (ones4 == 3'd3) & i_data6[5] 
                            ||  (ones4 == 3'd1) & i_data6[3] & i_data6[4] & i_data6[5] 
                            ||  (ones4 == 3'd2) & ~i_data6[0] & ~i_data6[2] & (i_data6[4]==i_data6[5])
                            ||  (ones4 == 3'd1) & ~i_data6[4]
                            ||  i_data6[0] & i_data6[1] & i_data6[4] & i_data6[5]
                            ||  ~i_data6[2] & ~i_data6[3] & ~i_data6[4] & ~i_data6[5]) ) ^ i_data6[0];

    

    //The incoming code is neutral if it has the same number of zeros as ones
    assign  o_is_neutral    =   o_ones == 3'd3;
    
    //Running disparity is positive if there are more ones than zeros, the same as 
    //before for neutral, and negative for fewer ones than zeros
    assign  o_run_disp  =   (o_ones > 3'd3)?    1'b1:
                            o_is_neutral?       i_run_disp:
                                                1'b0;


endmodule