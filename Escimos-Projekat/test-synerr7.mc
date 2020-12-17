//greske ukoliko se inkrement ne pozove nad promenljivom ili u izrazu

//fun int funckija()++ { } <- baca gresku 

fun int funkcija(int a++) { } 


fun int main() {  
int a,b, c;

c++;
b = a++ - c;


return 0;

}
