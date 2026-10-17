module trigger_buffer #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 12,
    parameter THRESHOLD  = 12'd2400,
    parameter SAMPLES    = 195
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic                  done,

    output logic                  tr           = 0,
    output logic                  trigger      = 0,
    output logic [ADDR_WIDTH-1:0] mem_addr     = 0,
    output logic                  write_enable = 0
);

    // Ponteiro de escrita do buffer
    logic [ADDR_WIDTH-1:0] wr_ptr = 0;

    // Indica a ocorrência do trigger
    logic triggered = 0;

    // Controle do intervalo entre aquisições
    logic [22:0] delay_counter = 0;
    logic        waiting_delay = 0;

    assign trigger  = triggered;
    assign mem_addr = wr_ptr;

    always_ff @(posedge clk or negedge rst) begin

        if (!rst) begin
            wr_ptr        <= 0;
            triggered     <= 0;
            write_enable  <= 0;
            tr            <= 0;
            delay_counter <= 0;
            waiting_delay <= 0;
        end

        // Intervalo entre aquisições consecutivas
        else if (waiting_delay) begin

            // 1.625.000 ciclos a 65 MHz = 25 ms
            if (delay_counter == 1_625_000) begin
                waiting_delay <= 0;
                delay_counter <= 0;
            end
            else begin
                delay_counter <= delay_counter + 1;
            end
        end

        // Reinicia o sistema após a leitura dos dados armazenados
        else if (done && write_enable) begin
            wr_ptr        <= 0;
            triggered     <= 0;
            write_enable  <= 0;
            tr            <= 0;
            waiting_delay <= 1;
            delay_counter <= 0;
        end

        // Antes do trigger, mantém o buffer circular
        else if (!triggered) begin

            wr_ptr <= wr_ptr + 1;

            // Detecção do trigger por comparação com o limiar
            if (data_in > THRESHOLD) begin
                triggered <= 1;
                tr        <= 1;
            end

            // Mantém aproximadamente 1/3 da janela para pré-trigger
            if (wr_ptr > (SAMPLES - 2*SAMPLES/3)) begin
                wr_ptr <= 0;
            end
        end

        // Após o trigger, completa a janela de aquisição
        else begin

            if (wr_ptr <= SAMPLES) begin
                wr_ptr <= wr_ptr + 1;
            end
            else begin
                write_enable <= 1;
            end
        end

    end

endmodule