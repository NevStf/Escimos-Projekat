//raznorazne greske za funkcije

fun int f1(int a, int b) { } // ne prolazi 

fun int f2()  { return ; } //warning 

//fun int f3() { return 8u; } ne prolazi

//fun unsigned f4() { return ; } warning

//fun unsigned f5() { } ne prolazi 

//fun unsigned f6() {return 3; } ne prolazi 

//fun vacant f6() {return 5; } ne prolazi  
 
fun vacant f7() {return ; } //ovo je ok 

fun int main() { 


return 0;

} 
