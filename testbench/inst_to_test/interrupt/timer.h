#ifndef _TIMER_H_
#define _TIMER_H_


#define TIMER0_BASE   (0x4A103000)
#define TIMER0_COUNT   (TIMER0_BASE + (0x00))
#define TIMER0_CTRL  (TIMER0_BASE + (0x04))
#define TIMER0_CMP  (TIMER0_BASE + (0x08))

#define TIMER1_BASE   (0x4A103010)
#define TIMER1_COUNT   (TIMER1_BASE + (0x00))
#define TIMER1_CTRL  (TIMER1_BASE + (0x04))
#define TIMER1_CMP  (TIMER1_BASE + (0x08))



#define TIMER_REG(addr) (*((volatile uint32_t *)addr))          //读写寄存器


#endif