#include <stdio.h>

static int
mix(int x)
{
  x = x * 1103515245 + 12345;
  x ^= x >> 11;
  x += (x << 7);
  return x;
}

int
main(void)
{
  int i;
  volatile int seed = 1;
  volatile int result = 0;

  for (i = 0; i < 1000000; i++)
    result += mix(seed + i);

  printf("result = %d\n", result);
  return 0;
}
