`timescale 1ns/1ps

module pe_tb;
    parameter DATA_WIDTH = 16;
    reg clk;
    reg reset;
    reg [DATA_WIDTH-1:0] a_in;
    reg [DATA_WIDTH-1:0] b_in;
    reg valid_in;
    wire valid_out;
    wire [DATA_WIDTH-1:0] a_out;
    wire [DATA_WIDTH-1:0] b_out;
    wire [2*DATA_WIDTH-1:0] c_out;

    pe #(
        .DATA_WIDTH(DATA_WIDTH)
    ) 
    dut (
        .clk(clk),
        .reset(reset),
        .a_in(a_in),
        .b_in(b_in),
        .valid_in(valid_in),
        .valid_out(valid_out),
        .a_out(a_out),
        .b_out(b_out),
        .c_out(c_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("pe_dump.vcd");
        $dumpvars(0, pe_tb);
        clk = 0;
        reset = 1;
        valid_in = 0;
        a_in = 0;
        b_in = 0;

        //release reset
        #20;
        reset = 0;

        send_data(3, 4);   //12
        send_data(2, 5);   //10
        send_data(1, 7);   //7

        //done
        valid_in = 0;
        #50;
        $display("Final result = %d", c_out); //should be 50
        $finish;
    end
    //yeahhhh im a bit of a tasker myself liek among us
    task send_data;
        input [DATA_WIDTH-1:0] a;
        input [DATA_WIDTH-1:0] b;
        begin
            @(posedge clk);
            a_in <= a;
            b_in <= b;
            valid_in <= 1;
        end
    endtask

endmodule