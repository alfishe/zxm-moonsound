# CPLD Source Files

Source files for the EPM7032STC44 CPLD used in ZXM-MoonSound ZX-BUS cards.

## CPLD Details

| Parameter | Value |
|-----------|-------|
| Chip | Altera EPM7032STC44-10 |
| Package | 44-pin TQFP |
| Macrocells | 32 |
| I/O Pins | 36 |
| Speed grade | 10ns |
| Family | MAX 7000S |

## Function

The CPLD provides the bus interface between the ZX Spectrum and YMF278B:

- I/O port decoding:
  - 0x7E-0x7F: PCM/Wave registers
  - 0xC4-0xC7: FM registers
- YMF278B chip select generation (`CSYM`)
- Address translation (Z80 → YMF278B addressing)
- DOS mode handling (TR-DOS compatibility)
- IORQG bus contention control

## Directory Structure

```
cpld-sources/
├── v0100-original/            # Original board (2015-06-29)
│   ├── dd2.tdf                # Main AHDL source
│   ├── 2mux1.tdf              # 2:1 multiplexer component
│   ├── dd2.pof                # Programming Object File
│   ├── dd2.jed                # JEDEC programming file
│   └── ...                    # Quartus II project files
│
└── v0100-rev01/               # Revised board (2016-09-07)
    └── (same structure)
```

## Version Differences

### v0100-original (June 2015)
- First release for original ZXM-MoonSound board
- Address bus input: CA[7..0] (full 8 bits)
- YMF278B address output: YA[2..0] (3 bits)
- Single IRQ input: C_IRQ
- ENIO logic: `C_IORQ # ENDOS # !(C_M1 & C_MREQ)`

### v0100-rev01 (September 2016)
- Revised for rev01 board layout
- Address bus input: CA[7..1] (7 bits, CA0 removed)
- YMF278B address output: YA1, YA2 (2 separate pins)
- Dual IRQ inputs: C_IRQ0 (YMF278B), C_IRQ1 (second source)
- ENIO logic: `C_IORQ # ENDOS # !C_M1 # !C_MREQ` (different M1/MREQ handling)
- Reserved data bus pins CD[7..0] for future expansion

**Key logic differences:**
```ahdl
-- Original (v0100)
ENIO = C_IORQ # ENDOS # !(C_M1 & C_MREQ);

-- Rev01
ENIO = C_IORQ # ENDOS # !C_M1 # !C_MREQ;
```

## Source Files

| File | Description |
|------|-------------|
| `dd2.tdf` | Main design (AHDL - Altera HDL) |
| `2mux1.tdf` | 2:1 multiplexer component |
| `dd2.acf` | Assignment & Configuration File |
| `dd2.cnf` | Configuration database |
| `dd2.pin` | Pin assignment report |
| `dd2.fit` | Fitter report |
| `dd2.rpt` | Full compilation report |

## Programming Files

| File | Format | Usage |
|------|--------|-------|
| `dd2.pof` | Programming Object File | Direct JTAG (ByteBlaster/USB-Blaster) |
| `dd2.jed` | JEDEC | Universal programmers (TL866, etc.) |
| `dd2.jam` | JAM (ASCII) | Altera JAM Player |
| `dd2.jbc` | JAM Byte-Code | Compressed JAM |
| `dd2.sof` | SRAM Object File | Temporary programming |

## Compiling with Quartus II

### Requirements
- Altera Quartus II 9.1 or later (MAX II/MAX 7000S support)
- Quartus II Web Edition is sufficient (free)

### Build Steps

1. Open Quartus II
2. Create new project or open `dd2.acf`
3. Add source files:
   - `dd2.tdf` (main)
   - `2mux1.tdf` (component)
4. Set device: EPM7032STC44-10
5. Compile: Processing → Start Compilation
6. Output files appear in project directory

### Command Line Build

```bash
# Set up Quartus environment
source /opt/altera/quartus/settings.sh

# Compile
quartus_map dd2
quartus_fit dd2
quartus_asm dd2

# Generate JEDEC
quartus_cpf -c dd2.pof dd2.jed
```

## Programming the CPLD

### Using USB-Blaster (JTAG)

1. Connect USB-Blaster to JTAG header on board
2. Power on the ZXM-MoonSound card
3. Open Quartus Programmer
4. Add `dd2.pof` file
5. Select Program/Configure
6. Click Start

```bash
# Command line (Linux/macOS)
quartus_pgm -c USB-Blaster -m JTAG -o "p;dd2.pof"
```

### Using TL866 Universal Programmer

1. Open XGecu/MiniPRO software
2. Select IC: EPM7032STC44
3. Load `dd2.jed` file
4. Remove CPLD from board (if socketed) or use PLCC44 adapter
5. Insert into programmer
6. Click Program

### Using JAM Player (In-System)

```bash
# Using Quartus JAM Player
quartus_jli dd2.jam -a PROGRAM

# Using standalone JAM player
jam -arun -dDO_PROGRAM=1 dd2.jam
```

### JTAG Pin Header

| Pin | Signal |
|-----|--------|
| 1 | TCK |
| 2 | GND |
| 3 | TDO |
| 4 | VCC |
| 5 | TMS |
| 6 | (NC) |
| 7 | (NC) |
| 8 | (NC) |
| 9 | TDI |
| 10 | GND |

## I/O Port Decoding Logic

```
Port 0x7E-0x7F (PCM):
  CS7E_Sel = !(CA[7..1] == B"0111111")
  
Port 0xC4-0xC7 (FM):
  CSC4_Sel = !(CA[7..2] == B"110001")

Chip Select:
  CSYM = (CS7E_Sel & CSC4_Sel) # ENIO
```

## Troubleshooting

### No response from YMF278B
- Check CSYM signal with logic analyzer
- Verify JTAG programming completed successfully
- Check power supply to CPLD (3.3V)

### Wrong port responses
- Verify dd2.pof version matches board revision
- Check address bus connections

### Programming fails
- Ensure JTAG cable connections are correct
- Verify VCC present on CPLD
- Try reducing JTAG clock speed

## References

- [Altera MAX 7000S Family Datasheet](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/ds/m7000s.pdf)
- [Quartus II Handbook](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/qts/quartusii_handbook.pdf)
- [AHDL Reference Manual](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/lg/max2.pdf)
