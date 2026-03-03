# Computes and displays the Mandelbrot set on the terminal.
# Needs NRV_IO_UART to be enabled. 
#
# To access it, use:
#   miniterm.py --dtr=0 /dev/ttyUSB1 115200
#   or screen /dev/ttyUSB1 115200 (<ctrl> a \ to exit)

# Mandelbrot Set - High Resolution RV32I Assembly
# Optimized for a 120x60 Terminal Display

# --- IO Configuration ---
.equ IO_BASE, 0x400000  
.equ IO_LEDS, 4

# --- Fixed-Point Math Constants (10-bit fractional) ---
.equ mandel_shift, 10
.equ mandel_mul, (1 << mandel_shift)

# --- Resolution & Aspect Ratio Settings ---
# We use a 2:1 ratio (120x60) to compensate for tall terminal fonts.
.equ x_res, 120
.equ y_res, 60

# --- Framing the Complex Plane ---
# Standard Mandelbrot view: X from -2.1 to 0.6, Y from -1.2 to 1.2
.equ xmin, -21 * mandel_mul / 10
.equ xmax,   6 * mandel_mul / 10
.equ ymin, -12 * mandel_mul / 10
.equ ymax,  12 * mandel_mul / 10

# Calculate step size per character
.equ dx, (xmax-xmin)/x_res
.equ dy, (ymax-ymin)/y_res

.equ norm_max, (4 << mandel_shift)
.equ max_iter, 9

.section .text
.globl main

# Register Map:
# s0: x_pixel_counter | s1: y_pixel_counter
# s2: Cr (Real part)  | s3: Ci (Imag part)
# s4: Zr              | s5: Zi
# s6: Zrr             | s7: 2Zri
# s8: Zii             | s10: iteration_counter
# gp: IO_BASE         | a0: putchar argument

main:
mandelstart:
    # Heartbeat: Set LEDs at start of frame
    li   t0, 5
    sw   t0, IO_LEDS(gp)
    call wait
    li   t0, 10
    sw   t0, IO_LEDS(gp)
    call wait
    li   t0, 5
    sw   t0, IO_LEDS(gp)
    li   t0, 10
    sw   t0, IO_LEDS(gp)
    call wait
    li   t0, 0
    sw   t0, IO_LEDS(gp)

    li s1, 0              # Reset Y pixel counter
    li s3, ymin           # Start Ci at the top (ymin)

loop_y: 
    li s0, 0              # Reset X pixel counter
    li s2, xmin           # Start Cr at the left (xmin)
    
loop_x: 
    mv s4, s2             # Z_initial = C
    mv s5, s3             
    
    li s10, max_iter      # Start countdown from 9
    
loop_Z: 
    # 1. Zrr = (Zr * Zr) >> shift
    mv a0, s4
    mv a1, s4
    call __mulsi3
    srai s6, a0, mandel_shift
    
    # 2. 2Zri = (Zr * Zi) >> (shift - 1)
    mv a0, s4
    mv a1, s5
    call __mulsi3
    srai s7, a0, mandel_shift-1
    
    # 3. Zii = (Zi * Zi) >> shift
    mv a0, s5
    mv a1, s5
    call __mulsi3
    srai s8, a0, mandel_shift
    
    # 4. Zr = Zrr - Zii + Cr
    sub s4, s6, s8
    add s4, s4, s2
    
    # 5. Zi = 2Zri + Ci
    add s5, s7, s3

    # 6. Escape Check: if (Zrr + Zii) > 4.0
    add t1, s6, s8
    li  t2, norm_max
    bgt t1, t2, exit_Z

    addi s10, s10, -1     # Iteration countdown
    bnez s10, loop_Z

exit_Z:
    # Character selection: colormap[s10]
    la  a0, colormap
    add a0, a0, s10
    lbu a0, 0(a0)
    call putchar
    
    addi s0, s0, 1        # Next X pixel
    add  s2, s2, dx       # Move Cr right
    li   t3, x_res
    blt  s0, t3, loop_x

    # Row End: Send Line Feed (\n)
    # Note: \r (13) is handled by terminal.sh/picocom --imap
    li a0, 10
    call putchar

    addi s1, s1, 1        # Next Y line
    add  s3, s3, dy       # Move Ci down
    li   t3, y_res
    blt  s1, t3, loop_y
    
    # Frame End: Clear LEDs and loop
    li   t0, 0
    sw   t0, IO_LEDS(gp)
    call wait             # Pause 1 before moving on
    call wait             # Pause 2 before moving on
    call wait             # Pause 3 before moving on
    j mandelstart

.section .data
.align 4
# Original Colormap mapped to countdown s10
# Inside Set (s10=0)  -> '@' (Dense)
# Far Outside (s10=9) -> ' ' (Space)
colormap:
.ascii " .,:;ox%#@"
