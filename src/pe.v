module pe #(parameter DATA_WIDTH = 16)
(
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH-1:0] a_in,
    input wire [DATA_WIDTH-1:0] b_in,
    input wire valid_in,
    output reg valid_out,
    output reg [DATA_WIDTH-1:0] a_out,
    output reg [DATA_WIDTH-1:0] b_out,
    output reg [2*DATA_WIDTH-1:0] c_out
);

    wire [2*DATA_WIDTH-1:0] mult; //balatro
    //mult
    assign mult = a_in * b_in;

    //keep moving 
    always @(posedge clk) begin
        if (reset) begin
            c_out <= 0;
            valid_out <= 0;
        end
        else begin
            a_out <= a_in;
            b_out <= b_in;
            valid_out <= valid_in;

            if (valid_in) begin
                c_out <= c_out + mult;  //add chips due to chips * mult
            end
        end
    end

endmodule