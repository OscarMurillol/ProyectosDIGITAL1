`timescale 1ns / 1ps

module tb_division_entera;

    parameter N = 8;

    reg clk;
    reg rst;
    reg start;
    reg [N-1:0] A;
    reg [N-1:0] B;
    wire [N-1:0] Q;
    wire [N-1:0] R;
    wire done;

    division_entera #(.N(N)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .Q(Q),
        .R(R),
        .done(done)
    );

    // Reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        #2000;
        $display("ERROR CRÍTICO: La simulación se colgó (Timeout).");
        $display("Revisa si el contador está bajando o si entraste al estado CALC.");
        $finish;
    end

    initial begin
        $monitor("Tiempo: %t | Estado: %d | Count: %d | A_ext: %b | Done: %b", 
                 $time, dut.state, dut.count, dut.A_ext, done);
    end

    // Pruebas
    initial begin
        $dumpfile("division.vcd");
        $dumpvars(0, tb_division_entera);

        // Reset
        rst = 1; start = 0; A = 0; B = 0;
        #20;
        rst = 0;
        #20;

        // Prueba: 15 / 4
        $display("--- Iniciando Prueba 15/4 ---");
        A = 8'd15;
        B = 8'd4;
        start = 1; 
        #10; // Pulso de start
        start = 0;

        // Esperamos (pero el Timeout nos salvará si falla)
        wait(done);
        
        $display(">>> ÉXITO: Resultado 15/4 -> Q: %d, R: %d", Q, R);
        $finish;
    end

endmodule
