`timescale 1ns / 1ps

module top_tb;

    // Entradas al TOP
    reg clk;
    reg rst_n;
    reg miso;

    // Salidas del TOP
    wire mosi;
    wire cs_n;
    wire i2s_bclk;
    wire i2s_lrc;
    wire i2s_din;
    wire led_running;

    // Instancia del Módulo Principal
    top UUT (
        .clk(clk),
        .rst_n(rst_n),
        .miso(miso),
        .mosi(mosi),
        .cs_n(cs_n),
        .i2s_bclk(i2s_bclk),
        .i2s_lrc(i2s_lrc),
        .i2s_din(i2s_din),
        .led_running(led_running)
    );

    // Generador de Reloj (25 MHz -> 40ns periodo)
    initial begin
        clk = 0;
        forever #20 clk = ~clk;
    end

    // Simulación de la Memoria Flash (Responde 10101010)
    always @(negedge clk) begin
        if (!cs_n) begin
            // Cuando el chip está activo, enviamos datos falsos por MISO
            miso <= $random; 
        end else begin
            miso <= 0;
        end
    end

    // Proceso de Test
    initial begin
        $dumpfile("sim/system_test.vcd");
        $dumpvars(0, top_tb);

        // 1. Inicialización
        rst_n = 0; // Botón presionado (Reset)
        miso = 0;
        #100;
        
        // 2. Soltar Reset
        rst_n = 1; 

        // 3. TRUCO: Saltarnos la espera de 40ms
        // Forzamos el contador interno del TOP para que crea que ya pasó el tiempo
        // Accedemos a la variable interna usando el punto (.)
        force UUT.start_delayed = 1; 
        
        #200;
        // Ahora el timer debería desbordar y activar start_delayed
        
        // 4. Dejar correr para ver SPI e I2S
        #50000; // Correr suficiente tiempo para ver tramas I2S

        $finish;
    end

endmodule
module USRMCLK (
    input USRMCLKI,
    input USRMCLKTS
);
endmodule
