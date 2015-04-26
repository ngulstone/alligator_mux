/*




//_____________________________________________________________________________
//Description
    * Performs standard 8B/10B encoding on DATA_BYTES octets of data
    * Sets running disparity negative when compliance is asserted
    * Pipelines any signals that need to stay with the data
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module encoder_8b10b #(
    parameter   DATA_BYTES      =   2,
    parameter   PIPELINE_BITS   =   1   
)
(
    input   wire                        c_clk,
    input   wire                        i_rst,          //synchronous active high
    input   wire                        i_enable,       //0=pause
    input   wire                        i_compliance,   //1=set running disparity -ve
    input   wire    [DATA_BYTES-1:0]    i_data,     
    input   wire    [DATA_BYTES-1:0]    i_datak,    //1=corresponding i_data bytes is a k character
    output  reg     [DATA_BYTES*10-1:0] o_data10,
    input   wire    [PIPELINE_BITS-1:0] i_pipeline, //for signals that need to travel with the data
    output  reg     [PIPELINE_BITS-1:0] o_pipeline
);


//_____________________________________________________________________________
//Declarations

    reg                             previous_run_disp;
    
    wire    [DATA_BYTES:0]          run_disp;   //Extra top bit maps to previous_run_disp
    wire    [DATA_BYTES*10-1:0]     data10;
    
    genvar                          n;



//_____________________________________________________________________________
//Main Body of code


    //=========================================================================
    //Create an encoder for each byte. Chain the disparity signals between 
    //encoders. Use a register for the running disparity signal on the first 
    //encoder. Set that running disparity to 0 (negative) when i_compliance is asserted
    
    assign      run_disp[DATA_BYTES]    =   previous_run_disp && !i_compliance;
    
    
    generate
    for(n=0;n<DATA_BYTES;n=n+1) begin: generate_single_byte_encoders
        
        encoder_8b10b_1byte enc (
            .i_data         (i_data[n*8+:8]     ),
            .i_datak        (i_datak[n]         ),
            .o_data10       (data10[n*10+:10]   ),
            .i_run_disp     (run_disp[n+1]      ),          
            .o_run_disp     (run_disp[n]        )
        );        
    end
    endgenerate


    //=========================================================================
    //Create registers for the outputs and the running disparity
    
    always @(posedge i_clk) begin
    
        //Previous run disparity saves the output running disparity of the last encoder
        //so it can be used on the next cycle
        if(i_rst)   previous_run_disp    <=  1'b0;
        else        previous_run_disp    <=  i_enable?  run_disp[0]: previous_run_disp;
                                                       

        
        //Register the output of the encoders to simplify timing
        if(i_rst)   o_data10            <=  {(DATA_BYTES*10){1'b0}};
        else        o_data10            <=  i_enable?   data10: o_data10;
        
        
        //The pipeline register keeps pipeline inputs in line with data input
        if(i_rst)   o_pipeline  <=  {PIPELINE_BITS{1'b0}};
        else        o_pipeline  <=  i_enable?   i_pipeline: o_pipeline;        
    end

endmodule