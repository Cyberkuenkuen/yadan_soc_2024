
main.elf:     file format elf32-littleriscv


Disassembly of section .vectors:

00000000 <_startup>:
   0:	0580006f          	j	58 <_stext>
   4:	00000013          	nop
   8:	00000013          	nop
   c:	00000013          	nop
  10:	00000013          	nop
  14:	00000013          	nop
  18:	00000013          	nop
  1c:	00000013          	nop
  20:	00000013          	nop
  24:	00000013          	nop
  28:	00000013          	nop
  2c:	00000013          	nop
  30:	00000013          	nop
  34:	00000013          	nop
  38:	00000013          	nop
  3c:	00000013          	nop
  40:	00000013          	nop
  44:	00000013          	nop
  48:	00000013          	nop
  4c:	00000013          	nop
  50:	00000013          	nop
  54:	00000013          	nop

Disassembly of section .text:

00000058 <_stext>:
  58:	30501073          	csrw	mtvec,zero
  5c:	00000093          	li	ra,0
  60:	00008113          	mv	sp,ra
  64:	00008193          	mv	gp,ra
  68:	00008213          	mv	tp,ra
  6c:	00008293          	mv	t0,ra
  70:	00008313          	mv	t1,ra
  74:	00008393          	mv	t2,ra
  78:	00008413          	mv	s0,ra
  7c:	00008493          	mv	s1,ra
  80:	00008513          	mv	a0,ra
  84:	00008593          	mv	a1,ra
  88:	00008613          	mv	a2,ra
  8c:	00008693          	mv	a3,ra
  90:	00008713          	mv	a4,ra
  94:	00008793          	mv	a5,ra
  98:	00008813          	mv	a6,ra
  9c:	00008893          	mv	a7,ra
  a0:	00008913          	mv	s2,ra
  a4:	00008993          	mv	s3,ra
  a8:	00008a13          	mv	s4,ra
  ac:	00008a93          	mv	s5,ra
  b0:	00008b13          	mv	s6,ra
  b4:	00008b93          	mv	s7,ra
  b8:	00008c13          	mv	s8,ra
  bc:	00008c93          	mv	s9,ra
  c0:	00008d13          	mv	s10,ra
  c4:	00008d93          	mv	s11,ra
  c8:	00008e13          	mv	t3,ra
  cc:	00008e93          	mv	t4,ra
  d0:	00008f13          	mv	t5,ra
  d4:	00008f93          	mv	t6,ra
  d8:	00104117          	auipc	sp,0x104
  dc:	f2810113          	addi	sp,sp,-216 # 104000 <_stack_start>

000000e0 <_start>:
  e0:	00100d17          	auipc	s10,0x100
  e4:	f20d0d13          	addi	s10,s10,-224 # 100000 <_data_ram>
  e8:	00100d97          	auipc	s11,0x100
  ec:	f18d8d93          	addi	s11,s11,-232 # 100000 <_data_ram>
  f0:	01bd5863          	bge	s10,s11,100 <zero_loop_end>

000000f4 <zero_loop>:
  f4:	000d2023          	sw	zero,0(s10)
  f8:	004d0d13          	addi	s10,s10,4
  fc:	ffaddce3          	bge	s11,s10,f4 <zero_loop>

00000100 <zero_loop_end>:
 100:	2dc00513          	li	a0,732
 104:	00100597          	auipc	a1,0x100
 108:	efc58593          	addi	a1,a1,-260 # 100000 <_data_ram>
 10c:	00100617          	auipc	a2,0x100
 110:	ef460613          	addi	a2,a2,-268 # 100000 <_data_ram>
 114:	00c5fc63          	bgeu	a1,a2,12c <main_entry>
 118:	00052283          	lw	t0,0(a0)
 11c:	0055a023          	sw	t0,0(a1)
 120:	00450513          	addi	a0,a0,4
 124:	00458593          	addi	a1,a1,4
 128:	fec5e8e3          	bltu	a1,a2,118 <zero_loop_end+0x18>

0000012c <main_entry>:
 12c:	00000513          	li	a0,0
 130:	00000593          	li	a1,0
 134:	020000ef          	jal	ra,154 <main>
 138:	00050413          	mv	s0,a0
 13c:	00040513          	mv	a0,s0

00000140 <_fini>:
 140:	00008067          	ret

00000144 <__CTOR_LIST__>:
	...

0000014c <__CTOR_END__>:
	...

00000154 <main>:
 154:	fd010113          	addi	sp,sp,-48
 158:	02812623          	sw	s0,44(sp)
 15c:	03010413          	addi	s0,sp,48
 160:	4a1017b7          	lui	a5,0x4a101
 164:	0007a683          	lw	a3,0(a5) # 4a101000 <_stack_start+0x49ffd000>
 168:	4a1017b7          	lui	a5,0x4a101
 16c:	00002737          	lui	a4,0x2
 170:	00e6e733          	or	a4,a3,a4
 174:	00e7a023          	sw	a4,0(a5) # 4a101000 <_stack_start+0x49ffd000>
 178:	35200793          	li	a5,850
 17c:	fcf42a23          	sw	a5,-44(s0)
 180:	fe042623          	sw	zero,-20(s0)
 184:	09c0006f          	j	220 <main+0xcc>
 188:	4a1017b7          	lui	a5,0x4a101
 18c:	00878793          	addi	a5,a5,8 # 4a101008 <_stack_start+0x49ffd008>
 190:	0007a683          	lw	a3,0(a5)
 194:	4a1017b7          	lui	a5,0x4a101
 198:	00878793          	addi	a5,a5,8 # 4a101008 <_stack_start+0x49ffd008>
 19c:	00002737          	lui	a4,0x2
 1a0:	00e6e733          	or	a4,a3,a4
 1a4:	00e7a023          	sw	a4,0(a5)
 1a8:	fe042423          	sw	zero,-24(s0)
 1ac:	0100006f          	j	1bc <main+0x68>
 1b0:	fe842783          	lw	a5,-24(s0)
 1b4:	00178793          	addi	a5,a5,1
 1b8:	fef42423          	sw	a5,-24(s0)
 1bc:	fe842703          	lw	a4,-24(s0)
 1c0:	fec42783          	lw	a5,-20(s0)
 1c4:	fef746e3          	blt	a4,a5,1b0 <main+0x5c>
 1c8:	4a1017b7          	lui	a5,0x4a101
 1cc:	00878793          	addi	a5,a5,8 # 4a101008 <_stack_start+0x49ffd008>
 1d0:	0007a683          	lw	a3,0(a5)
 1d4:	4a1017b7          	lui	a5,0x4a101
 1d8:	00878793          	addi	a5,a5,8 # 4a101008 <_stack_start+0x49ffd008>
 1dc:	ffffe737          	lui	a4,0xffffe
 1e0:	fff70713          	addi	a4,a4,-1 # ffffdfff <_stack_start+0xffef9fff>
 1e4:	00e6f733          	and	a4,a3,a4
 1e8:	00e7a023          	sw	a4,0(a5)
 1ec:	fe042223          	sw	zero,-28(s0)
 1f0:	0100006f          	j	200 <main+0xac>
 1f4:	fe442783          	lw	a5,-28(s0)
 1f8:	00178793          	addi	a5,a5,1
 1fc:	fef42223          	sw	a5,-28(s0)
 200:	fd442703          	lw	a4,-44(s0)
 204:	fec42783          	lw	a5,-20(s0)
 208:	40f707b3          	sub	a5,a4,a5
 20c:	fe442703          	lw	a4,-28(s0)
 210:	fef742e3          	blt	a4,a5,1f4 <main+0xa0>
 214:	fec42783          	lw	a5,-20(s0)
 218:	00178793          	addi	a5,a5,1
 21c:	fef42623          	sw	a5,-20(s0)
 220:	fec42703          	lw	a4,-20(s0)
 224:	fd442783          	lw	a5,-44(s0)
 228:	f6f740e3          	blt	a4,a5,188 <main+0x34>
 22c:	fd442783          	lw	a5,-44(s0)
 230:	fef42023          	sw	a5,-32(s0)
 234:	09c0006f          	j	2d0 <main+0x17c>
 238:	4a1017b7          	lui	a5,0x4a101
 23c:	00878793          	addi	a5,a5,8 # 4a101008 <_stack_start+0x49ffd008>
 240:	0007a683          	lw	a3,0(a5)
 244:	4a1017b7          	lui	a5,0x4a101
 248:	00878793          	addi	a5,a5,8 # 4a101008 <_stack_start+0x49ffd008>
 24c:	00002737          	lui	a4,0x2
 250:	00e6e733          	or	a4,a3,a4
 254:	00e7a023          	sw	a4,0(a5)
 258:	fe042783          	lw	a5,-32(s0)
 25c:	fcf42e23          	sw	a5,-36(s0)
 260:	0100006f          	j	270 <main+0x11c>
 264:	fdc42783          	lw	a5,-36(s0)
 268:	fff78793          	addi	a5,a5,-1
 26c:	fcf42e23          	sw	a5,-36(s0)
 270:	fdc42783          	lw	a5,-36(s0)
 274:	fef048e3          	bgtz	a5,264 <main+0x110>
 278:	4a1017b7          	lui	a5,0x4a101
 27c:	00878793          	addi	a5,a5,8 # 4a101008 <_stack_start+0x49ffd008>
 280:	0007a683          	lw	a3,0(a5)
 284:	4a1017b7          	lui	a5,0x4a101
 288:	00878793          	addi	a5,a5,8 # 4a101008 <_stack_start+0x49ffd008>
 28c:	ffffe737          	lui	a4,0xffffe
 290:	fff70713          	addi	a4,a4,-1 # ffffdfff <_stack_start+0xffef9fff>
 294:	00e6f733          	and	a4,a3,a4
 298:	00e7a023          	sw	a4,0(a5)
 29c:	fd442703          	lw	a4,-44(s0)
 2a0:	fe042783          	lw	a5,-32(s0)
 2a4:	40f707b3          	sub	a5,a4,a5
 2a8:	fcf42c23          	sw	a5,-40(s0)
 2ac:	0100006f          	j	2bc <main+0x168>
 2b0:	fd842783          	lw	a5,-40(s0)
 2b4:	fff78793          	addi	a5,a5,-1
 2b8:	fcf42c23          	sw	a5,-40(s0)
 2bc:	fd842783          	lw	a5,-40(s0)
 2c0:	fef048e3          	bgtz	a5,2b0 <main+0x15c>
 2c4:	fe042783          	lw	a5,-32(s0)
 2c8:	fff78793          	addi	a5,a5,-1
 2cc:	fef42023          	sw	a5,-32(s0)
 2d0:	fe042783          	lw	a5,-32(s0)
 2d4:	f6f042e3          	bgtz	a5,238 <main+0xe4>
 2d8:	ea9ff06f          	j	180 <main+0x2c>

Disassembly of section .stack:

00103000 <_stack-0x1000>:
	...

Disassembly of section .comment:

00000000 <.comment>:
   0:	3a434347          	fmsub.d	ft6,ft6,ft4,ft7,rmm
   4:	2820                	fld	fs0,80(s0)
   6:	20554e47          	fmsub.s	ft8,fa0,ft5,ft4,rmm
   a:	434d                	li	t1,19
   c:	2055                	jal	b0 <_stext+0x58>
   e:	6345                	lui	t1,0x11
  10:	696c                	flw	fa1,84(a0)
  12:	7370                	flw	fa2,100(a4)
  14:	2065                	jal	bc <_stext+0x64>
  16:	4952                	lw	s2,20(sp)
  18:	562d4353          	0x562d4353
  1c:	4520                	lw	s0,72(a0)
  1e:	626d                	lui	tp,0x1b
  20:	6465                	lui	s0,0x19
  22:	6564                	flw	fs1,76(a0)
  24:	2064                	fld	fs1,192(s0)
  26:	2c434347          	0x2c434347
  2a:	3620                	fld	fs0,104(a2)
  2c:	2d34                	fld	fa3,88(a0)
  2e:	6962                	flw	fs2,24(sp)
  30:	2974                	fld	fa3,208(a0)
  32:	3820                	fld	fs0,112(s0)
  34:	322e                	fld	ft4,232(sp)
  36:	302e                	fld	ft0,232(sp)
	...
