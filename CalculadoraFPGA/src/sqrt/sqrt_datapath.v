module sqrt_datapath #(
    parameter WIDTH = 16 
)(
    input wire clk,
    input wire rst,
    input wire load_data,    
    input wire shift_r_d,    
    input wire check_sub,    
    input wire dec_count,    

    input wire [WIDTH-1:0] D_in, 
    output wire [WIDTH/2-1:0] Q_out, 
    
    // Feedback al Control
    output wire count_is_0   
);

    
    reg [WIDTH-1:0]   REG_D; 
    reg [WIDTH/2-1:0] REG_Q; 
    reg [WIDTH/2+1:0] REG_R; 
    reg [4:0] count; 
    wire [WIDTH/2+1:0] test_val;
    assign test_val = {REG_Q, 2'b01}; 
    wire r_ge_test;
    assign r_ge_test = (REG_R >= test_val);



    always @(posedge clk or posedge rst) begin
        if (rst) begin
            REG_D <= 0;
            REG_R <= 0;
            REG_Q <= 0;
            count <= 0;
        end else begin
            

            if (load_data) begin
                REG_D <= D_in;
                REG_R <= 0;
                REG_Q <= 0;
                count <= WIDTH / 2; 
            end
            
            if (shift_r_d) begin
                REG_R <= {REG_R[WIDTH/2-1:0], REG_D[WIDTH-1:WIDTH-2]};
                // D se desplaza 2 a la izquierda
                REG_D <= {REG_D[WIDTH-3:0], 2'b00};
            end
            
            if (check_sub) begin
                if (r_ge_test) begin
                    REG_R <= REG_R - test_val;       
                    REG_Q <= {REG_Q[WIDTH/2-2:0], 1'b1}; // Q << 1, inserta 1
                end else begin
                    REG_Q <= {REG_Q[WIDTH/2-2:0], 1'b0}; // Q << 1, inserta 0
                end
            end
            
            if (dec_count) begin
                count <= count - 1;
            end
        end
    end

    // Salidas
    assign Q_out = REG_Q;
    assign count_is_0 = (count == 0); 

endmodule
