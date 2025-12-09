module spi_flash_reader (
    input wire clk, rst, start,
    input wire miso,
    input wire pausa,
    input wire [23:0] start_addr,
    
    output reg cs_n,
    output reg mosi,
    output reg sclk,
    output reg validar,
    output reg [7:0] data_out
);

    localparam IDLE = 0;
    localparam SEND_CMD = 1;
    localparam SEND_ADDR = 2;
    localparam READ_LOOP = 3;

    reg [1:0] state;
    reg [4:0] bit_cnt;
    reg [7:0] cmd_reg;
    reg [23:0] addr_reg;
    reg [7:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            cs_n <= 1; mosi <= 0; sclk <= 0;
            validar <= 0; data_out <= 0;
            bit_cnt <= 0;
        end else begin
            
            if (state == READ_LOOP && pausa) begin
                validar <= 0;
            end 
            else begin
                case (state)
                    IDLE: begin
                        cs_n <= 1;
                        validar <= 0;
                        if (start) begin
                            cs_n <= 0;
                            state <= SEND_CMD;
                            cmd_reg <= 8'h03;
                            bit_cnt <= 7;
                            addr_reg <= start_addr;
                            sclk <= 0;
                        end
                    end

                    SEND_CMD: begin
                        sclk <= ~sclk;
                        if (sclk == 0) begin
                            mosi <= cmd_reg[bit_cnt[2:0]];
                        end else begin
                            if (bit_cnt == 0) begin
                                state <= SEND_ADDR;
                                bit_cnt <= 23;
                            end else begin
                                bit_cnt <= bit_cnt - 1;
                            end
                        end
                    end

                    SEND_ADDR: begin
                        sclk <= ~sclk;
                        if (sclk == 0) begin
                            mosi <= addr_reg[bit_cnt];
                        end else begin
                            if (bit_cnt == 0) begin
                                state <= READ_LOOP;
                                bit_cnt <= 7;
                            end else begin
                                bit_cnt <= bit_cnt - 1;
                            end
                        end
                    end

                    READ_LOOP: begin
                        sclk <= ~sclk;
                        validar <= 0;
                        
                        if (sclk == 0) begin
                             
                        end else begin
                             shift_reg <= {shift_reg[6:0], miso};
                             if (bit_cnt == 0) begin
                                 data_out <= {shift_reg[6:0], miso};
                                 validar <= 1;
                                 bit_cnt <= 7;
                             end else begin
                                 bit_cnt <= bit_cnt - 1;
                             end
                        end
                    end
                endcase
            end
        end
    end
endmodule
