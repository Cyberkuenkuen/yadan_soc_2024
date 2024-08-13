// 宏定义简化对寄存器的访问
#define REG(add) (*(volatile unsigned int *)(add))

// 定义GPIO寄存器地址
#define PADDIR REG(0x4A101000) 	// GPIO方向寄存器
#define PADOUT REG(0x4A101008)  // GPIO输出寄存器


int main()
{
    PADDIR |= (1 << 13);	// 设置GPIO的第13号引脚为输出模式
    int num = 850; 			// 定义控制呼吸效果的周期数
    while (1) 				// 无限循环
    {
        // 呼吸灯亮起过程：逐渐增加LED闪烁时的点亮时间
        for (int j = 0; j < num; j++)
        {
            PADOUT |= (1 << 13); 				// 设置GPIO第13号引脚为高电平，点亮LED
            for (int i = 0; i < j; i++)			// 软件延时，延时时间随j的增加而增加
                ;
            PADOUT &= ~(1 << 13); 				// 设置GPIO第13号引脚为低电平，熄灭LED
            for (int i = 0; i < num - j; i++)	// 软件延时
                ;
        }

        // 呼吸灯熄灭过程：逐渐减少LED闪烁时的点亮时间
        for (int j = num; j > 0; j--)
        {
            PADOUT |= (1 << 13);
            for (int i = j; i > 0; i--)
                ;
            PADOUT &= ~(1 << 13);
            for (int i = num - j; i > 0; i--)
                ;
        }
    }

    return 0; // 此行通常不会被执行
}