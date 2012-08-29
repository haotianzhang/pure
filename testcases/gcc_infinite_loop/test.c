//#include <stdlib.h>


__attribute__ ((__noreturn__))
void a () {
  exit(1);
}

int b (int arg)
{
 arg == !! arg ? 0 : a ();
  if (arg)
    return 0;
  else
    return 1;
}

int main() {
  b (1);
}

