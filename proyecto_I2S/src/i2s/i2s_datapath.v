module i2s_datapath (
    input wire clk, rst,
    input wire load_data,
    input wire shift_data,
    input wire [15:0] fifo_data,
    output wire strobe,
    output wire [4:0] cnt_lrc,
    output reg bclk,
    output wire lrc,
    output wire din
);

    localparam LIMIT = 18; 
    reg [7:0] tick;
    reg strobe_reg;
    reg [4:0] lrc_counter;
    reg [15:0] sreg;

    always @(posedge clk) begin
        if (rst) begin
            tick <= 0;
            bclk <= 0;
            strobe_reg <= 0;
        end else begin
            strobe_reg <= 0;
            if (tick >= LIMIT-1) begin
                tick <= 0;
                bclk <= ~bclk;
                if (bclk == 1) strobe_reg <= 1;
            end else begin
                tick <= tick + 1;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) lrc_counter <= 0;
        else if (strobe_reg) lrc_counter <= lrc_counter + 1;
    end

    always @(posedge clk) begin
        if (rst) sreg <= 0;
        else if (strobe_reg) begin
            if (load_data) sreg <= fifo_data;
            else if (shift_data) sreg <= {sreg[14:0], 1'b0};
        end
    end

    assign strobe = strobe_reg;
    assign cnt_lrc = lrc_counter;
    assign lrc = lrc_counter[4];
    assign din = (lrc_counter[3:0] == 0) ? 1'b0 : sreg[15];

endmodule
