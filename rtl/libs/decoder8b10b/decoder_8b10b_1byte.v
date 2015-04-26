/*




//_____________________________________________________________________________
//Description
    * Performs standard 8B/10B decoding on 1 octet of data
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module decoder_8b10b_1byte (
    input   wire    [9:0]   i_data10,     
    input   wire            o_datak,    //1=corresponding i_data bytes is a k character
    output  wire    [7:0]   o_data,
    output  wire            o_not_in_table,
    output  wire            o_disp_err,
    input   wire            i_run_disp,
    output  wire            o_run_disp
);


//_____________________________________________________________________________
//Declarations
    
    wire                    run_disp;
    wire                    neutral5b6b;
    wire                    neutral3b4b;
    wire    [2:0]           ones5b6b;
    wire    [2:0]           ones3b4b;


//_____________________________________________________________________________
//Main Body of code


    //=========================================================================
    //Apply 5b6b decoding to the lower 6 bits of i_data, and 3b4b decoding to the 
    //upper 4 bits. Apply an error check to all bits
    
    decoder_5b6b dec_5_0 (
        .i_data6        (i_data10[5:0]  ),
        .o_data6        (o_data[4:0]    ),
        .o_is_neutral   (neutral5b6b    ),
        .o_is_ones      (ones5b6b       ),
        .i_run_disp     (i_run_disp     ),
        .o_run_disp     (run_disp       )
    );
    
    decoder_3b4b dec_9_6 (
        .i_data10       (i_data10       ),  //all 10 bits are used for the 3b/4b encode
        .o_datak        (o_datak        ),
        .o_data3        (o_data[7:5]    ),
        .o_is_neutral   (neutral3b4b    ),
        .o_is_ones      (ones3b4b       ),
        .i_run_disp     (run_disp       ),
        .o_run_disp     (o_run_disp     )
    );
    
    error_check error_check (
        ,i_data10       (i_data10       ),
        .i_neutral5b6b  (neutral5b6b    ),
        .i_neutral3b4b  (neutral3b4b    ),
        .i_run_disp5b6b (run_disp       ),  //run_disp comes from 5b6b
        .i_run_disp3b4b (o_run_disp     ),  //o_run_disp comes from 3b4b
        .i_ones5b6b     (ones5b6b       ),  //#of ones indicates 6b code word disparity
        .i_ones3b4b     (ones3b4b       ),  //#of ones here is 4b code word disparity
        .i_run_disp     (i_run_disp     ),  //i_run_disp is from the previous byte
        .o_not_in_table (o_not_in_table ),
        .o_disp_err     (o_disp_err     )
    );


endmodule