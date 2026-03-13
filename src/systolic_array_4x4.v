module systolic_array_4x4 #(
    parameter N = 4,
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire reset,

    input wire [DATA_WIDTH-1:0] a_in_row [0:N-1],
    input wire [DATA_WIDTH-1:0] b_in_col [0:N-1],
    input wire valid_in,

    output wire [2*DATA_WIDTH-1:0] c_out [0:N-1][0:N-1],
    output wire valid_out
);

wire [DATA_WIDTH-1:0] a_wire [0:N-1][0:N-1];
wire [DATA_WIDTH-1:0] b_wire [0:N-1][0:N-1];
wire valid_wire [0:N-1][0:N-1];

genvar i,j;

generate
for (i = 0; i < N; i = i + 1) begin : rows
for (j = 0; j < N; j = j + 1) begin : cols

wire [DATA_WIDTH-1:0] a_in_sel;
wire [DATA_WIDTH-1:0] b_in_sel;
wire valid_in_sel;

if (j == 0)
    assign a_in_sel = a_in_row[i];
else
    assign a_in_sel = a_wire[i][j-1];

if (i == 0)
    assign b_in_sel = b_in_col[j];
else
    assign b_in_sel = b_wire[i-1][j];

//i finally fiexed it
if (j == 0)
    assign valid_in_sel = valid_in;
else
    assign valid_in_sel = valid_wire[i][j-1];

PE #(.DATA_WIDTH(DATA_WIDTH)) pe_inst (
    .clk(clk),
    .reset(reset),
    .a_in(a_in_sel),
    .b_in(b_in_sel),
    .valid_in(valid_in_sel),

    .a_out(a_wire[i][j]),
    .b_out(b_wire[i][j]),
    .valid_out(valid_wire[i][j]),
    .c_out(c_out[i][j])
);

end
end
endgenerate
assign valid_out = valid_wire[N-1][N-1];

endmodule