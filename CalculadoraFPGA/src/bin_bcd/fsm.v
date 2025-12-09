module bin2bcd_control (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [4:0] bit_count,
    input wire [31:0] shift_reg,
    output reg load_en,
    output reg shift_en,
    output reg add_en,
    output reg done,
    output reg [3:0] current_state
);

    // Estados de la FSM
    localparam IDLE      = 4'd0;
    localparam LOAD      = 4'd1;
    localparam ADD_3     = 4'd2;
    localparam SHIFT     = 4'd3;
    localparam END_STATE = 4'd4;
    
    // Registro para próximo estado
    reg [3:0] next_state;
    
    // Variables para extraer dígitos BCD
    wire [3:0] bcd_digit3, bcd_digit2, bcd_digit1, bcd_digit0;
    wire needs_add3;
    
    assign {bcd_digit3, bcd_digit2, bcd_digit1, bcd_digit0} = shift_reg[31:16];
    
    // Detectar si algún dígito BCD necesita ajuste (>= 5)
    assign needs_add3 = (bcd_digit3 >= 5) || (bcd_digit2 >= 5) || 
                        (bcd_digit1 >= 5) || (bcd_digit0 >= 5);
    
    // Registro de estado
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Lógica del próximo estado y salidas
    always @(*) begin
        // Valores por defecto
        load_en = 0;
        shift_en = 0;
        add_en = 0;
        done = 0;
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (start) begin
                    next_state = LOAD;
                end
            end
            
            LOAD: begin
                load_en = 1;
                next_state = ADD_3;
            end
            
            ADD_3: begin
                // Verificar si necesita ajuste antes de shift
                if (needs_add3) begin
                    add_en = 1;
                    next_state = ADD_3;  // Permanece para aplicar add3
                end else begin
                    next_state = SHIFT;
                end
            end
            
            SHIFT: begin
                shift_en = 1;
                if (bit_count == 0) begin
                    next_state = END_STATE;
                end else begin
                    next_state = ADD_3;
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
