module bin_to_bcd_tb;

    // Señales de prueba
    reg clk;
    reg reset;
    reg start;
    reg [15:0] binary_in;
    wire [15:0] bcd_out;
    wire done;
    
    // Instancia del convertidor
    bin_to_bcd_converter dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .binary_in(binary_in),
        .bcd_out(bcd_out),
        .done(done)
    );
    
    // Generación de reloj (50 MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // Tareas auxiliares
    task apply_test;
        input [15:0] test_value;
        input [15:0] expected_bcd;
        begin
            binary_in = test_value;
            start = 1;
            @(posedge clk);
            start = 0;
            
            // Esperar a que termine
            wait(done == 1);
            @(posedge clk);
            
            // Verificar resultado
            if (bcd_out === expected_bcd) begin
                $display("[PASS] Binary %h -> BCD %h", test_value, bcd_out);
            end else begin
                $display("[FAIL] Binary %h -> Got %h, Expected %h", 
                         test_value, bcd_out, expected_bcd);
            end
            
            #20;
        end
    endtask
    
    // Procedimiento de prueba principal
    initial begin
        // Inicialización
        reset = 1;
        start = 0;
        binary_in = 16'h0;
        #40;
        
        reset = 0;
        #20;
        
        $display("=== Iniciando pruebas Binario a BCD ===");
        
        // Casos de prueba
        apply_test(16'd0,     16'h0000);    // 0 -> 0000
        apply_test(16'd1,     16'h0001);    // 1 -> 0001
        apply_test(16'd9,     16'h0009);    // 9 -> 0009
        apply_test(16'd10,    16'h0010);    // 10 -> 0010
        apply_test(16'd99,    16'h0099);    // 99 -> 0099
        apply_test(16'd100,   16'h0100);    // 100 -> 0100
        apply_test(16'd255,   16'h0255);    // 255 -> 0255
        apply_test(16'd999,   16'h0999);    // 999 -> 0999
        apply_test(16'd1234,  16'h1234);    // 1234 -> 1234
        apply_test(16'd4095,  16'h4095);    // 4095 -> 4095
        apply_test(16'd9999,  16'h9999);    // 9999 -> 9999
        
        // Casos límite
        apply_test(16'd65535, 16'h????);    // Máximo de 16 bits
        
        #50;
        $display("=== Pruebas completadas ===");
        $finish;
    end
    
    // Monitoreo en tiempo real
    initial begin
        $monitor("Time=%0t: State=%d, Start=%b, Binary=%h, BCD=%h, Done=%b, BitCount=%d",
                 $time, dut.control_inst.current_state, start, binary_in, 
                 bcd_out, done, dut.datapath_inst.bit_count);
    end
    
    // Timeout de seguridad
    initial begin
        #500000;
        $display("[ERROR] Timeout en la simulación");
        $finish;
    end

endmodule
