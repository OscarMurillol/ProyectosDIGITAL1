module bin_to_bcd_converter (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [15:0] binary_in,  // Entrada binaria de 16 bits
    output reg [15:0] bcd_out,     // Salida BCD de 4 dígitos (16 bits)
    output reg done
);

    // Señales internas
    wire [31:0] shift_reg;         // Registro de desplazamiento
    wire [4:0] bit_count;
    wire load_en, shift_en, add_en;
    wire [3:0] current_state;
    
    // Instancias de los módulos
    bin2bcd_datapath datapath_inst (
        .clk(clk),
        .reset(reset),
        .load_en(load_en),
        .shift_en(shift_en),
        .add_en(add_en),
        .binary_in(binary_in),
        .shift_reg(shift_reg),
        .bit_count(bit_count)
    );
    
    bin2bcd_control control_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .bit_count(bit_count),
        .shift_reg(shift_reg),
        .load_en(load_en),
        .shift_en(shift_en),
        .add_en(add_en),
        .done(done),
        .current_state(current_state)
    );
    
    // Extraer resultado BCD (dígitos BCD en los nibbles superiores)
    always @(*) begin
        bcd_out = {shift_reg[31:28], shift_reg[27:24], 
                   shift_reg[23:20], shift_reg[19:16]};
    end

endmodule
