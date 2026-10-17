# Aquisição-de-Sinais-de-Descargas-Parciais
Arquivos-fonte em SystemVerilog, C/C++ para Arduino e Python para aquisição, transferência e armazenamento de sinais de descargas parciais.

## Funcionamento

A FPGA Cyclone IV E EP4CE22F17C6 recebe as amostras de 12 bits do conversor analógico-digital. O PLL gera o clock de 65 MHz a partir da referência de 50 MHz. A lógica de trigger detecta quando a amostra ultrapassa o limiar configurado e controla o encerramento da aquisição.

As amostras armazenadas na FPGA são disponibilizadas sequencialmente ao Arduino. O Arduino converte os valores digitais em tensão e os transmite pela interface serial. O programa em Python recebe os dados e salva cada aquisição em um arquivo de texto.

## Arquivos

| Arquivo | Função |
| --- | --- |
| `Final(7).sv` | Integra o PLL, o controlador de trigger e a memória. |
| `PLL(5).v` | Configura o PLL para gerar o clock de 65 MHz. |
| `trigger_buffer(7).sv` | Detecta o trigger e controla o ponteiro de aquisição. |
| `simple_ram(7).sv` | Armazena as amostras e controla sua leitura sequencial. |
| `Exportacao_txt(5).ino` | Lê os dados da FPGA e os transmite pela interface serial. |
| `leitura(3).py` | Recebe os dados e salva os arquivos de texto. |

## Parâmetros principais

| Parâmetro | Valor |
| --- | --- |
| FPGA | Cyclone IV E EP4CE22F17C6 |
| Clock de referência | 50 MHz |
| Taxa de amostragem | 65 MS/s |
| Resolução das amostras | 12 bits |
| Número configurado de amostras | 195 |
| Janela nominal de aquisição | 3 µs |
| Limiar de trigger | 2400, em código digital do ADC |
| Comunicação serial | 115200 baud |

## Utilização

1. Inclua os módulos SystemVerilog/Verilog no projeto do Quartus e defina `Final` como módulo principal. Configure o dispositivo, a pinagem e as restrições de temporização conforme a montagem.
2. Grave o programa `Exportacao_txt(5).ino` no Arduino e conecte os sinais conforme os pinos definidos no programa.
3. Instale a dependência do programa Python:

   ```bash
   pip install pyserial
   ```

4. Ajuste a porta serial e o caminho de saída em `leitura(3).py`. Crie a pasta de destino antes de executar.
5. Execute o programa Python para receber as aquisições. As mensagens `START` e `END` delimitam os dados de cada registro.

## Formato dos dados

Cada aquisição é salva em um arquivo `.txt`, com um valor de tensão por linha, sem coluna de tempo. O eixo temporal pode ser reconstruído por `t[n] = n / 65e6`, com `n` iniciado em zero.

A conversão aplicada pelo Arduino é `V = codigo_ADC / 409.5 - 5`, correspondente à escala de −5 V a +5 V adotada no programa. Essa escala deve corresponder ao circuito utilizado.

## Base de dados

A base de dados pode ser solicitada ao autor por e-mail.
