# 1 "main.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "main.c"
# 9 "main.c"
int main()
{
    (*(volatile unsigned int *)(0x4A101000)) |= (1 << 13);
    int num = 850;
    while (1)
    {

        for (int j = 0; j < num; j++)
        {
            (*(volatile unsigned int *)(0x4A101008)) |= (1 << 13);
            for (int i = 0; i < j; i++)
                ;
            (*(volatile unsigned int *)(0x4A101008)) &= ~(1 << 13);
            for (int i = 0; i < num - j; i++)
                ;
        }


        for (int j = num; j > 0; j--)
        {
            (*(volatile unsigned int *)(0x4A101008)) |= (1 << 13);
            for (int i = j; i > 0; i--)
                ;
            (*(volatile unsigned int *)(0x4A101008)) &= ~(1 << 13);
            for (int i = num - j; i > 0; i--)
                ;
        }
    }

    return 0;
}
