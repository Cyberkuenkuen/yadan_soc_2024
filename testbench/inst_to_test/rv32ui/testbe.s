


addi x5,x0,0x4
addi x6,x0,0x5
bge x6,x5,test
addi x5,x0,0x7
addi x6,x0,0x8
test:
addi gp,x5,0x0
li sp,0x4
beq gp,sp,
testpass:
li	s10,1
li	s11,1
testfail:
li	s10,1
li	s11,0


