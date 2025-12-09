module control_unit (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [4:0] count,
    input wire [31:0] c_reg,
    output reg load_en,
    output reg shift_en,
    output reg comp_en,
    output reg sum_en,
    output reg done,
    output reg [3:0] state
);

    // Estados de la FSM
    localparam IDLE      = 4'd0;
    localparam LOAD      = 4'd1;
    localparam COMPARE   = 4'd2;
    localparam ADD       = 4'd3;
    localparam SHIFT     = 4'd4;
    localparam END_STATE = 4'd5;
    
    // Registro de estado
    reg [3:0] next_state;
    
    // Lógica de transición de estados
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Lógica del siguiente estado y salidas
    always @(*) begin
        // Valores por defecto
        load_en = 0;
        shift_en = 0;
        comp_en = 0;
        sum_en = 0;
        done = 0;
        next_state = state;
        
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = LOAD;
                end
            end
            
            LOAD: begin
                load_en = 1;
                next_state = COMPARE;
            end
            
            COMPARE: begin
                comp_en = 1;
                // Verificar si algún dígito BCD > 4
                if (c_reg[31:28] > 4 || c_reg[27:24] > 4 || 
                    c_reg[23:20] > 4 || c_reg[19:16] > 4) begin
                    next_state = ADD;
                end else begin
                    next_state = SHIFT;
                end
            end
            
            ADD: begin
                sum_en = 1;
                next_state = SHIFT;
            end
            
            SHIFT: begin
                shift_en = 1;
                if (count == 0) begin
                    next_state = END_STATE;
                end else begin
                    next_state = COMPARE;
                end
            end
            
            END_STATE: begin
                done = 1;
                if (!start) begin
                    next_state = IDLE;
                end
            end
            
            default: next_state = IDLE;
        endcase
    end

endmodule