%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"
  #include "codegen.h"

  int yyparse(void);
  int yylex(void);
  int yyerror(char *s);
  void warning(char *s);

  extern int yylineno;
  char char_buffer[CHAR_BUFFER_LENGTH];
  int error_count = 0;
  int warning_count = 0;
  int var_num = 0;
  int glob_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;
  int ima_return = 0;
  int switch_idx = 10;
  int case_vrednost[100];
  int case_cnt = 0;
  //definisanje var_type
  int var_type = 0;
  FILE *output;
  int out_lin = 0;
 int lab_num = -1;
%}

%union {
  int i;
  char *s;
}

%token <i> _TYPE
%token _IF
%token _ELSE
%token _RETURN
%token <s> _ID
%token <s> _INT_NUMBER
%token <s> _UINT_NUMBER
%token _LPAREN
%token _RPAREN
%token _LBRACKET
%token _RBRACKET
%token _ASSIGN
%token _SEMICOLON
%token _COMMA
%token <i> _AROP
%token <i> _RELOP
%token _INC
%token _FUN
%token _PARA
%token _COLON
%token _POINTER
%token _SWITCH
%token _BREAK
%token _OTHERWISE
%token _CASE


%type <i> num_exp exp literal function_call argument rel_exp if_part

%nonassoc ONLY_IF
%nonassoc _ELSE

%%

program
  : global_list function_list
      {  
        if(lookup_symbol("main", FUN) == NO_INDEX)
          err("undefined reference to 'main'");
       }
  ;

function_list
  : function
  | function_list function
  ;

function
  : _FUN _TYPE _ID
      {
        fun_idx = lookup_symbol($3, FUN);
        if(fun_idx == NO_INDEX)
          fun_idx = insert_symbol($3, FUN, $2, NO_ATR, NO_ATR);
        else 
          err("redefinition of function '%s'", $3);

	 code("\n%s:", $3);	
        code("\n\t\tPUSH\t%%14");	
        code("\n\t\tMOV \t%%15,%%14");
      }
    _LPAREN parameters _RPAREN body
      {
        clear_symbols(fun_idx + 1);
        var_num = 0;
	ima_return = 0;

	code("\n@%s_exit:", $3);	
        code("\n\t\tMOV \t%%14,%%15");	
        code("\n\t\tPOP \t%%14");	
        code("\n\t\tRET");
      }
  ;

global_list
  : /*empty*/
  | global_list global
  ;

global
 : _TYPE _ID _SEMICOLON
	{
	 if(lookup_symbol($2, GLOB) == NO_INDEX) { 
		 insert_symbol($2, GLOB, $1, NO_ATR, NO_ATR); 
		} else { err("Redefinition of %s.", $2); } 
		
		code("\n%s:\n\t\tWORD\t1", $2);
	}
 ;


parameters
  : /* empty */
      { set_atr1(fun_idx, 0); }

  | _TYPE _ID
      {
	if($1 == VACANT) { err("parameters of function cannot be VACANT.\n"); }
        insert_symbol($2, PAR, $1, 1, NO_ATR);
        set_atr1(fun_idx, $1); 
        
      }
  | _TYPE _ID _COMMA _TYPE _ID 
	{  
		if($1 == VACANT || $4 == VACANT) { err("parameters of function cannot be VACANT.\n"); }	
		insert_symbol($2, PAR, $1, 1, NO_ATR);
		insert_symbol($5, PAR, $4, 2, NO_ATR);
		set_atr1(fun_idx, $1);
		set_atr2(fun_idx, $4); //promena logike atributa, gde kod funckije sa jednim parametrom u atr1 stavljamo tip parametra
	} 
  ;

body
  : _LBRACKET variable_list  
	{  if(var_num)	
         code("\n\t\tSUBS\t%%15,$%d,%%15", 4*var_num);	
        code("\n@%s_body:", get_name(fun_idx));
 	}

    statement_list _RBRACKET
	{ //zakucavanje returna za sve funckije koje nisu void 
		if(ima_return == 0) 
		{ 
			if(get_type(fun_idx) != VACANT) 
			{
				 err("Missing a return value.\n");
			} 		
		} 
	
	} 
  ;

variable_list
  : /* empty */
  | variable_list variable
  ;

variable
  : vars _SEMICOLON     
  ;

vars
  : _TYPE _ID
	 { 
	  var_type = $1;
          if(var_type == VACANT) { err("variable cannot be VACANT.\n");}
          else { 
	   if(lookup_symbol($2, VAR|PAR) == NO_INDEX)
           insert_symbol($2, VAR, var_type, ++var_num, NO_ATR);
          else 
           err("redefinition of '%s'", $2);
 	       }
      	 }

  | vars _COMMA _ID
	{ if(lookup_symbol($3, VAR|PAR) == NO_INDEX) 
		{
		insert_symbol($3, VAR, var_type, ++var_num, NO_ATR);
		} else 
		      { err("redefinition of '%s' ", $3); }
	}
			  
  ;

statement_list
  : /* empty */
  | statement_list statement
  ;

statement
  : compound_statement
  | assignment_statement
  | if_statement
  | return_statement { ima_return++; } 
  | para_statement
  | increment
  | break_statement
  | switch
  ;

compound_statement
  : _LBRACKET statement_list _RBRACKET
  ;

assignment_statement
  : _ID _ASSIGN num_exp _SEMICOLON
      {
        int idx = lookup_symbol($1, VAR|PAR|GLOB);
        if(idx == NO_INDEX)
          err("invalid lvalue '%s' in assignment", $1);
        else
          if(get_type(idx) != get_type($3))
            err("incompatible types in assignment");
	
	gen_mov($3, idx);
      }
  ;

num_exp
  : exp
  | num_exp _AROP exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: arithmetic operation");
	
	//printf("get type je: %d\n", get_type($3));  <- sirotinjski debager    
	if(get_type($2) == DIV && lookup_symbol(get_name($3), LIT) == lookup_symbol("0", LIT)) { warning("Cannot divide by zero!"); } 

	int t1 = get_type($1);    	
        code("\n\t\t%s\t", ar_instructions[$2 + (t1 - 1) * AROP_NUMBER]);	
        gen_sym_name($1);	
        code(",");	
        gen_sym_name($3);	
        code(",");	
        free_if_reg($3);	
        free_if_reg($1);	
        $$ = take_reg();	
        gen_sym_name($$);	
        set_type($$, t1);
      }

	
  ;

exp
  : literal
  | _ID
      {
        $$ = lookup_symbol($1, VAR|PAR|GLOB);
        if($$ == NO_INDEX)
          err("'%s' undeclared", $1);
      }
  | function_call
      {	
        $$ = take_reg();	
        gen_mov(FUN_REG, $$);	
      }
  | _LPAREN num_exp _RPAREN
      { $$ = $2; }
  | _ID _INC
      {
        $$ = lookup_symbol($1, VAR|PAR|GLOB);
        if( $$ == NO_INDEX)
          err("'%s' undeclared", $1);
      }
	
  ;

para_statement
  : _PARA _LPAREN _TYPE _ID _ASSIGN literal _SEMICOLON 
	{ 
	 if(lookup_symbol($4, VAR|PAR) == NO_INDEX) 
		{
		insert_symbol($4, VAR, $3, NO_ATR, NO_ATR); /*lokalna promenljiva treba da postoji samo u petlji, 
							      3. mesto ide no_atr umesto 								      ++var_num*/
		} else 
		      { err("redefinition of '%s' ", $4); }

		if(get_type($6) != $3) { err("Types in para are not matching.\n"); } //poklapanje tipa i literala 
		
	}
    rel_exp _SEMICOLON literal _RPAREN statement 
	{
	 int inc = lookup_symbol($4, VAR|PAR);	//smestamo lokalnu promenljivu deklarisanu na pocetku para
	 if(lookup_symbol(get_name($11), LIT) == lookup_symbol("0", LIT)) { err("Third argument cannot be 0.\n"); }
	 if($3 != get_type($11)) { err("Types in para are not matching.\n"); }
	 clear_symbols(inc); //brisemo lokalnu promenljivu po zavrsetku izvrsetka
	}
 

  ;


switch
  : _SWITCH _LPAREN _ID _RPAREN 
	 {
        int idx = lookup_symbol($3, VAR|PAR);
        if(idx == NO_INDEX)
          err("'%s' undeclared", $3);

	 switch_idx = get_type(idx); 
	 
	 }
	_LBRACKET switch_body _RBRACKET { case_cnt = 0;}
  ; 


case_statement
  : _CASE literal _POINTER statement
   	{
 
	if(switch_idx != get_type($2))
		err("incompatible types in switch-case (%s)", get_name($2));
	if(case_cnt == 0){
		case_vrednost[case_cnt] = atoi(get_name($2));
	}
	for(int i = 0; i < case_cnt; i++) { 
		if(atoi(get_name($2)) == case_vrednost[i]) { 
				err("case %s already used\n", get_name($2));
			 
		}else { 
			case_vrednost[case_cnt] = atoi(get_name($2));

   		     } 
	

	} 
	}
  | _CASE literal _POINTER statement break_statement
   	{

	if(switch_idx != get_type($2))
		err("incompatible types in switch-case (%s)", get_name($2));
	if(case_cnt == 0){
		case_vrednost[case_cnt] = atoi(get_name($2));
	}
	for(int i = 0; i < case_cnt; i++) 
	{ 
		if(atoi(get_name($2)) == case_vrednost[i]) 
		{ 
			err("case %s already used\n", get_name($2));
			 
		}else{ 
			case_vrednost[case_cnt] = atoi(get_name($2));

   		     } 

	} 
	}
  ;

otherwise_statement
  : _OTHERWISE _POINTER statement
  | _OTHERWISE _POINTER statement break_statement
  ;

case_statement_list
  : case_statement	{ case_cnt++;}
  | case_statement_list case_statement { case_cnt++; }
  ;

switch_body
//ovo je potrebno da bi se omogucilo da otherwise ide samo jedanput u switchu
  : case_statement_list
  | case_statement_list otherwise_statement
  ;

break_statement
  : _BREAK _SEMICOLON
  ;



increment
  : _ID _INC _SEMICOLON
    //provera da li postoji ID 
    {
        int idx = lookup_symbol($1, VAR|PAR|GLOB); //smestamo simbol u lokalnu promenljivu u int 
        if(idx == NO_INDEX)
          err("'%s' undeclared", $1);

	 code("\n\t\t%s\t", ar_instructions[0+(get_type(idx)-1) * AROP_NUMBER]);
	 gen_sym_name(idx);
	 code(",$1,");
	 gen_sym_name(idx);
	 free_if_reg(idx);
    }
  ;

literal
  : _INT_NUMBER
      { $$ = insert_literal($1, INT); }

  | _UINT_NUMBER
      { $$ = insert_literal($1, UINT); }
  ;

function_call
  : _ID 
      {
        fcall_idx = lookup_symbol($1, FUN);
        if(fcall_idx == NO_INDEX)
          err("'%s' is not a function", $1);
      }
    _LPAREN argument _RPAREN
      {
	int arp_brojac = 0; 
	if(get_atr1(fcall_idx) != 0) { arp_brojac++; } 
	if(get_atr2(fcall_idx) != 0) { arp_brojac++; }


        if(arp_brojac != $4)
          err("wrong number of args to function '%s'", 
              get_name(fcall_idx));
        code("\n\t\t\tCALL\t%s", get_name(fcall_idx));	
        if($4 > 0)	
          code("\n\t\t\tADDS\t%%15,$%d,%%15", $4 * 4);


        set_type(FUN_REG, get_type(fcall_idx));
        $$ = FUN_REG;

        
      }
  ;

argument
  : /* empty */
    { $$ = 0; }

  | num_exp
    { 
      if(get_atr1(fcall_idx) != get_type($1)) //menjana logika u funkciji 
        err("incompatible type for argument in '%s'",
            get_name(fcall_idx));

      free_if_reg($1);	
      code("\n\t\t\tPUSH\t");	
      gen_sym_name($1);
      $$ = 1;
    }
  | num_exp _COMMA num_exp
	{ 
		if(get_atr1(fcall_idx) != get_type($1) || get_atr2(fcall_idx) != get_type($3))
       		err("incompatible type for argument in '%s'",
            	get_name(fcall_idx));
      		$$ = 2;
	} 
  ;

if_statement	
  : if_part %prec ONLY_IF	
      { code("\n@exit%d:", $1); }	
  | if_part _ELSE statement	
      { code("\n@exit%d:", $1); }	
  ;	

if_part	
  : _IF _LPAREN	
      {	
        $<i>$ = ++lab_num;	
        code("\n@if%d:", lab_num);	
      }	
    rel_exp	
      {	
        code("\n\t\t%s\t@false%d", opp_jumps[$4], $<i>3);	
        code("\n@true%d:", $<i>3);	
      }	
    _RPAREN statement	
      {	
        code("\n\t\tJMP \t@exit%d", $<i>3);	
        code("\n@false%d:", $<i>3);	
        $$ = $<i>3;	
      }	
  ;	


rel_exp
  : num_exp _RELOP num_exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: relational operator");
	$$ = $2 + ((get_type($1) - 1) * RELOP_NUMBER);	
        gen_cmp($1, $3);
      }
  ;

return_statement
  : _RETURN num_exp _SEMICOLON
      { 
	if(get_type(fun_idx) == VACANT) 
	{
	 err("VACANT should not return a type.\n"); 
        }
        if(get_type(fun_idx) != get_type($2))  
          err("incompatible types in return");
        
	 gen_mov($2, FUN_REG);	
        code("\n\t\tJMP \t@%s_exit", get_name(fun_idx));
      }
  | _RETURN _SEMICOLON
      { 
	if(get_type(fun_idx) != VACANT) 
	{
	  warning("function should return a value.\n");
	}
      }
  ;

%%

int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s", yylineno, s);
  error_count++;
  return 0;
}

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  warning_count++;
}

	int main() {	
  int synerr;	
  init_symtab();	
  output = fopen("output.asm", "w+");	
  synerr = yyparse();	
  clear_symtab();	
  fclose(output);	
  	
  if(warning_count)	
    printf("\n%d warning(s).\n", warning_count);	
  if(error_count) {	
    remove("output.asm");	
    printf("\n%d error(s).\n", error_count);	
  }	
  if(synerr)	
    return -1;  //syntax error	
  else if(error_count)	
    return error_count & 127; //semantic errors	
  else if(warning_count)	
    return (warning_count & 127) + 127; //warnings	
  else	
    return 0; //OK	
}

