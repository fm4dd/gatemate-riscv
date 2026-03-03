.section .text
.globl wait

wait:
        li t0,5         # Load 5 as a wait multiplier for below
	slli t0, t0,17  # 5 * (2^17) = 655,360 iterations
.L0:       
        addi t0,t0,-1
	bnez t0, .L0
	ret
