//OPIS: globalne promenljive, inkrement
//RETURN: 265

int x;
int y;

fun int f1(int a) {
    x = a + 3;
    x++;
    a++;
    return a + x;
}

fun int f2(int a) {
    y = a + x;
    y++;
    return y;
}

fun int main() {
  int a;
  int b;
  a = f1(42);
  b = f2(17);
  a++;
  y++;
  return a + b + x + y;
}

