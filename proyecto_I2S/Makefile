# --- DEFINICIONES DE ENTORNO ---
.PHONY: all clean test syn config config-flash help load-audio

# 1. NOMBRE DEL MÓDULO PRINCIPAL
top = top

# 2. LISTA DE TODOS LOS ARCHIVOS FUENTE
# Asegúrate de que todas las carpetas existan en src/
DESIGN = src/top.v \
         src/spi/spi_control.v \
         src/spi/spi_datapath.v \
         src/spi/spi_flash_reader.v \
         src/assembler/byte_assembler.v \
         src/fifo/fifo_control.v \
         src/fifo/fifo_datapath.v \
         src/fifo/fifo_top.v \
         src/i2s/i2s_control.v \
         src/i2s/i2s_datapath.v \
         src/i2s/i2s_tx.v

# 3. ARCHIVOS DE CONFIGURACIÓN
LPF = impl/pines.lpf
TB  = sim/top_tb.v

# 4. CARPETAS DE TRABAJO
DIR_BUILD = build
S = sim

# 5. NOMBRES DE ARCHIVOS GENERADOS
JSON = $(DIR_BUILD)/$(top).json
PNR  = $(DIR_BUILD)/$(top).pnr
BITSTREAM = $(DIR_BUILD)/$(top).bit

# 6. CONFIGURACIÓN DEL CABLE (FT232RL)
CABLE_ARGS = -c ft232RL --pins=TXD:CTS:DTR:RXD --freq 3000000 --verbose

# ==========================================
# REGLAS (COMANDOS)
# ==========================================

# Regla por defecto
all: syn

# Ayuda
help:
	@echo "Comandos disponibles:"
	@echo "  make syn           -> Sintetizar y crear el bitstream (.bit)"
	@echo "  make config        -> Subir diseño a la FPGA (RAM)"
	@echo "  make load-audio    -> Subir audio.bin (Desbloqueando Flash)"
	@echo "  make clean         -> Borrar archivos temporales"

# --- SÍNTESIS ---
syn: $(BITSTREAM)

# Paso 1: Verilog -> JSON (Yosys)
$(JSON): $(DESIGN)
	@mkdir -p $(DIR_BUILD)
	yosys -p "synth_ecp5 -top $(top) -json $(JSON)" $(DESIGN)

# Paso 2: Place & Route (Nextpnr)
# Usamos CABGA256 según tu placa
$(PNR): $(JSON) $(LPF)
	nextpnr-ecp5 --25k --package CABGA256 --speed 6 --json $(JSON) --lpf $(LPF) --textcfg $(PNR)

# Paso 3: Empaquetado (.bit)
$(BITSTREAM): $(PNR)
	ecppack $(PNR) $(BITSTREAM)

# --- CONFIGURACIÓN (SUBIDA) ---

# Subir a RAM (Rápido para probar)
config: $(BITSTREAM)
	openFPGALoader $(CABLE_ARGS) -m $(BITSTREAM)

# Subir a Flash (Permanente)
config-flash: $(BITSTREAM)
	openFPGALoader $(CABLE_ARGS) -f $(BITSTREAM) --unprotect-flash

# --- UTILIDAD DE AUDIO ---
# Sube el audio y desbloquea la flash para asegurar que se escriba
load-audio:
	openFPGALoader $(CABLE_ARGS) -f --offset 0x200000 --unprotect-flash audio.bin

# --- LIMPIEZA ---
clean:
	rm -rf $(DIR_BUILD) $(S)/*.vvp $(S)/*.vcd $(S)/*.txt
