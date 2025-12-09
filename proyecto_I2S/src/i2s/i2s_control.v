module i2s_control (
    input wire strobe,
    input wire [4:0] cnt_lrc,
    input wire fifo_empty,
    output reg rd_en,
    output reg load_data,
    output reg shift_data
);

    always @(*) begin
        rd_en = 0;
        load_data = 0;
        shift_data = 0;

        if (strobe) begin
            if (cnt_lrc == 24 && !fifo_empty) begin
                rd_en = 1; 
            end

            if (cnt_lrc == 0) begin
                load_data = 1;
            end else begin
                shift_data = 1;
            end
        end
    end

endmodule
