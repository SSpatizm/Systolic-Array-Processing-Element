`timescale 1ns/1ps

module systolic_matmul_tb;

parameter DATA_WIDTH = 16;
parameter N = 4;

reg clk;
reg reset;
reg valid_in;

reg [DATA_WIDTH-1:0] a_in_row [0:N-1];
reg [DATA_WIDTH-1:0] b_in_col [0:N-1];

wire [2*DATA_WIDTH-1:0] c_out [0:N-1][0:N-1];
wire valid_out;

integer i,j,k, t;
//init
systolic_array_4x4 #(
    .N(N),
    .DATA_WIDTH(DATA_WIDTH)
) dut (
    .clk(clk),
    .reset(reset),
    .a_in_row(a_in_row),
    .b_in_col(b_in_col),
    .valid_in(valid_in),
    .c_out(c_out),
    .valid_out(valid_out)
);

always #5 clk = ~clk;

//a * B
reg [DATA_WIDTH-1:0] A [0:N-1][0:N-1];
reg [DATA_WIDTH-1:0] B [0:N-1][0:N-1];
reg [2*DATA_WIDTH-1:0] C_expected [0:N-1][0:N-1];

initial begin
    $dumpfile("4x4_matmul_dump.vcd");
    $dumpvars(0, systolic_matmul_tb);
end


initial begin

    clk = 0;
    reset = 1;
    valid_in = 0;

    for (i=0;i<N;i=i+1) begin
        a_in_row[i] = 0;
        b_in_col[i] = 0;
    end

    //generate mat
    for (i = 0; i < N; i = i + 1) begin
        for (j = 0; j < N; j = j + 1) begin
            A[i][j] = i + j + 1;
            B[i][j] = (i == j) ? 1 : 0; //only if equal to eachother(diag)
        end
    end

    // should be equal to a
    for (i = 0; i < N; i = i + 1) begin
        for (j = 0; j < N; j = j + 1) begin
            C_expected[i][j] = 0;
            for (k = 0; k < N; k = k + 1) begin
                C_expected[i][j] =
                    C_expected[i][j] + A[i][k] * B[k][j];
            end
        end
    end

    #20;
    reset = 0;

    valid_in = 1;
    //begin on negedge fuck
    for (t = 0; t < N + N - 1; t = t + 1) begin
        @(negedge clk);
        //a in row
        for (i = 0; i < N; i = i + 1) begin
            if (t >= i && (t-i) < N)
                a_in_row[i] = A[i][t-i];
            else
                a_in_row[i] = 0;
        end
        //bi in col
        for (j = 0; j < N; j = j + 1) begin
            if (t >= j && (t-j) < N)
                b_in_col[j] = B[t-j][j];
            else
                b_in_col[j] = 0;
        end
    end
        //finished!!!
    @(negedge clk); 
    valid_in = 0;
    //resert inputs
    for (i=0;i<N;i=i+1) begin
        a_in_row[i] = 0;
        b_in_col[i] = 0;
    end

    // wait for wave to finish
    repeat(12) @(posedge clk);

    // check result
    for (i = 0; i < N; i = i + 1) begin
        for (j = 0; j < N; j = j + 1) begin
            if (c_out[i][j] !== C_expected[i][j]) begin
                $display("C[%0d][%0d] got %0d expected %0d",
                i,j,c_out[i][j],C_expected[i][j]);
            end
            else begin
                $display("correct, C[%0d][%0d] = %0d",
                i,j,c_out[i][j]);
            end
        end
    end

    $finish;

end

endmodule