module datapath (
    input wire clk,
    input wire reset,
    input wire load_en,
    input wire shift_en,
    input wire comp_en,
    input wire sum_en,
    input wire [15:0] data_in,
    output reg [31:0] c_reg,
    output reg [4:0] count
);

    // Registro C de 32 bits
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            c_reg <= 32'b0;
            count <= 5'b0;
        end else begin
            if (load_en) begin
                // Cargar datos en C[31:16], C[15:0] a 0
                c_reg <= {data_in, 16'b0};
                count <= 5'd16; // Número de bits a procesar
            end
            else if (shift_en) begin
                // Shift left de 1 bit
                c_reg <= c_reg << 1;
                count <= count - 1;
            end
            else if (sum_en) begin
                // Sumar 3 a los dígitos BCD si son > 4
                if (c_reg[31:28] > 4) c_reg[31:28] <= c_reg[31:28] + 3;
                if (c_reg[27:24] > 4) c_reg[27:24] <= c_reg[27:24] + 3;
                if (c_reg[23:20] > 4) c_reg[23:20] <= c_reg[23:20] + 3;
                if (c_reg[19:16] > 4) c_reg[19:16] <= c_reg[19:16] + 3;
            end
        end
    end

endmodule