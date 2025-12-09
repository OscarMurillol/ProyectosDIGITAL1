module bcd_processor_tb;

    // Señales de prueba
    reg clk;
    reg reset;
    reg start;
    reg [15:0] data_in;
    wire [15:0] data_out;
    wire done;
    
    // Instancia del DUT
    bcd_processor dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(data_in),
        .data_out(data_out),
        .done(done)
    );
    
    // Generación de reloj (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Procedimiento de prueba
    initial begin
        // Inicialización
        reset = 1;
        start = 0;
        data_in = 16'h0;
        #20;
        
        reset = 0;
        #10;
        
        // Caso de prueba 1: Valor BCD
        data_in = 16'h1234; // BCD: 1234
        start = 1;
        #10;
        start = 0;
        
        // Esperar a que termine
        wait(done == 1);
        #20;
        
        // Caso de prueba 2: Otro valor
        data_in = 16'h5678;
        start = 1;
        #10;
        start = 0;
        
        wait(done == 1);
        #50;
        
        $finish;
    end
    
    // Monitoreo
    initial begin
        $monitor("Time=%0t: start=%b, data_in=%h, data_out=%h, done=%b",
                 $time, start, data_in, data_out, done);
    end

endmodule