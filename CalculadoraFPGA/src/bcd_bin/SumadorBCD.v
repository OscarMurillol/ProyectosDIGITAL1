module bcd_adder (
    input wire [3:0] bcd_in,
    output wire [3:0] bcd_out
);

    // Sumar 3 al dígito BCD
    assign bcd_out = bcd_in - 4'd3;


endmodule