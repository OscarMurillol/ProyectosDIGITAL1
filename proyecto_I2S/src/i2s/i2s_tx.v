module i2s_tx (
    input wire clk, rst,
    input wire [15:0] fifo_out,
    input wire fifo_empty,
    output reg rd_en,
    output reg bclk, 
    output wire din, 
    output wire lrc
);

    localparam LIMIT = 18; 

    reg [7:0] tick;
    reg strobe;
    reg [4:0] cnt_lrc;
    reg [15:0] sreg;

    always @(posedge clk) begin
        if (rst) begin 
            tick <= 0; 
            bclk <= 0; 
            strobe <= 0; 
        end else begin
            strobe <= 0;
            if (tick >= LIMIT-1) begin
                tick <= 0;
                bclk <= ~bclk; 
                if (bclk == 1) strobe <= 1; 
            end else begin
                tick <= tick + 1;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            cnt_lrc <= 0;
            rd_en <= 0;
            sreg <= 0;
        end else if (strobe) begin
            cnt_lrc <= cnt_lrc + 1;
            
            rd_en <= 0; 
            if (cnt_lrc == 24 && !fifo_empty) begin
                rd_en <= 1; 
            end

            if (cnt_lrc == 0) begin
                sreg <= fifo_out;
            end else begin
                sreg <= {sreg[14:0], 1'b0}; 
            end
        end else begin
             rd_en <= 0; 
        end
    end

    assign lrc = cnt_lrc[4]; 
    assign din = (cnt_lrc[3:0] == 0) ? 1'b0 : sreg[15];

endmodule
