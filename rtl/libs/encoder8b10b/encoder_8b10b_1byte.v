/*




//_____________________________________________________________________________
//Description
    * Performs standard 8B/10B encoding on 1 octet of data
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module encoder_8b10b_1byte (
    input   wire    [7:0]   i_data,     
    input   wire            i_datak,    //1=corresponding i_data bytes is a k character
    output  wire    [9:0]   o_data10,
    input   wire            i_run_disp,
    output  wire            o_run_disp
);


//_____________________________________________________________________________
//Declarations

    
    wire                    run_disp;


//_____________________________________________________________________________
//Main Body of code


    //=========================================================================
    //Apply 5b6b encoding to the lower 5 bits of i_data, and 3b4b encoding to the 
    //upper 3 bits
    
    encoder_5b6b enc_4_0 (
        .i_data5        (i_data[4:0]    ),
        .i_datak        (i_datak        ),
        .o_data6        (o_data10[5:0]  ),
        .i_run_disp     (i_run_disp     ),
        .o_run_disp     (run_disp       )
    );
    
    encoder_3b4b enc_7_5 (
        .i_data8        (i_data         ),  //all 8 bits are used for the 3b/4b encode
        .i_dataie       (o_data10[5:4]  ),  //top bits from 5b6b (bits ei) are used by 3b4b
        .i_datak        (i_datak        ),
        .o_data4        (o_data10[9:6]  ),
        .i_run_disp     (run_disp       ),
        .o_run_disp     (o_run_disp     )
    );


endmodule