module bin2bcd_datapath (
    input wire clk,
    input wire reset,
    input wire load_en,
    input wire shift_en,
    input wire add_en,
    input wire [15:0] binary_in,
    output reg [31:0] shift_reg,  // [31:16] BCD, [15:0] Binary remainder
    output reg [4:0] bit_count
);

    // Variables temporales para operaciones
    reg [31:0] next_shift_reg;
    reg [3:0] bcd3_temp, bcd2_temp, bcd1_temp, bcd0_temp;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 32'b0;
            bit_count <= 5'b0;
        end else begin
            if (load_en) begin
                // Inicializar: BCD en 0, binario en la parte baja
                shift_reg <= {16'b0, binary_in};
                bit_count <= 5'd16;  // 16 bits a procesar
            end
            else if (add_en) begin
                // Aplicar add-3 a cada dígito BCD si es necesario
                {bcd3_temp, bcd2_temp, bcd1_temp, bcd0_temp} = shift_reg[31:16];
                
                // Dígito 3 (miles)
                if (bcd3_temp >= 5) bcd3_temp = bcd3_temp + 3;
                // Dígito 2 (centenas)
                if (bcd2_temp >= 5) bcd2_temp = bcd2_temp + 3;
                // Dígito 1 (decenas)
                if (bcd1_temp >= 5) bcd1_temp = bcd1_temp + 3;
                // Dígito 0 (unidades)
                if (bcd0_temp >= 5) bcd0_temp = bcd0_temp + 3;
                
                shift_reg[31:16] <= {bcd3_temp, bcd2_temp, bcd1_temp, bcd0_temp};
            end
            else if (shift_en) begin
                // Shift left de todo el registro
                shift_reg <= {shift_reg[30:0], 1'b0};
                bit_count <= bit_count - 1;
            end
        end
    end

endmodule
