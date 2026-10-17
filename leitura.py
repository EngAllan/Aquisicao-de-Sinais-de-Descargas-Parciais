import serial
import time
from datetime import datetime

# Configurações da porta serial
porta = 'COM5'       
baudrate = 115200
timeout = 1

# Tempo máximo por arquivo (segundos)
tempo_por_arquivo = 60  

# Abre a conexão serial
ser = serial.Serial(porta, baudrate, timeout=timeout)
time.sleep(2)  # Aguarda a inicialização da serial

# Captura a data atual
data_hoje = datetime.now().strftime("%Y%m%d")

contador = 1  # Contador dos arquivos
capturando = False  # Flag para indicar se está dentro de uma captura

print(" Aguardando início de captura... (Ctrl+C para parar)")

try:
    while True: 
        nome_arquivo = f"C:\\Users\\Allan\\Desktop\\Id\\Azul_Isolador_{contador}.txt"
        arquivo = None
        inicio_arquivo = time.time()

        while (time.time() - inicio_arquivo) < tempo_por_arquivo:
            linha = ser.readline().decode('utf-8', errors='ignore').strip()

            if not linha:
                continue  # Nenhuma linha recebida, volta pro início

            if linha == "START":
                print(f"Início da captura detectado.")
                capturando = True

                # Abre novo arquivo para escrita
                arquivo = open(nome_arquivo, "w")

            elif linha == "END":
                print(f"Fim da captura detectado.")
                capturando = False

                if arquivo:
                    arquivo.close()
                    print(f" Arquivo {nome_arquivo} salvo.\n--- Aguardando nova captura ---")
                    contador += 1  # Incrementa contador para o próximo arquivo
                break  # Sai para começar um novo arquivo ou encerrar

            elif capturando:
                print(linha)
                if arquivo:
                    arquivo.write(linha + "\n")

        # Se estava capturando, mas tempo esgotou (não recebeu END)
        if capturando:
            print(f" Tempo máximo atingido para o arquivo {nome_arquivo}. Salvando mesmo assim.")
            if arquivo:
                arquivo.close()
                contador += 1
                capturando = False

except KeyboardInterrupt:
    print("\n Captura encerrada pelo usuário.")

finally:
    if ser.is_open:
        ser.close()
    print("Conexão serial encerrada.")
