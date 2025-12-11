module sqrt_top #(
    parameter WIDTH = 16
)(
    input wire clk,
    input wire rst,     
    input wire start,   
    input wire [WIDTH-1:0] D, 
    
    output wire done,   
    output wire [WIDTH/2-1:0] Q /
);


    wire w_load_data;
    wire w_shift_r_d;
    wire w_check_sub;
    wire w_dec_count;
    wire w_count_is_0;


    sqrt_datapath #(
        .WIDTH(WIDTH)
    ) U_DATAPATH (
        .clk(clk),
        .rst(rst),
 
        .load_data(w_load_data),
        .shift_r_d(w_shift_r_d),
        .check_sub(w_check_sub),
        .dec_count(w_dec_count),
        .D_in(D),
        .Q_out(Q),
        .count_is_0(w_count_is_0)
    );

    sqrt_control U_CONTROL (
        .clk(clk),
        .rst(rst),
        .start(start),
        .count_is_0(w_count_is_0),
        .load_data(w_load_data),
        .shift_r_d(w_shift_r_d),
        .check_sub(w_check_sub),
        .dec_count(w_dec_count),
        .done(done)
    );

endmodule
