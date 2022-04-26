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
  // Empty implementation. Doing nothing.
}

extern UART_HandleTypeDef PRINTF_UART_PORT;

#if defined (__ARMCC_VERSION)
  #define PUTCHAR_PROTOTYPE int stdout_putchar(int ch)
#elif defined(__GNUC__)
  #define PUTCHAR_PROTOTYPE int __io_putchar(int ch)
#elif defined(__ICCARM__)
  #define PUTCHAR_PROTOTYPE int fputc(int ch, FILE *f)
#endif
PUTCHAR_PROTOTYPE
{
	
  HAL_UART_Transmit(&PRINTF_UART_PORT, (uint8_t *)&ch, 1, 0xFFFF);
  return ch;
}

#if defined (__ARMCC_VERSION)
#define RTE_Compiler_IO_STDOUT          /* Compiler I/O: STDOUT */
#define RTE_Compiler_IO_STDOUT_User     /* Compiler I/O: STDOUT User */
#define RETARGET_SYS

#ifdef RETARGET_SYS

#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <rt_sys.h>

/**
  Put a character to the stdout
 
  \param[in]   ch  Character to output
  \return          The character written, or -1 on write error.
*/
#if   defined(RTE_Compiler_IO_STDOUT)
#if   defined(RTE_Compiler_IO_STDOUT_User)
extern int stdout_putchar (int ch);
#endif
#endif
 
//#else  /* __MICROLIB */
 
 
#if (defined(RTE_Compiler_IO_STDIN)  || \
     defined(RTE_Compiler_IO_STDOUT) || \
     defined(RTE_Compiler_IO_STDERR) || \
     defined(RTE_Compiler_IO_File))
#define RETARGET_SYS
 
/* IO device file handles. */
#define FH_STDIN    0x8001
#define FH_STDOUT   0x8002
#define FH_STDERR   0x8003
// User defined ...
 
/* Standard IO device name defines. */
const char __stdin_name[]  = ":STDIN";
const char __stdout_name[] = ":STDOUT";
const char __stderr_name[] = ":STDERR";
 
#endif
 
 
/**
  Defined in rt_sys.h, this function opens a file.
 
  The _sys_open() function is required by fopen() and freopen(). These
  functions in turn are required if any file input/output function is to
  be used.
  The openmode parameter is a bitmap whose bits mostly correspond directly to
  the ISO mode specification. Target-dependent extensions are possible, but
  freopen() must also be extended.
 
  \param[in] name     File name
  \param[in] openmode Mode specification bitmap
 
  \return    The return value is ?1 if an error occurs.
*/
#ifdef RETARGET_SYS
__attribute__((weak))
FILEHANDLE _sys_open (const char *name, int openmode) {
#if (!defined(RTE_Compiler_IO_File))
  (void)openmode;
#endif
 
  if (name == NULL) {
    return (-1);
  }
 
  if (name[0] == ':') {
    if (strcmp(name, ":STDIN") == 0) {
      return (FH_STDIN);
    }
    if (strcmp(name, ":STDOUT") == 0) {
      return (FH_STDOUT);
    }
    if (strcmp(name, ":STDERR") == 0) {
      return (FH_STDERR);
    }
    return (-1);
  }
  return (-1);
}
#endif
 
 
/**
  Defined in rt_sys.h, this function closes a file previously opened
  with _sys_open().
  
  This function must be defined if any input/output function is to be used.
 
  \param[in] fh File handle
 
  \return    The return value is 0 if successful. A nonzero value indicates
             an error.
*/
#ifdef RETARGET_SYS
__attribute__((weak))
int _sys_close (FILEHANDLE fh) {
  return (0);
}
#endif
 
 
/**
  Defined in rt_sys.h, this function writes the contents of a buffer to a file
  previously opened with _sys_open().
 
  \note The mode parameter is here for historical reasons. It contains
        nothing useful and must be ignored.
 
  \param[in] fh   File handle
  \param[in] buf  Data buffer
  \param[in] len  Data length
  \param[in] mode Ignore this parameter
 
  \return    The return value is either:
             - a positive number representing the number of characters not
               written (so any nonzero return value denotes a failure of
               some sort)
             - a negative number indicating an error.
*/
#ifdef RETARGET_SYS
__attribute__((weak))
int _sys_write (FILEHANDLE fh, const uint8_t *buf, uint32_t len, int mode) {
#if (defined(RTE_Compiler_IO_STDOUT) || defined(RTE_Compiler_IO_STDERR))
  int ch;
#elif (!defined(RTE_Compiler_IO_File))
  (void)buf;
  (void)len;
#endif
  (void)mode;
 
  switch (fh) {
    case FH_STDIN:
      return (-1);
    case FH_STDOUT:
#ifdef RTE_Compiler_IO_STDOUT
      for (; len; len--) {
        ch = *buf++;
#if (STDOUT_CR_LF != 0)
        if (ch == '\n') stdout_putchar('\r');
#endif
        stdout_putchar(ch);
      }
#endif
      return (0);
    case FH_STDERR:
#ifdef RTE_Compiler_IO_STDERR
      for (; len; len--) {
        ch = *buf++;
#if (STDERR_CR_LF != 0)
        if (ch == '\n') stderr_putchar('\r');
#endif
        stderr_putchar(ch);
      }
#endif
      return (0);
  }
 
#ifdef RTE_Compiler_IO_File
#ifdef RTE_Compiler_IO_File_FS
  return (__sys_write(fh, buf, len));
#endif
#else
  return (-1);
#endif
}
#endif
 
/**
  Defined in rt_sys.h, this function determines if a file handle identifies
  a terminal.
 
  When a file is connected to a terminal device, this function is used to
  provide unbuffered behavior by default (in the absence of a call to
  set(v)buf) and to prohibit seeking.
 
  \param[in] fh File handle
 
  \return    The return value is one of the following values:
             - 0:     There is no interactive device.
             - 1:     There is an interactive device.
             - other: An error occurred.
*/
#ifdef RETARGET_SYS
__attribute__((weak))
int _sys_istty (FILEHANDLE fh) {
  return (0);
}
#endif
 
 
/**
  Defined in rt_sys.h, this function puts the file pointer at offset pos from
  the beginning of the file.
 
  This function sets the current read or write position to the new location pos
  relative to the start of the current file fh.
 
  \param[in] fh  File handle
  \param[in] pos File pointer offset
 
  \return    The result is:
             - non-negative if no error occurs
             - negative if an error occurs
*/
#ifdef RETARGET_SYS
__attribute__((weak))
int _sys_seek (FILEHANDLE fh, long pos) {
  return (0);
}
#endif
 
 
/**
  Defined in rt_sys.h, this function returns the current length of a file.
 
  This function is used by _sys_seek() to convert an offset relative to the
  end of a file into an offset relative to the beginning of the file.
  You do not have to define _sys_flen() if you do not intend to use fseek().
  If you retarget at system _sys_*() level, you must supply _sys_flen(),
  even if the underlying system directly supports seeking relative to the
  end of a file.
 
  \param[in] fh File handle
 
  \return    This function returns the current length of the file fh,
             or a negative error indicator.
*/
#ifdef RETARGET_SYS
__attribute__((weak))
long _sys_flen (FILEHANDLE fh) {
  return (0);
}
#endif

#ifdef __MICROLIB
__attribute__((weak)) int fputc (int c, FILE * stream) {
  (void)c;
  (void)stream;
 
#ifdef RTE_Compiler_IO_STDOUT
  if (stream == &__stdout) {
#if (STDOUT_CR_LF != 0)
    if (c == '\n') stdout_putchar('\r');
#endif
    return (stdout_putchar(c));
  }
#endif 
  return (-1);
}
#endif  /* __MICROLIB */

#endif  /* RETARGET_SYS */
#endif  /* __ARMCC_VERSION */
