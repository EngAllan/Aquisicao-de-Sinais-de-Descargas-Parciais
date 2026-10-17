const int numBits = 12;

// Pinos utilizados para leitura paralela dos 12 bits provenientes da FPGA
const int dataPins[numBits] = {2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, A0};

// Sinal proveniente da FPGA que habilita a leitura dos dados
const int tr_enable = 8;

// Número de amostras da janela de aquisição
const int maxSamples = 195;

// Buffer local para armazenamento dos dados recebidos da FPGA
int dados[maxSamples];

int indice = 0;
bool leituraAtiva = false;

void setup() {

  // Comunicação serial com o computador
  Serial.begin(115200);

  // Configuração dos pinos do barramento de dados
  for (int i = 0; i < numBits; i++) {
    pinMode(dataPins[i], INPUT);
  }

  pinMode(tr_enable, INPUT);
}

void loop() {

  // Verifica se a FPGA habilitou a leitura
  bool estado_tr = digitalRead(tr_enable);

  if (estado_tr == HIGH) {

    leituraAtiva = true;

    if (indice < maxSamples) {

      // Reconstrói a palavra digital de 12 bits
      int valor = 0;

      for (int i = 0; i < numBits; i++) {
        int bit = digitalRead(dataPins[i]);
        valor |= (bit << i);
      }

      // Armazena a amostra no buffer
      dados[indice] = valor;
      indice++;
    }
  }

  // Quando o sinal retorna para LOW, transmite os dados armazenados
  if (estado_tr == LOW && leituraAtiva) {

    // Marcador de início da transmissão
    Serial.println("START");

    for (int i = 0; i < indice; i++) {

      // Conversão do código do ADC para a escala de tensão utilizada
      Serial.println(dados[i] / 409.5 - 5);
    }

    // Marcador de fim da transmissão
    Serial.println("END");

    // Prepara o sistema para a próxima aquisição
    indice = 0;
    leituraAtiva = false;
  }

  // Intervalo de 20 ms entre leituras (50 Hz)
  delay(20);
}