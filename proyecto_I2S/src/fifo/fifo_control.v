module fifo_control (
    input wire Wr_En,
    input wire Rd_En,
    input wire count_eq_0,
    input wire count_gt_512,
    output reg write_mem,
    output reg inc_wr,
    output reg inc_rd,
    output reg inc_count,
    output reg dec_count,
    output wire Pausa,
    output wire Empty
);

    assign Empty = count_eq_0;
    assign Pausa = count_gt_512;

    always @(*) begin
        write_mem = 0;
        inc_wr    = 0;
        inc_rd    = 0;
        inc_count = 0;
        dec_count = 0;

        if (Wr_En) begin
            write_mem = 1;
            inc_wr    = 1;
        end

        if (Rd_En && !count_eq_0) begin
            inc_rd = 1;
        end

        if (Wr_En && !(Rd_En && !count_eq_0)) begin
            inc_count = 1;
        end
        else if (!Wr_En && (Rd_En && !count_eq_0)) begin
            dec_count = 1;
        end
    end

endmodule
