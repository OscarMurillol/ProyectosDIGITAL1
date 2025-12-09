module sqrt_datapath #(
  parameter WIDTH = 16
) ( input wire clk, input wire ld_data, input wire shift_r_d, input wire check_sub, input wire dec_count, input wire [WIDTH-1:0] D_in,
 output wire cont_es0 );
 
 reg [WIDTH-1:0] REG_D;
 reg [(WIDTH/2)-1:0] REG_Q;
 reg [(WIDTH/2)+1:0] REG_R;
 reg [4:0] count;
  //Es trabajo humilde, pero honesto...
