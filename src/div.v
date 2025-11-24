module division_entera #(
parameter N = 8
)(
input wire clk,
input wire rst,
input wire start,
input wire [N-1:0] A,
input wire [N-1:0] B,
output reg [N-1:0] Q,
output reg [N-1:0] R,
output reg done
);
reg [N-1:0] B_reg;
reg [2*N-1:0] A_ext;
reg [N-1:0] count;
reg [1:0] state;
localparam IDLE = 2'b00;
localparam CALC = 2'b01;
localparam DONE = 2'b10;
wire [2*N-1:0] shifted_A = {A_ext[2*N-2:0], 1'b0};
wire [N-1:0] upper_part = shifted_A[2*N-1:N];
wire cabe = (upper_part >= B_reg);
wire [N-1:0] diff = upper_part - B_reg;
wire [2*N-1:0] next_A_val;
assign next_A_val = cabe ? {diff, shifted_A[N-1:1], 1'b1} : shifted_A;
always @(posedge clk or posedge rst) begin
if (rst) begin
state <= IDLE;
done <= 0;
Q <= 0;
R <= 0;
count <= 0;
A_ext <= 0;
B_reg <= 0;
end else begin
case (state)
IDLE: begin
done <= 0;
if (start) begin
B_reg <= B;
count <= N;
A_ext <= {{N{1'b0}}, A};
state <= CALC;
end
end
CALC: begin
A_ext <= next_A_val;
count <= count - 1;
if (count == 1) begin
state <= DONE;
end
end
DONE: begin
done <= 1;
Q <= A_ext[N-1:0];
R <= A_ext[2*N-1:N];
if (!start) begin
state <= IDLE;
end
end
endcase
end
end
endmodule
