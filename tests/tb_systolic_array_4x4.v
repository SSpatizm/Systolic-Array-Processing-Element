`timescale 1ns/1ps

module systolic_matmul_tb;

    parameter DATA_WIDTH = 16;
    parameter N = 4;

    reg clk;
    reg reset;
    reg valid_in;

    reg  [DATA_WIDTH-1:0] a_in_row [0:N-1];
    reg  [DATA_WIDTH-1:0] b_in_col [0:N-1];

    wire [2*DATA_WIDTH-1:0] c_out [0:N-1][0:N-1];
    wire valid_out;

    integer i, j, k;

    // -----------------------------------------
    // Instantiate DUT
    // -----------------------------------------
    systolic_array_4x4 #(
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

    // -----------------------------------------
    // Clock
    // -----------------------------------------
    always #5 clk = ~clk;

    // -----------------------------------------
    // Matrices
    // -----------------------------------------
    reg [DATA_WIDTH-1:0] A [0:N-1][0:N-1];
    reg [DATA_WIDTH-1:0] B [0:N-1][0:N-1];
    reg [2*DATA_WIDTH-1:0] C_expected [0:N-1][0:N-1];

    // -----------------------------------------
    // Dump waves
    // -----------------------------------------
    initial begin
        $dumpfile("4x4_matmul_dump.vcd");
        $dumpvars(0, systolic_matmul_tb);
    end

    // -----------------------------------------
    // Main Test
    // -----------------------------------------
    initial begin

        clk = 0;
        reset = 1;
        valid_in = 0;

        // Initialize inputs
        for (i = 0; i < N; i = i + 1) begin
            a_in_row[i] = 0;
            b_in_col[i] = 0;
        end

        // -------------------------------------
        // Initialize A and B with small values
        // -------------------------------------
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                A[i][j] = i + j + 1;   // simple pattern
                B[i][j] = (i == j) ? 1 : 0;  // Identity matrix
            end
        end

        // -------------------------------------
        // Compute expected C in software
        // -------------------------------------
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                C_expected[i][j] = 0;
                for (k = 0; k < N; k = k + 1) begin
                    C_expected[i][j] =
                        C_expected[i][j] + A[i][k] * B[k][j];
                end
            end
        end

        // Release reset
        #20;
        reset = 0;

        // -------------------------------------
        // Stream matrices (k = 0..3)
        // -------------------------------------
        for (k = 0; k < N; k = k + 1) begin
            @(posedge clk);

            valid_in = 1;

            for (i = 0; i < N; i = i + 1)
                a_in_row[i] = A[i][k];

            for (j = 0; j < N; j = j + 1)
                b_in_col[j] = B[k][j];
        end

        // Stop feeding
        @(posedge clk);
        valid_in = 0;

        for (i = 0; i < N; i = i + 1) begin
            a_in_row[i] = 0;
            b_in_col[i] = 0;
        end

        // -------------------------------------
        // Wait for pipeline to flush
        // -------------------------------------
        repeat (12) @(posedge clk);

        // -------------------------------------
        // Compare results
        // -------------------------------------
        $display("Checking results...");

        integer errors;
        errors = 0;

        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                if (c_out[i][j] !== C_expected[i][j]) begin
                    $display("Mismatch at C[%0d][%0d]: got %0d expected %0d",
                             i, j, c_out[i][j], C_expected[i][j]);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("✅ MATRIX MULTIPLICATION PASSED");
        else
            $display("❌ MATRIX MULTIPLICATION FAILED (%0d errors)", errors);

        $finish;
    end

endmodule