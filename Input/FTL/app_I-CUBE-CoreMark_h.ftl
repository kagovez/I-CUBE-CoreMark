#include "coremark.h"

#if MAIN_HAS_NOARGC
MAIN_RETURN_TYPE coremark_main(void);
#else
MAIN_RETURN_TYPE coremark_main(int argc, char *argv[]);
#endif

/* Exported Functions Prototypes ---------------------------------------------*/
void ${fctName}(void);
void ${fctProcessName}(void);