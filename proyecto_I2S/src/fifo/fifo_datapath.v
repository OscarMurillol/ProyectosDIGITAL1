module fifo_datapath (
    input wire clk, rst,
    input wire [15:0] Dato_In,
    output wire [15:0] Out,
    input wire write_mem,
    input wire inc_wr,
    input wire inc_rd,
    input wire inc_count,
    input wire dec_count,
    output wire count_eq_0,
    output wire count_gt_512
);

    parameter DEPTH = 1024;
    parameter PTR_WIDTH = 10;

    reg [15:0] MEM [0:DEPTH-1];
    reg [15:0] mem_out_reg;

    reg [PTR_WIDTH-1:0] wr_ptr;
    reg [PTR_WIDTH-1:0] rd_ptr;
    reg [PTR_WIDTH:0] count;

    always @(posedge clk) begin
        if (write_mem) begin
            MEM[wr_ptr] <= Dato_In;
        end
        mem_out_reg <= MEM[rd_ptr];
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
        end else begin
            if (inc_wr) wr_ptr <= wr_ptr + 1;
            if (inc_rd) rd_ptr <= rd_ptr + 1;

            if (inc_count)      count <= count + 1;
            else if (dec_count) count <= count - 1;
        end
    end

    assign Out = mem_out_reg;
    assign count_eq_0   = (count == 0);
    assign count_gt_512 = (count > 512);

endmodule
