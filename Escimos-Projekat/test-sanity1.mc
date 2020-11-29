//OPIS: Sanity check za miniC gramatiku

fun int f(int x) {
    int y;
    return x + 2 - y;
}

fun unsigned f2() {
    return 2u;
}

fun unsigned ff(unsigned x) {
    unsigned y;
    return x + f2() - y; //f2++() takodje ne radi kao i f2()++ , return y++ radi
}

/* ne radi ako vacant vraca tip
fun vacant funkcija(int x) {
return x;
} 
*/

/* provera za void i return ; , radi
 fun vacant fff() {

return ; } */

/* baca warning 
fun int fff(int x) { 
return ;
} */

fun int funkcija(int a, unsigned b) { 
	
	return a;
} 



//fun int a++() { } <- ne moze increment na funckiju 

fun int main() {
    int a;
    int b;
    int aa;
    int bb;
    int c;
    int d;
    unsigned u;
    unsigned w;
    unsigned uu;
    unsigned ww;
	
    // a = funkcija(, 3u); poziv funckije 2 parametara, radi sve 

    
    //int o++; ne radi test ok 
    int s;
    s = 2/0;
   
    a = funkcija(2, 3u) / s;


    //poziv funkcije
    a = f(3);
    a++;
   //kad pozovem f++ to radi i baca error na test jer je f nedefinisan
   // f++;

  
    //if iskaz sa else delom
    if (a < b)  //1
        a = 1;
    else
        a = -2;

    if (a + c == b + d - 4) //2
        a = 1;
    else
        a = 2;

    if (u == w) {   //3
        u = ff(1u);
        a = f(11);
    }
    else {
        w = 2u;
    }
    if (a + c == b - d - -4) {  //4
        a = 1;
    }
    else
        a = 2;
    a = f(42);

    if (a + (aa-c) - d < b + (bb-a))    //5
        uu = w-u+uu;
    else
        d = aa+bb-c;

    //if iskaz bez else dela
    if (a < b)  //6
        a = 1;

    if (a + c == b - +4)    //7
        a = 1;


    a = b++ + a + c;

    return 0;
}

