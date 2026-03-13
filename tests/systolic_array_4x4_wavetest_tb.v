`timescale 1ns/1ps

module systolic_array_4x4_tb;

    parameter DATA_WIDTH = 16;

    reg clk;
    reg reset;
    reg valid_in;

    reg  [DATA_WIDTH-1:0] a_in_row [0:3];
    reg  [DATA_WIDTH-1:0] b_in_col [0:3];

    wire [2*DATA_WIDTH-1:0] c_out [0:3][0:3];
    wire valid_out;

    systolic_array_4x4 #(
        .DATA_WIDTH(DATA_WIDTH)
    ) 
    dut (
        .clk(clk),
        .reset(reset),
        .a_in_row(a_in_row),
        .b_in_col(b_in_col),
        .valid_in(valid_in),
        .c_out(c_out),
        .valid_out(valid_out)
    );

    // Clock
    always #5 clk = ~clk;

    integer i;

    initial begin
        $dumpfile("4x4_dump.vcd");
        $dumpvars(0, systolic_array_4x4_tb);

        clk = 0;
        reset = 1;
        valid_in = 0;

        for (i = 0; i < 4; i = i + 1) begin
            a_in_row[i] = 0;
            b_in_col[i] = 0;
        end

        #20;
        reset = 0;

        // begin
        @(posedge clk);
        valid_in = 1;
        //mat a
        a_in_row[0] = 1;
        a_in_row[1] = 2;
        a_in_row[2] = 3;
        a_in_row[3] = 4;
        //mat b
        b_in_col[0] = 5;
        b_in_col[1] = 6;
        b_in_col[2] = 7;
        b_in_col[3] = 8;

        @(posedge clk);
        valid_in = 0;

        // wait like 12 times
        repeat (12) @(posedge clk);
        $display("Bottom-right PE C value: %d", c_out[3][3]);
        $finish;
    end

endmodule