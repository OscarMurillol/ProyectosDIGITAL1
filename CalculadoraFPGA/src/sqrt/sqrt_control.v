module sqrt_control (
    input wire clk,
    input wire rst,
    
    
    input wire start,       
    input wire count_is_0,  
    
    output reg load_data,
    output reg shift_r_d,
    output reg check_sub,
    output reg dec_count,
    output reg done
);

    localparam ST_IDLE_START = 3'd0; 
    localparam ST_SHIFT      = 3'd1; 
    localparam ST_CHECK      = 3'd2; 
    localparam ST_IDLE_LOOP  = 3'd3; 
    localparam ST_DONE       = 3'd4; 
    reg [2:0] state, next_state;


    always @(posedge clk or posedge rst) begin
        if (rst) state <= ST_IDLE_START;
        else     state <= next_state;
    end

    
    always @(*) begin
       
        next_state = state;
        load_data = 0; shift_r_d = 0; check_sub = 0; dec_count = 0; done = 0;

        case (state)
 
            ST_IDLE_START: begin
                load_data = 1; 
                
             
                if (start) next_state = ST_SHIFT;
                else       next_state = ST_IDLE_START;
            end

      
            ST_SHIFT: begin
                shift_r_d = 1; 
                
            
                next_state = ST_CHECK;
            end

            ST_CHECK: begin
                check_sub = 1; 
                
          
                next_state = ST_IDLE_LOOP;
            end

       
            ST_IDLE_LOOP: begin
                dec_count = 1; 
                
            
                if (count_is_0) begin
                    next_state = ST_DONE; 
                end else begin
                    next_state = ST_SHIFT; 
                end
            end

          
            ST_DONE: begin
                done = 1; 
                
           
                if (!start) next_state = ST_IDLE_START;
            end

            default: next_state = ST_IDLE_START;
        endcase
    end
endmodule
