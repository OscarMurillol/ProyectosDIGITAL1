module bcd_processor (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [15:0] data_in,
    output reg [15:0] data_out,
    output reg done
);

    // Señales internas
    wire [31:0] c_reg;
    wire [4:0] count;
    wire load_en, shift_en, comp_en, sum_en;
    wire [3:0] state;
    
    // Instancias de los módulos
    datapath datapath_inst (
        .clk(clk),
        .reset(reset),
        .load_en(load_en),
        .shift_en(shift_en),
        .comp_en(comp_en),
        .sum_en(sum_en),
        .data_in(data_in),
        .c_reg(c_reg),
        .count(count)
    );
    
    control_unit control_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .count(count),
        .c_reg(c_reg),
        .load_en(load_en),
        .shift_en(shift_en),
        .comp_en(comp_en),
        .sum_en(sum_en),
        .done(done),
        .state(state)
    );
    
    // Asignar salida (bits 31:16 del registro C)
    always @(*) begin
        data_out = c_reg[31:16];
    end

endmodule