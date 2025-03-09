#include <stdint.h>
#include "timer.h"
// #include "../include/gpio.h"
#include "utils.h"


static volatile uint32_t count;

int main()
{
  count = 0;

// #ifdef SIMULATION
  TIMER_REG(TIMER0_COUNT) = 0;     // 初始计时值 
  TIMER_REG(TIMER0_CMP) = 500;     // 设置比较溢出的值，50MHz下计时10us
  TIMER_REG(TIMER0_CTRL) = 0x01;   // 启动计数且不分频。[0]: 使能位   [5:3]预分频系数

  while (1) {
    if (count == 2) {
      TIMER_REG(TIMER0_CTRL) = 0x00;   // stop timer
      count = 0;
      // TODO: do something
      set_test_pass();
      break;
    }
    }
// #else
//     TIMER_REG(TIMER0_COUNT) = 0;
//     TIMER_REG(TIMER0_CMP) = 500000;  // 10ms
//     TIMER_REG(TIMER0_CTRL) = 0x01;

//     GPIO_REG(GPIO_CTRL) |= 0x1;  // set gpio0 output mode

//     while (1) {
//         // 500ms
//         if (count == 50) {
//             count = 0;
//             GPIO_REG(GPIO_DATA) ^= 0x1; // toggle led
//         }
//     }
// #endif

    return 0;
}

void timer_0_compare_handler()
{
    count++;
}