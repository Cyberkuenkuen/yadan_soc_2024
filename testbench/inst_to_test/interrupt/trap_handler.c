#include <stdint.h>

//assign intn = {timebCint,timebOint,timeaCint,timeaOint,4'b0};
//cause <= {1'b1, 19'b0, int_flag_i, 4'b0};
#define TIMER_0_OINT_BIT 0x80000100
#define TIMER_0_CINT_BIT 0x80000200
#define TIMER_1_OINT_BIT 0x80000400
#define TIMER_1_CINT_BIT 0x80000800

extern void timer_0_overflow_handler() __attribute__((weak));
extern void timer_0_compare_handler() __attribute__((weak));
extern void timer_1_overflow_handler() __attribute__((weak));
extern void timer_1_compare_handler() __attribute__((weak));

void timer_0_overflow_handler() {}
void timer_0_compare_handler() {}
void timer_1_overflow_handler() {}
void timer_1_compare_handler() {}

void trap_handler(uint32_t mcause, uint32_t mepc)
{
  uint32_t timer_interrupts_pending = mcause & 0x00000F00;
  // int handled = 0;
  
  // 按优先级处理中断 (timer_0优先于timer_1，compare优先于overflow)
  if (timer_interrupts_pending & TIMER_0_CINT_BIT) {
    timer_0_compare_handler();
    // handled = 1;
  }

  if (timer_interrupts_pending & TIMER_0_OINT_BIT) {
    timer_0_overflow_handler();
    // handled = 1;
  }

  if (timer_interrupts_pending & TIMER_1_CINT_BIT) {
    timer_1_compare_handler();
    // handled = 1;
  }

  if (timer_interrupts_pending & TIMER_1_OINT_BIT) {
    timer_1_overflow_handler();
    // handled = 1;
  }
}