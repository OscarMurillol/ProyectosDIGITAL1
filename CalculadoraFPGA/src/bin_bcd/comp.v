module bcd_ge5_comparator (
    input wire [3:0] bcd_digit,
    output wire ge_5
);

    assign ge_5 = (bcd_digit >= 4'd5);

endmodule
