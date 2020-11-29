//OPIS: jedna deklaracija sa dve promenljive
fun int main() {
    int a,b,c;
    a = 5;
    b = 3;

para(int i = 1; i < a; 4) { 
 
c = a + b++;

}  
//za nepoklapanje parametra radi (3. argument da bude tipa u na primer) 
//
para(int i = 1; i < a; 5) { 
	para(int j = 1; i < a; 3) { 
		b=6;
		c++;
		//i = 1u; <- radi kako treba
		
	}


}

//switch GOD HELP US ALL
switch (a) {
	case 1 =>
	a = a + 5;
	//a++; 
	break;

	case 5 =>
	{
	b = 3;
	a++;
	
	}
	break;
	case 1 =>
	c = 3;

	otherwise =>
	a = a - 1;
	
}


return 1;

}
