#include <stdio.h>

int
main(void)
{
  int i;

  for (i = 0; i < 10000000; i++)
    ;

  printf("hello world\n");
  return 0;
}
