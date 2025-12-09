module byte_assembler (
    input wire clk, rst,
    input wire validar_in,
    input wire [7:0] D,
    output reg we_en,
    output reg [15:0] sample
);

    reg [7:0] temp;
    reg flag;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            temp <= 0;
            flag <= 0;
            sample <= 0;
            we_en <= 0;
        end else begin
            we_en <= 0;

            if (validar_in) begin
                if (flag == 0) begin
                    temp <= D;
                    flag <= 1;
                end else begin
                    sample <= {D, temp};
                    we_en <= 1;
                    flag <= 0;
                end
            end
        end
    end
endmodule
