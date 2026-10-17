module Final (
    input  logic        clk,         // Clock de entrada: 50 MHz
    input  logic        rst,
    input  logic [11:0] data_in,     // Dados provenientes do ADC

    output logic        clk_2,
    output logic        tr_enable = 0,
    output logic [11:0] data_out,    // Dados disponibilizados para leitura
    output logic        LED_trigger  // Indicação de trigger
);

    // 3 us de aquisição em 65 MS/s = 195 amostras
    localparam int SAMPLES = 195;

    // Limiar de detecção do trigger
    localparam logic [11:0] THRESHOLD_LEVEL = 12'd2400;

    logic clk_65mhz;
    logic pll_locked;

    // Sinais internos de interconexão
    logic [9:0] mem_address;
    logic       write_enable;
    logic       trigger_detected;
    logic       w_done;

    assign LED_trigger = trigger_detected;
    assign clk_2       = clk_65mhz;

    // PLL parametrizado para gerar 65 MHz a partir de 50 MHz
    PLL pll_inst (
        .inclk0(clk),
        .c0(clk_65mhz),
        .locked(pll_locked)
    );

    // Controle do trigger, endereçamento e janela de aquisição
    trigger_buffer #(
        .ADDR_WIDTH(10),
        .DATA_WIDTH(12),
        .THRESHOLD(THRESHOLD_LEVEL),
        .SAMPLES(SAMPLES)
    ) tb_inst (
        .clk(clk_65mhz),
        .rst(rst),
        .data_in(data_in),
        .done(w_done),

        .tr(tr_enable),
        .trigger(trigger_detected),
        .mem_addr(mem_address),
        .write_enable(write_enable)
    );

    // Memória para armazenamento das amostras adquiridas
    simple_ram #(
        .ADDR_WIDTH(10),
        .DATA_WIDTH(12),
        .SAMPLES(SAMPLES)
    ) mem_inst (
        .clk(clk_65mhz),
        .rst(rst),
        .we(write_enable),
        .addr(mem_address),
        .data_in(data_in),

        .done(w_done),
        .data_out(data_out)
    );

endmodule