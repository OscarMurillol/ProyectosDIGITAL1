module top (
    input wire clk,
    input wire rst_n,
    input wire miso,
    output wire mosi,
    output wire cs_n,
    output wire i2s_bclk,
    output wire i2s_lrc,
    output wire i2s_din,
    output wire led_running
);

    wire rst = ~rst_n;
    
    // Temporizador de arranque (40ms)
    reg [19:0] start_timer;
    reg start_delayed;

    always @(posedge clk) begin
        if (rst) begin
            start_timer <= 0;
            start_delayed <= 0;
        end else begin
            if (start_timer < 20'd1000000) begin
                start_timer <= start_timer + 1;
                start_delayed <= 0;
            end else begin
                start_delayed <= 1;
            end
        end
    end

    wire [23:0] start_addr = 24'h200000; 

    wire [7:0] w_spi_byte;
    wire w_spi_valid;
    wire [15:0] w_asm_sample;
    wire w_asm_we;
    wire w_fifo_pausa;
    wire w_fifo_empty;
    wire [15:0] w_fifo_out;
    wire w_i2s_rd_en;
    wire w_internal_sclk;

    spi_flash_reader U_SPI (
        .clk(clk), 
        .rst(rst), 
        .start(start_delayed),
        .miso(miso), 
        .pausa(w_fifo_pausa),
        .start_addr(start_addr),
        .cs_n(cs_n), 
        .mosi(mosi), 
        .sclk(w_internal_sclk),
        .validar(w_spi_valid), 
        .data_out(w_spi_byte)
    );

    USRMCLK u_mclk (
        .USRMCLKI(w_internal_sclk),
        .USRMCLKTS(1'b0)
    );

    byte_assembler U_ASM (
        .clk(clk), 
        .rst(rst),
        .validar_in(w_spi_valid), 
        .D(w_spi_byte),
        .we_en(w_asm_we), 
        .sample(w_asm_sample)
    );

    fifo_top U_FIFO (
        .clk(clk), 
        .rst(rst),
        .wr_en(w_asm_we), 
        .rd_en(w_i2s_rd_en),
        .dato_in(w_asm_sample),
        .out(w_fifo_out), 
        .empty(w_fifo_empty), 
        .pausa(w_fifo_pausa)
    );

    i2s_tx U_I2S (
        .clk(clk), 
        .rst(rst),
        .fifo_out(w_fifo_out), 
        .fifo_empty(w_fifo_empty),
        .rd_en(w_i2s_rd_en),
        .bclk(i2s_bclk), 
        .din(i2s_din), 
        .lrc(i2s_lrc)
    );

endmodule
