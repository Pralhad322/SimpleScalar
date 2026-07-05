#include <stdio.h>

int
main(void)
{
  int i;
  int sum = 0;

  for (i = 1; i <= 10; i++)
    sum += i * i;

  printf("Hello from SimpleScalar PISA little-endian\n");
  printf("sum_of_squares_1_to_10 = %d\n", sum);

  return 0;
}
