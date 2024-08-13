
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
  60:	8106                	mv	sp,ra
  62:	8186                	mv	gp,ra
  64:	8206                	mv	tp,ra
  66:	8286                	mv	t0,ra
  68:	8306                	mv	t1,ra
  6a:	8386                	mv	t2,ra
  6c:	8406                	mv	s0,ra
  6e:	8486                	mv	s1,ra
  70:	8506                	mv	a0,ra
  72:	8586                	mv	a1,ra
  74:	8606                	mv	a2,ra
  76:	8686                	mv	a3,ra
  78:	8706                	mv	a4,ra
  7a:	8786                	mv	a5,ra
  7c:	8806                	mv	a6,ra
  7e:	8886                	mv	a7,ra
  80:	8906                	mv	s2,ra
  82:	8986                	mv	s3,ra
  84:	8a06                	mv	s4,ra
  86:	8a86                	mv	s5,ra
  88:	8b06                	mv	s6,ra
  8a:	8b86                	mv	s7,ra
  8c:	8c06                	mv	s8,ra
  8e:	8c86                	mv	s9,ra
  90:	8d06                	mv	s10,ra
  92:	8d86                	mv	s11,ra
  94:	8e06                	mv	t3,ra
  96:	8e86                	mv	t4,ra
  98:	8f06                	mv	t5,ra
  9a:	8f86                	mv	t6,ra
  9c:	00104117          	auipc	sp,0x104
  a0:	f6410113          	addi	sp,sp,-156 # 104000 <_stack_start>

000000a4 <_start>:
  a4:	00100d17          	auipc	s10,0x100
  a8:	f5cd0d13          	addi	s10,s10,-164 # 100000 <_data_ram>
  ac:	00100d97          	auipc	s11,0x100
  b0:	f54d8d93          	addi	s11,s11,-172 # 100000 <_data_ram>
  b4:	01bd5763          	bge	s10,s11,c2 <zero_loop_end>

000000b8 <zero_loop>:
  b8:	000d2023          	sw	zero,0(s10)
  bc:	0d11                	addi	s10,s10,4
  be:	ffaddde3          	bge	s11,s10,b8 <zero_loop>

000000c2 <zero_loop_end>:
  c2:	23800513          	li	a0,568
  c6:	00100597          	auipc	a1,0x100
  ca:	f3a58593          	addi	a1,a1,-198 # 100000 <_data_ram>
  ce:	00100617          	auipc	a2,0x100
  d2:	f3260613          	addi	a2,a2,-206 # 100000 <_data_ram>
  d6:	00c5fa63          	bgeu	a1,a2,ea <main_entry>
  da:	00052283          	lw	t0,0(a0)
  de:	0055a023          	sw	t0,0(a1)
  e2:	0511                	addi	a0,a0,4
  e4:	0591                	addi	a1,a1,4
  e6:	fec5eae3          	bltu	a1,a2,da <zero_loop_end+0x18>

000000ea <main_entry>:
  ea:	00000513          	li	a0,0
  ee:	00000593          	li	a1,0
  f2:	01a000ef          	jal	ra,10c <main>
  f6:	842a                	mv	s0,a0
  f8:	8522                	mv	a0,s0

000000fa <_fini>:
  fa:	8082                	ret

000000fc <__CTOR_LIST__>:
	...

00000104 <__CTOR_END__>:
	...

0000010c <main>:
 10c:	7179                	addi	sp,sp,-48
 10e:	d622                	sw	s0,44(sp)
 110:	1800                	addi	s0,sp,48
 112:	4a1017b7          	lui	a5,0x4a101
 116:	4394                	lw	a3,0(a5)
 118:	4a1017b7          	lui	a5,0x4a101
 11c:	6709                	lui	a4,0x2
 11e:	8f55                	or	a4,a4,a3
 120:	c398                	sw	a4,0(a5)
 122:	35200793          	li	a5,850
 126:	fcf42a23          	sw	a5,-44(s0)
 12a:	fe042623          	sw	zero,-20(s0)
 12e:	a89d                	j	1a4 <main+0x98>
 130:	4a1017b7          	lui	a5,0x4a101
 134:	07a1                	addi	a5,a5,8
 136:	4394                	lw	a3,0(a5)
 138:	4a1017b7          	lui	a5,0x4a101
 13c:	07a1                	addi	a5,a5,8
 13e:	6709                	lui	a4,0x2
 140:	8f55                	or	a4,a4,a3
 142:	c398                	sw	a4,0(a5)
 144:	fe042423          	sw	zero,-24(s0)
 148:	a031                	j	154 <main+0x48>
 14a:	fe842783          	lw	a5,-24(s0)
 14e:	0785                	addi	a5,a5,1
 150:	fef42423          	sw	a5,-24(s0)
 154:	fe842703          	lw	a4,-24(s0)
 158:	fec42783          	lw	a5,-20(s0)
 15c:	fef747e3          	blt	a4,a5,14a <main+0x3e>
 160:	4a1017b7          	lui	a5,0x4a101
 164:	07a1                	addi	a5,a5,8
 166:	4394                	lw	a3,0(a5)
 168:	4a1017b7          	lui	a5,0x4a101
 16c:	07a1                	addi	a5,a5,8
 16e:	7779                	lui	a4,0xffffe
 170:	177d                	addi	a4,a4,-1
 172:	8f75                	and	a4,a4,a3
 174:	c398                	sw	a4,0(a5)
 176:	fe042223          	sw	zero,-28(s0)
 17a:	a031                	j	186 <main+0x7a>
 17c:	fe442783          	lw	a5,-28(s0)
 180:	0785                	addi	a5,a5,1
 182:	fef42223          	sw	a5,-28(s0)
 186:	fd442703          	lw	a4,-44(s0)
 18a:	fec42783          	lw	a5,-20(s0)
 18e:	40f707b3          	sub	a5,a4,a5
 192:	fe442703          	lw	a4,-28(s0)
 196:	fef743e3          	blt	a4,a5,17c <main+0x70>
 19a:	fec42783          	lw	a5,-20(s0)
 19e:	0785                	addi	a5,a5,1
 1a0:	fef42623          	sw	a5,-20(s0)
 1a4:	fec42703          	lw	a4,-20(s0)
 1a8:	fd442783          	lw	a5,-44(s0)
 1ac:	f8f742e3          	blt	a4,a5,130 <main+0x24>
 1b0:	fd442783          	lw	a5,-44(s0)
 1b4:	fef42023          	sw	a5,-32(s0)
 1b8:	a89d                	j	22e <main+0x122>
 1ba:	4a1017b7          	lui	a5,0x4a101
 1be:	07a1                	addi	a5,a5,8
 1c0:	4394                	lw	a3,0(a5)
 1c2:	4a1017b7          	lui	a5,0x4a101
 1c6:	07a1                	addi	a5,a5,8
 1c8:	6709                	lui	a4,0x2
 1ca:	8f55                	or	a4,a4,a3
 1cc:	c398                	sw	a4,0(a5)
 1ce:	fe042783          	lw	a5,-32(s0)
 1d2:	fcf42e23          	sw	a5,-36(s0)
 1d6:	a031                	j	1e2 <main+0xd6>
 1d8:	fdc42783          	lw	a5,-36(s0)
 1dc:	17fd                	addi	a5,a5,-1
 1de:	fcf42e23          	sw	a5,-36(s0)
 1e2:	fdc42783          	lw	a5,-36(s0)
 1e6:	fef049e3          	bgtz	a5,1d8 <main+0xcc>
 1ea:	4a1017b7          	lui	a5,0x4a101
 1ee:	07a1                	addi	a5,a5,8
 1f0:	4394                	lw	a3,0(a5)
 1f2:	4a1017b7          	lui	a5,0x4a101
 1f6:	07a1                	addi	a5,a5,8
 1f8:	7779                	lui	a4,0xffffe
 1fa:	177d                	addi	a4,a4,-1
 1fc:	8f75                	and	a4,a4,a3
 1fe:	c398                	sw	a4,0(a5)
 200:	fd442703          	lw	a4,-44(s0)
 204:	fe042783          	lw	a5,-32(s0)
 208:	40f707b3          	sub	a5,a4,a5
 20c:	fcf42c23          	sw	a5,-40(s0)
 210:	a031                	j	21c <main+0x110>
 212:	fd842783          	lw	a5,-40(s0)
 216:	17fd                	addi	a5,a5,-1
 218:	fcf42c23          	sw	a5,-40(s0)
 21c:	fd842783          	lw	a5,-40(s0)
 220:	fef049e3          	bgtz	a5,212 <main+0x106>
 224:	fe042783          	lw	a5,-32(s0)
 228:	17fd                	addi	a5,a5,-1
 22a:	fef42023          	sw	a5,-32(s0)
 22e:	fe042783          	lw	a5,-32(s0)
 232:	f8f044e3          	bgtz	a5,1ba <main+0xae>
 236:	bdd5                	j	12a <main+0x1e>

Disassembly of section .stack:

00103000 <_stack-0x1000>:
	...

Disassembly of section .comment:

00000000 <.comment>:
   0:	3a434347          	fmsub.d	ft6,ft6,ft4,ft7,rmm
   4:	2820                	fld	fs0,80(s0)
   6:	20554e47          	fmsub.s	ft8,fa0,ft5,ft4,rmm
   a:	434d                	li	t1,19
   c:	2055                	jal	b0 <_start+0xc>
   e:	6345                	lui	t1,0x11
  10:	696c                	flw	fa1,84(a0)
  12:	7370                	flw	fa2,100(a4)
  14:	2065                	jal	bc <zero_loop+0x4>
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
