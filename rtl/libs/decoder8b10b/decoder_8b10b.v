/*




//_____________________________________________________________________________
//Description
    * Performs standard 8B/10B decoding on DATA_BYTES octets of data
    * Reports not-in-table and disparity errors
    * Pipelines any signals that need to stay with the data
    
*/
//_____________________________________________________________________________
//Module declaration

`timescale 1ns/1ns

module decoder_8b10b #(
    parameter   DATA_BYTES      =   2,
    parameter   PIPELINE_BITS   =   1   
)
(
    input   wire                        i_clk,
    input   wire                        i_rst,          //synchronous active high
    input   wire                        i_enable,       //0=pause
    input   wire                        i_compliance,   //1=set running disparity -ve
    input   wire    [DATA_BYTES*10-1:0] i_data10,     
    input   wire    [DATA_BYTES-1:0]    o_datak,        //1=corresponding i_data bytes is a k character
    output  reg     [DATA_BYTES*8-1:0]  o_data,
    output  reg     [DATA_BYTES-1:0]    o_not_in_table,
    output  reg     [DATA_BYTES-1:0]    o_disp_err,
    input   wire    [PIPELINE_BITS-1:0] i_pipeline,     //for signals that need to travel with the data
    output  reg     [PIPELINE_BITS-1:0] o_pipeline
);


//_____________________________________________________________________________
//Declarations

    reg                             previous_run_disp;
    
    wire    [DATA_BYTES:0]          run_disp;   //Extra top bit maps to previous_run_disp
    wire    [DATA_BYTES*8-1:0]      data;
    wire    [DATA_BYTES-1:0]        datak;
    wire    [DATA_BYTES-1:0]        not_in_table;
    wire    [DATA_BYTES-1:0]        disp_err;
    
    genvar                          n;


//_____________________________________________________________________________
//Main Body of code


    //=========================================================================
    //Create a decoder for each byte. Chain the disparity signals between 
    //decoders. Use a register for the running disparity signal on the first 
    //encoder.
    
    assign      run_disp[DATA_BYTES]    =   previous_run_disp;
    
    
    generate
    for(n=0;n<DATA_BYTES;n=n+1) begin: generate_single_byte_decoders
        
        decoder_8b10b_1byte dec (
            .i_data10       (i_data[n*10+:10]   ),
            .o_datak        (datak[n]           ),
            .o_data         (data[n*8+:8]       ),
            .o_not_in_table (not_in_table[n]    ),
            .o_disp_err     (disp_err[n]        ),
            .i_run_disp     (run_disp[n+1]      ),          
            .o_run_disp     (run_disp[n]        )
        );        
    end
    endgenerate


    //=========================================================================
    //Create registers for the outputs and the running disparity
    
    always @(posedge i_clk) begin
    
        //Previous run disparity saves the output running disparity of the last decoder
        //so it can be used on the next cycle
        if(i_rst)   previous_run_disp    <=  1'b0;
        else        previous_run_disp    <=  i_enable?  run_disp[0]: previous_run_disp;
                                                       

        
        //Register the output of the decoders to simplify timing
        if(i_rst) begin
            o_data              <=  {(DATA_BYTES*10){1'b0}};
            o_datak             <=  {(DATA_BYTES){1'b0}};
            o_not_in_table      <=  {(DATA_BYTES){1'b0}};
            o_disp_err          <=  {(DATA_BYTES){1'b0}};
        end
        else begin        
            o_data              <=  i_enable?   data:           o_data;
            o_datak             <=  i_enable?   datak:          o_datak;
            o_not_in_table      <=  i_enable?   not_in_table:   o_not_in_table;
            o_disp_err          <=  i_enable?   disp_err:       o_disp_err;
        end
        
        
        //The pipeline register keeps pipeline inputs in line with data input
        if(i_rst)   o_pipeline  <=  {PIPELINE_BITS{1'b0}};
        else        o_pipeline  <=  i_enable?   i_pipeline: o_pipeline;        
    end

endmodule