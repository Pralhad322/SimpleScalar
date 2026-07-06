#include <stdio.h>

int
main(void)
{
  int i;
  float a = 0.0f;
  float b = 2.0f, c = 3.0f, d = 10.0f, e = 5.0f, f = 8.0f;

  for (i = 0; i < 10000000; i++)
    a = b + c * d / e - f;

  printf("a = %f\n", a);
  return 0;
}
