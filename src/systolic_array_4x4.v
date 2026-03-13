`timescale 1ns/1ps

module systolic_array_4x4 #(
    parameter DATA_WIDTH = 16
)(
    input  wire                        clk,
    input  wire                        reset,

    // Input streams for A and B
    input  wire [DATA_WIDTH-1:0]       a_in_row [0:3], // row-wise A inputs
    input  wire [DATA_WIDTH-1:0]       b_in_col [0:3], // column-wise B inputs
    input  wire                        valid_in,

    // Output C matrix (each PE's c_out)
    output wire [2*DATA_WIDTH-1:0]     c_out [0:3][0:3],
    output wire                        valid_out
);
    wire [DATA_WIDTH-1:0] a_wire [0:3][0:3];
    wire [DATA_WIDTH-1:0] b_wire [0:3][0:3];
    wire valid_wire [0:3][0:3];

    genvar i;
    genvar j;
    for (i = 0; i < 4; i = i + 1) begin : ROW
        for (j = 0; j < 4; j = j + 1) begin : COL
            wire [DATA_WIDTH-1:0] a_in_local;
            wire [DATA_WIDTH-1:0] b_in_local;
            wire valid_in_local;
            //A
            if (j == 0)
                assign a_in_local = a_in_row[i];
            else
                assign a_in_local = a_wire[i][j-1];

            //B
            if (i == 0)
                assign b_in_local = b_in_col[j];
            else
                assign b_in_local = b_wire[i-1][j];

            //propagate
            if (i == 0 && j == 0)
                assign valid_in_local = valid_in;
            else if (j == 0)
                assign valid_in_local = valid_wire[i-1][j];
            else
                assign valid_in_local = valid_wire[i][j-1];
            //pe           
            pe #(
                .DATA_WIDTH(DATA_WIDTH)
            ) pe_inst (
                .clk(clk),
                .reset(reset),
                .a_in(a_in_local),
                .b_in(b_in_local),
                .valid_in(valid_in_local),
                .valid_out(valid_wire[i][j]),
                .a_out(a_wire[i][j]),
                .b_out(b_wire[i][j]),
                .c_out(c_out[i][j])
            );
        end
    end
    //end reached
    assign valid_out = valid_wire[3][3];

endmodule