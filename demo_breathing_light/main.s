	.file	"main.c"
	.option nopic
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	li	a5,1242566656
	lw	a3,0(a5)
	li	a5,1242566656
	li	a4,8192
	or	a4,a3,a4
	sw	a4,0(a5)
	li	a5,850
	sw	a5,-44(s0)
.L14:
	sw	zero,-20(s0)
	j	.L2
.L7:
	li	a5,1242566656
	addi	a5,a5,8
	lw	a3,0(a5)
	li	a5,1242566656
	addi	a5,a5,8
	li	a4,8192
	or	a4,a3,a4
	sw	a4,0(a5)
	sw	zero,-24(s0)
	j	.L3
.L4:
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L3:
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	blt	a4,a5,.L4
	li	a5,1242566656
	addi	a5,a5,8
	lw	a3,0(a5)
	li	a5,1242566656
	addi	a5,a5,8
	li	a4,-8192
	addi	a4,a4,-1
	and	a4,a3,a4
	sw	a4,0(a5)
	sw	zero,-28(s0)
	j	.L5
.L6:
	lw	a5,-28(s0)
	addi	a5,a5,1
	sw	a5,-28(s0)
.L5:
	lw	a4,-44(s0)
	lw	a5,-20(s0)
	sub	a5,a4,a5
	lw	a4,-28(s0)
	blt	a4,a5,.L6
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	lw	a4,-20(s0)
	lw	a5,-44(s0)
	blt	a4,a5,.L7
	lw	a5,-44(s0)
	sw	a5,-32(s0)
	j	.L8
.L13:
	li	a5,1242566656
	addi	a5,a5,8
	lw	a3,0(a5)
	li	a5,1242566656
	addi	a5,a5,8
	li	a4,8192
	or	a4,a3,a4
	sw	a4,0(a5)
	lw	a5,-32(s0)
	sw	a5,-36(s0)
	j	.L9
.L10:
	lw	a5,-36(s0)
	addi	a5,a5,-1
	sw	a5,-36(s0)
.L9:
	lw	a5,-36(s0)
	bgtz	a5,.L10
	li	a5,1242566656
	addi	a5,a5,8
	lw	a3,0(a5)
	li	a5,1242566656
	addi	a5,a5,8
	li	a4,-8192
	addi	a4,a4,-1
	and	a4,a3,a4
	sw	a4,0(a5)
	lw	a4,-44(s0)
	lw	a5,-32(s0)
	sub	a5,a4,a5
	sw	a5,-40(s0)
	j	.L11
.L12:
	lw	a5,-40(s0)
	addi	a5,a5,-1
	sw	a5,-40(s0)
.L11:
	lw	a5,-40(s0)
	bgtz	a5,.L12
	lw	a5,-32(s0)
	addi	a5,a5,-1
	sw	a5,-32(s0)
.L8:
	lw	a5,-32(s0)
	bgtz	a5,.L13
	j	.L14
	.size	main, .-main
	.ident	"GCC: (GNU MCU Eclipse RISC-V Embedded GCC, 64-bit) 8.2.0"
