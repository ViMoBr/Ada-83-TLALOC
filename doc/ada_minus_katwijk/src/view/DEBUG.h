/*
 * Debug printf
 * define DEBUG to change PRINTF into printf
 * else a call to dummy is made
 */

#ifdef DEBUG
#define PRINTF printf
#define FPRINTF fprintf
#else
#define PRINTF dummy
#define FPRINTF dummy
static dummy() {}
#endif

