module comparator (
    input wire [3:0] bcd_digit,
    output wire gt_4
);

    assign gt_4 = (bcd_digit > 7);

endmodule