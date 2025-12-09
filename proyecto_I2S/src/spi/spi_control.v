module spi_control (
    input wire clk, rst,
    input wire start,
    input wire pausa,
    input wire count_lt_0,
    output reg cs_n,
    output reg sel_mosi,
    output reg cargar_7,
    output reg cargar_23,
    output reg restar_1,
    output reg gen_sclk,
    output reg shift_d,
    output reg validar
);

    localparam INICIO      = 0;
    localparam SET_CMD     = 1;
    localparam ENVIO_CMD   = 2;
    localparam SET_ADDR    = 3;
    localparam ENVIO_ADDR  = 4;
    localparam SET_LECTURA = 5;
    localparam CHECK_PAUSA = 6;
    localparam LEER_BYTE   = 7;
    localparam VALIDAR     = 8;

    reg [3:0] state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= INICIO;
        else     state <= next_state;
    end

    always @(*) begin
        next_state = state;
        cs_n = 0; 
        sel_mosi = 0; 
        cargar_7 = 0; 
        cargar_23 = 0;
        restar_1 = 0; 
        gen_sclk = 0; 
        shift_d = 0; 
        validar = 0;

        case (state)
            INICIO: begin
                cs_n = 1;
                if (start) next_state = SET_CMD;
            end

            SET_CMD: begin
                cargar_7 = 1;
                next_state = ENVIO_CMD;
            end

            ENVIO_CMD: begin
                gen_sclk = 1;
                restar_1 = 1;
                if (count_lt_0) next_state = SET_ADDR;
            end

            SET_ADDR: begin
                sel_mosi = 1;
                cargar_23 = 1;
                next_state = ENVIO_ADDR;
            end

            ENVIO_ADDR: begin
                sel_mosi = 1;
                gen_sclk = 1;
                restar_1 = 1;
                if (count_lt_0) next_state = SET_LECTURA;
            end

            SET_LECTURA: begin
                cargar_7 = 1;
                next_state = CHECK_PAUSA;
            end

            CHECK_PAUSA: begin
                if (pausa) next_state = CHECK_PAUSA;
                else       next_state = LEER_BYTE;
            end

            LEER_BYTE: begin
                gen_sclk = 1;
                shift_d = 1;
                restar_1 = 1;
                if (count_lt_0) next_state = VALIDAR;
                else            next_state = CHECK_PAUSA;
            end

            VALIDAR: begin
                validar = 1;
                next_state = SET_LECTURA;
            end
        endcase
    end
endmodule
