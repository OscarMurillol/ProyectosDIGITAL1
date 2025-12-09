module fifo_top (
    input wire clk, rst,
    input wire wr_en,
    input wire rd_en,
    input wire [15:0] dato_in,
    output wire [15:0] out,
    output wire empty,
    output wire pausa
);

    wire w_inc_wr, w_inc_rd, w_write_mem;
    wire w_inc_count, w_dec_count;
    wire w_count_eq_0, w_count_gt_512;

    fifo_control U_CONTROL (
        .Wr_En(wr_en), 
        .Rd_En(rd_en),
        .count_eq_0(w_count_eq_0),
        .count_gt_512(w_count_gt_512),
        .write_mem(w_write_mem),
        .inc_wr(w_inc_wr),
        .inc_rd(w_inc_rd),
        .inc_count(w_inc_count),
        .dec_count(w_dec_count),
        .Pausa(pausa),
        .Empty(empty)
    );

    fifo_datapath U_DATAPATH (
        .clk(clk), 
        .rst(rst),
        .Dato_In(dato_in),
        .Out(out),
        .write_mem(w_write_mem),
        .inc_wr(w_inc_wr),
        .inc_rd(w_inc_rd),
        .inc_count(w_inc_count),
        .dec_count(w_dec_count),
        .count_eq_0(w_count_eq_0),
        .count_gt_512(w_count_gt_512)
    );

endmodule
