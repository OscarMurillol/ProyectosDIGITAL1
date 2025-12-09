module spi_datapath (
    input wire clk, rst,
    input wire cargar_7,
    input wire cargar_23,
    input wire restar_1,
    input wire sel_mosi,
    input wire shift_d,
    input wire gen_sclk,
    input wire miso,
    input wire [23:0] start_addr,
    output wire count_lt_0,
    output wire mosi,
    output wire sclk,
    output wire [7:0] data_out
);

    reg signed [5:0] count;
    reg [7:0] cmd;
    reg [23:0] addr;
    reg [7:0] D;
    reg miso_safe;

    always @(negedge clk) begin
        miso_safe <= miso;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            cmd   <= 8'h03;
            addr  <= 0;
            D     <= 0;
        end else begin
            if (cargar_7)       count <= 6'd7;
            else if (cargar_23) count <= 6'd23;
            else if (restar_1)  count <= count - 1;

            if (cargar_23) addr <= start_addr;
            else if (sel_mosi && restar_1) addr <= {addr[22:0], 1'b0};
            
            if (cargar_7 && !sel_mosi) cmd <= 8'h03;
            else if (!sel_mosi && restar_1) cmd <= {cmd[6:0], 1'b0};

            if (shift_d) D <= {D[6:0], miso_safe};
        end
    end

    assign count_lt_0 = (count < 0);
    assign mosi = (sel_mosi) ? addr[23] : cmd[7];
    assign data_out = D;
    assign sclk = (gen_sclk) ? ~clk : 1'b0;

endmodule
