module simple_ram #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 12,
    parameter SAMPLES    = 195
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  we,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] data_in,

    output logic                  done = 0,
    output logic [DATA_WIDTH-1:0] data_out
);

    // Memória para armazenamento das amostras
    logic [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];

    // Controle da leitura sequencial
    logic [27:0]           counter  = 0;
    logic [ADDR_WIDTH-1:0] addr_out = 0;

    integer i;

    always_ff @(posedge clk or negedge rst) begin

        if (!rst) begin

            for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
                mem[i] <= 0;
            end

            addr_out <= 0;
            done     <= 0;
            counter  <= 0;
            data_out <= 0;

        end
        else begin

            // Armazena as amostras durante a aquisição
            if (!we) begin
                mem[addr] <= data_in;
                done <= 0;
            end

            // Após a captura, disponibiliza os dados sequencialmente
            else begin

                counter <= counter + 1;

                // Uma nova amostra é disponibilizada a cada 20 ms
                // considerando clock de 65 MHz
                if (counter == 1_300_000) begin
                    data_out <= mem[addr_out];
                    counter  <= 0;
                    addr_out <= addr_out + 1;
                end

                // Finaliza após a leitura das 195 amostras
                if (addr_out == SAMPLES) begin
                    done     <= 1;
                    counter  <= 0;
                    addr_out <= 0;
                    data_out <= 0;
                end

            end
        end
    end

endmodule