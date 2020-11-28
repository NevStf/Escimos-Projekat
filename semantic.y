%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"

  int yyparse(void);
  int yylex(void);
  int yyerror(char *s);
  void warning(char *s);

  extern int yylineno;
  char char_buffer[CHAR_BUFFER_LENGTH];
  int error_count = 0;
  int warning_count = 0;
  int var_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;
  int ima_return = 0;
  

  //definisanje var_type
  int var_type = 0;
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


%type <i> num_exp exp literal function_call argument rel_exp 

%nonassoc ONLY_IF
%nonassoc _ELSE

%%

program
  : function_list
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
      }
    _LPAREN parameters _RPAREN body
      {
        clear_symbols(fun_idx + 1);
        var_num = 0;
	ima_return = 0;
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
  : _LBRACKET variable_list statement_list _RBRACKET
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
  | increment
  ;

compound_statement
  : _LBRACKET statement_list _RBRACKET
  ;

assignment_statement
  : _ID _ASSIGN num_exp _SEMICOLON
      {
        int idx = lookup_symbol($1, VAR|PAR);
        if(idx == NO_INDEX)
          err("invalid lvalue '%s' in assignment", $1);
        else
          if(get_type(idx) != get_type($3))
            err("incompatible types in assignment");
      }
  ;

num_exp
  : exp
  | num_exp _AROP exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: arithmetic operation");
      }
  ;

exp
  : literal
  | _ID
      {
        $$ = lookup_symbol($1, VAR|PAR);
        if($$ == NO_INDEX)
          err("'%s' undeclared", $1);
      }
  | function_call
  | _LPAREN num_exp _RPAREN
      { $$ = $2; }
  | _ID _INC
      {
        $$ = lookup_symbol($1, VAR|PAR);
        if( $$ == NO_INDEX)
          err("'%s' undeclared", $1);
      }
	
  ;

increment
  : _ID _INC _SEMICOLON
    //provera da li postoji ID 
    {
        
        if(lookup_symbol($1, VAR|PAR) == NO_INDEX)
          err("'%s' undeclared", $1);
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
        if(get_atr1(fcall_idx) != $4)
          err("wrong number of args to function '%s'", 
              get_name(fcall_idx));
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
  | if_part _ELSE statement
  ;

if_part
  : _IF _LPAREN rel_exp _RPAREN statement
  ;



rel_exp
  : num_exp _RELOP num_exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: relational operator");
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

  synerr = yyparse();

  clear_symtab();
  
  if(warning_count)
    printf("\n%d warning(s).\n", warning_count);

  if(error_count)
    printf("\n%d error(s).\n", error_count);

  if(synerr)
    return -1; //syntax error
  else
    return error_count; //semantic errors
}

