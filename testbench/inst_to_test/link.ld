OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    ROM (wxa!ri) : ORIGIN = 0x00000000, LENGTH = 4K
    RAM (wxa!ri) : ORIGIN = 0x10000000, LENGTH = 4K
}

SECTIONS 
{
    __stack_size = 2k;

    . = 0x00000000;
    .text : { *(.text) }>ROM

    .lalign         :
    {
        . = ALIGN(4);
        PROVIDE( _data_lma = . );
    } >ROM AT>ROM 

    .dalign         :
    {
        . = ALIGN(4);
        PROVIDE( _data = . );
    } >RAM AT>ROM 

    .data          :
    {
        *(.rdata)
        *(.rodata .rodata.*)
        *(.gnu.linkonce.r.*)
        *(.data .data.*)
        *(.gnu.linkonce.d.*)
        . = ALIGN(8);
        PROVIDE( __global_pointer$ = . + 0x800 );
        *(.sdata .sdata.*)
        *(.gnu.linkonce.s.*)
        . = ALIGN(8);
        *(.srodata.cst16)
        *(.srodata.cst8)
        *(.srodata.cst4)
        *(.srodata.cst2)
        *(.srodata .srodata.*)
    } >RAM AT>ROM 

    . = ALIGN(4);
    PROVIDE( _edata = . );
    PROVIDE( edata = . );

    PROVIDE( _fbss = . );
    PROVIDE( __bss_start = . );
    .bss            :
    {
        *(.sbss*)
        *(.gnu.linkonce.sb.*)
        *(.bss .bss.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
        . = ALIGN(4);
    } >RAM AT>RAM 

    . = ALIGN(8);
    PROVIDE( _end = . );
    PROVIDE( end = . );

    PROVIDE(_stack_begin = .);
    . = ORIGIN(RAM) + LENGTH(RAM) - __stack_size;
    PROVIDE( _sp = . );
    PROVIDE(_stack_end = .);
    _end = .;
}

