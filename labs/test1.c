#include <stdio.h>

int
main(void)
{
  int i;
  int a = 0;
  int b = 2, c = 3, d = 10, e = 5, f = 8;

  for (i = 0; i < 10000000; i++)
    a = b + c * d / e - f;

  printf("a = %d\n", a);
  return 0;
}
