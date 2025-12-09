module bcd_add3_adjust (
    input wire [3:0] bcd_in,
    output reg [3:0] bcd_out
);

    always @(*) begin
        if (bcd_in > 4) begin
            bcd_out = bcd_in + 3;
        end else begin
            bcd_out = bcd_in;
        end
    end

endmodule
