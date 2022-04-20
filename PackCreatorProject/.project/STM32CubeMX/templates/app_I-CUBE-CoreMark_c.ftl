#include "main.h"
#include <stdio.h>
#include "app_coremarkapp.h"

void ${fctName}(void)
{
  printf("CoreMark Test Begins!\r\n");
  coremark_main();
  printf("CoreMark Test Finishes!\r\n");    
}

void ${fctProcessName}(void)
{

}

extern UART_HandleTypeDef PRINTF_UART_PORT;

#ifdef __GNUC__
  #define PUTCHAR_PROTOTYPE int __io_putchar(int ch)
#else
  #define PUTCHAR_PROTOTYPE int fputc(int ch, FILE *f)
#endif /* __GNUC__ */
PUTCHAR_PROTOTYPE
{
	
  HAL_UART_Transmit(&PRINTF_UART_PORT, (uint8_t *)&ch, 1, 0xFFFF);
  return ch;
}