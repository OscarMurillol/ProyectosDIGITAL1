# 🎵 Reproductor de Audio Digital (I2S + SPI Flash) en FPGA

Este proyecto consiste en la implementación de un sistema de reproducción de audio digital "mono" de 16 bits a 22.05 kHz. El sistema lee archivos de audio (.wav/mp3) en formato .bin almacenados en la memoria Flash SPI de la tarjeta FPGA y los transmite a un DAC externo (MAX98357A) utilizando el protocolo estándar I2S.

**Plataforma:** FPGA Colorlight 5A-75E (Lattice ECP5)
**Lenguaje:** Verilog HDL
**Herramientas:** Yosys, Nextpnr, OpenFPGALoader, GTKWave.

---

##  Arquitectura del Sistema

El diseño se ha estructurado de manera modular para garantizar la estabilidad de las señales y facilitar la depuración. A diferencia de un diseño monolítico, se separó la lógica de control del flujo de datos.

### Diagrama de Bloques Simplificado:
`SPI Flash` -> **[Lector SPI]** -> **[Ensamblador de Bytes]** -> **[FIFO]** -> **[Transmisor I2S]** -> `DAC`

### Descripción de Módulos:
1.  **Lector SPI (`spi_flash_reader`):** Implementa una Máquina de Estados Finitos (FSM) para enviar comandos de lectura (`0x03`) a la memoria Flash W25Qxx.
2.  **Ensamblador (`byte_assembler`):** Recibe dos bytes de 8 bits consecutivos desde el SPI y los concatena para formar una muestra de audio de 16 bits (Little Endian).
3.  **Buffer FIFO (`fifo_top`):** Una memoria intermedia vital que desacopla la velocidad de lectura (rápida y por ráfagas) de la velocidad de reproducción (lenta y constante).
4.  **Transmisor I2S (`i2s_tx`):** Genera los relojes `BCLK` y `LRC` y serializa los datos hacia el DAC.

---

##  Cambios de Diseño y Justificación Técnica

Durante la fase de implementación y pruebas, se realizaron ajustes críticos respecto a los diagramas iniciales para solucionar problemas de hardware real:

### 1. Implementación de Temporizador de Arranque (Start-Up Timer)
* **Problema:** Al energizar la FPGA, se escuchaba un ruido fuerte tipo "motor" o estática.
* **Causa:** La FPGA intentaba leer la memoria Flash inmediatamente (nanosegundos después del encendido), pero la Flash requiere un tiempo de "wake-up" interno.
* **Solución:** Se implementó un temporizador en `top.v` que mantiene el sistema en espera durante **40ms** antes de activar la señal `Chip Select`. Esto eliminó el ruido y garantizó la lectura correcta de los datos.

### 2. Separación Control vs. Datapath
* **Mejora:** Se dividieron los módulos complejos (SPI e I2S) en `_control.v` (FSM) y `_datapath.v` (Registros y Contadores).
* **Beneficio:** Esto permitió verificar matemáticamente los tiempos de los relojes en el Datapath sin interferencias de la lógica de estados, resultando en un reloj `BCLK` estable y sin *glitches*.

### 3. Sincronización I2S Matemática
* Se reemplazó la generación de reloj por estados por un contador exacto (`LIMIT = 18`) derivado del reloj de 25MHz.
* *Cálculo:* `25MHz / (22050Hz * 32bits * 2) ≈ 17.7` (Aproximado a 18 ciclos).

---

##  Simulaciones y Verificación

Se realizaron simulaciones funcionales (`make sim`) verificando el comportamiento antes de la síntesis.

### 1. Configuración de la Simulación
Se incluye el archivo **`sim/vista_final.gtkw`**. Para visualizar la simulación con las señales organizadas por colores y módulos, cargue este archivo en GTKWave.

### 2. Inicio de Transmisión (SPI)
En la siguiente captura se observa el comportamiento del **Temporizador de 40ms**. La señal `cs_n` (Chip Select) permanece en alto (inactiva) durante el inicio y cae a cero solo cuando el sistema es estable, iniciando el reloj `sclk`.

![Simulación Inicio SPI](sim_inicio.png)
*(Fig 1. Activación de la lectura tras el tiempo de espera)*

### 3. Protocolo I2S (Audio)
Se verifica la correcta relación de relojes. Por cada ciclo de `i2s_lrc` (Reloj Izquierda/Derecha), se generan 32 ciclos de `i2s_bclk` (Bit Clock), cumpliendo el estándar I2S. Los datos `i2s_din` cambian en el flanco de bajada de BCLK.

![Simulación Protocolo I2S](sim_audio.png)
*(Fig 2. Generación de relojes y serialización de datos)*

---

## 🔌Conexiones (Pinout)

Las conexiones físicas se realizan en el conector J1 de la Colorlight 5A-75E:

| Señal | Pin FPGA | Conexión DAC (MAX98357A) | Descripción |
| :--- | :--- | :--- | :--- |
| **i2s_bclk** | `C4` | **BCLK** | Reloj de Bit |
| **i2s_lrc** | `D4` | **LRC / LRCLK** | Selección de Canal (Word Select) |
| **i2s_din** | `E4` | **DIN** | Entrada de Datos Serial |
| **GND** | `GND` | **GND** | Tierra Común |
| **VCC** | `5V` | **VIN** | Alimentación |

---

##  Instrucciones de Ejecución

Este proyecto está automatizado mediante un `Makefile`.

1.  **Limpieza del proyecto:**
    ```bash
    make clean
    ```

2.  **Síntesis y Generación de Bitstream:**
    ```bash
    make syn
    ```

3.  **Carga del Archivo de Audio:**
    *Importante:* Este comando desbloquea los sectores de la Flash y carga el archivo `audio.bin` en la dirección `0x200000`.
    ```bash
    make load-audio
    ```

4.  **Configuración de la FPGA:**
    ```bash
    make config
    ```
