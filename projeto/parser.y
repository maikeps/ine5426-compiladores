%{
#include <string>
#include "ast.h"
#include "symtable.h"
#include "funtable.h"
#include "enums.h"

AST::Block* root;
ST::SymTable* symtable = new ST::SymTable(NULL);

// rotina para deleção de escopo:
// oldSymtable = symtable;
// symtable = symtable->superScope;
// delete oldSymtable;

FT::FunTable* funtable = new FT::FunTable();

extern int yylex();
extern void yyerror(const char* s, ...);	
%}

%define parse.trace

%union {
	const char* inteiro;
	const char* real;
	const char* booleano;
	const char* id;

	Type typeEnum;
	// std::vector<ST::Symbol*>* parameters;
	AST::Arguments* argList;

	AST::Node* node;
	AST::Block* block;
}

//Definição dos tokens
%token <inteiro> T_INT
%token <real> T_REAL
%token <booleano> T_BOOL
%token <id> T_ID
%token T_PLUS T_MULT T_SUB T_DIV T_ATTR
%token T_AND T_OR T_NOT
%token T_APAR T_FPAR 
%token T_AARR T_FARR
%token T_DINT T_DREAL T_DBOOL
%token T_NEQ T_EQ T_GTE T_GT T_LTE T_LT 
%token T_COLON T_ENDL T_COMMA
%token T_DEF T_DECL T_END T_FUN T_RET
%token T_IF T_THEN T_ELSE

//Definição de tipos não-terminais
%type <block> program cmds funcmds
%type <node> cmd funcmd decl listvar attr expr const arr arrexpr fun params
%type <typeEnum> type
// %type <parameters> params
%type <argList> arglist

//Precedencia de operadores
%left T_EQ T_NEQ
%left T_LT T_GT T_LTE T_GTE
%left T_PLUS T_SUB
%left T_MULT T_DIV
%right U_NEG T_NOT
%left U_PAR
%nonassoc error

%start program

%%

program	: cmds { root = $1; }
;

//code	: cmds
//		| fun
//		| code cmds
//		| code fun

cmds	: cmd { 
			$$ = new AST::Block(); 
			$$->nodes.push_back($1);
		}
		| cmds cmd {
			if($2 != NULL) $1->nodes.push_back($2);
		}
		;

cmd 	: decl T_ENDL
		| attr T_ENDL
		| fun//cond
        | error T_ENDL {yyerrok; $$=NULL;}
		;

funcmds : funcmd { 
//			symtable = new ST::SymTable(symtable);

			$$ = new AST::Block(); 
			$$->nodes.push_back($1);
		}
		| funcmds funcmd {
			if($2 != NULL) $1->nodes.push_back($2);
		}
		;

funcmd 	: decl T_ENDL
		| attr T_ENDL

		| T_RET expr T_ENDL {
			$$ = new AST::Return($2);
		}
        | error T_ENDL {yyerrok; $$=NULL;}
		;

decl	: type arr T_COLON listvar { 
			AST::Variable* var = (AST::Variable*) $4;
			while(var != NULL) {
				var->arrExpr = $2;
				ST::Symbol* s = symtable->getSymbol(var->name);
				s->setType($1);
				var->type = s->type;
				var = (AST::Variable*) var->next;
			}
			$$ = new AST::DeclVar($4);
		}
		;

arr 	: T_AARR T_INT T_FARR {
			$$ = new AST::Const($2, Type::inteiro);
		}
		| { 
			$$ = NULL;
		}
		;

arrexpr : T_AARR expr T_FARR {
			$$ = $2;
		}
		| { 
			$$ = NULL;
		}

listvar	: T_ID {
			symtable->addSymbol($1);
			$$ = new AST::Variable($1, NULL);
		}
		| listvar T_COMMA T_ID {
			symtable->addSymbol($3);
			$$ = new AST::Variable($3, $1);
		}
		;

attr 	: T_ID arrexpr T_ATTR expr {
			AST::Variable* var = new AST::Variable($1, NULL);
			var->type = symtable->getSymbol($1)->type;
			var->arrExpr = $2;
			symtable->setSymbol($1);
			$$ = new AST::AssignVar(var, $4, $2);
		}
		;

expr	: const 
		| T_ID arrexpr { 
			AST::Variable* var = new AST::Variable($1, NULL);
			var->type = symtable->useSymbol($1)->type;
			var->arrExpr = $2;
			$$ = var;
		}
		| T_ID T_APAR arglist T_FPAR {
			AST::FunCall* fun = new AST::FunCall($1, $3);
			//TODO trocar por use
			fun->type = funtable->getFunction($1)->returnType;
			$$ = fun;
		}
		| expr T_PLUS expr {
			$$ = new AST::BinOp($1, plus, $3);
		}
		| expr T_SUB expr {
			$$ = new AST::BinOp($1, sub, $3);
		}
		| expr T_MULT expr {
			$$ = new AST::BinOp($1, mult, $3);
		}
		| expr T_DIV expr {
			$$ = new AST::BinOp($1, _div, $3);
		}
		| expr T_EQ expr {
			$$ = new AST::BinOp($1, eq, $3);
		}
		| expr T_NEQ expr {
			$$ = new AST::BinOp($1, neq, $3);
		}
		| expr T_LT expr {
			$$ = new AST::BinOp($1, lt, $3);
		}
		| expr T_GT expr {
			$$ = new AST::BinOp($1, gt, $3);
		}
		| expr T_LTE expr {
			$$ = new AST::BinOp($1, lte, $3);
		}
		| expr T_GTE expr {
			$$ = new AST::BinOp($1, gte, $3);
		}
		| expr T_AND expr {
			$$ = new AST::BinOp($1, _and, $3);
		}
		| expr T_OR expr {
			$$ = new AST::BinOp($1, _or, $3);
		}
		| T_SUB expr %prec U_NEG { 
			$$ = new AST::UnOp(neg, $2);
		}
		| T_NOT expr { 
			$$ = new AST::UnOp(_not, $2);
		}
		| T_APAR expr T_FPAR %prec U_PAR { 
			$$ = new AST::Par($2);
		}
		;

arglist : expr {
			$$ = new AST::Arguments();
			$$->arguments.push_back($1);
		}
		| arglist T_COMMA expr {
			if($3 != NULL) $1->arguments.push_back($3);
		}
		;

fun 	: T_DECL T_FUN type T_COLON T_ID T_APAR params T_FPAR T_ENDL {
			std::vector<ST::Symbol*> symbols;
			AST::Variable* aux = (AST::Variable*)$7;
			while(aux != NULL){
				symbols.push_back(new ST::Symbol(aux->type));
				aux = (AST::Variable*) aux->next;
			}
			FT::Function* fun = new FT::Function($3, symbols);
			funtable->addFunction($5, fun);
			$$ = new AST::DeclFunc($5, new AST::Parameters($7));
			$$->type = $3;
		}
		| T_DEF T_FUN type T_COLON T_ID T_APAR params T_FPAR funcmds T_END T_DEF {
			std::vector<ST::Symbol*> temp;
			AST::Variable* aux = (AST::Variable*)$7;
			while(aux != NULL){
				temp.push_back(new ST::Symbol(aux->type));
				aux = (AST::Variable*) aux->next;
			}
			std::vector<ST::Symbol*> symbols;
			/*for(int i = temp.size()-1; i >= 0; i++){
				symbols.push_back(temp[i]);
			}*/
			FT::Function* fun = new FT::Function($3, temp);
			funtable->defFunction($5, fun);
			$$ = new AST::DefFunc($5, new AST::Parameters($7), $9);
			$$->type = $3;

			ST::SymTable* oldSymtable = symtable;
			symtable = symtable->superScope;
			delete oldSymtable;
			printf("velho escopo");
			if(symtable->superScope == NULL)
				printf("deu certo");
		}
		;

const   : T_INT { $$ = new AST::Const($1, Type::inteiro); }
		| T_REAL { $$ = new AST::Const($1, Type::real); }
		| T_BOOL { $$ = new AST::Const($1, Type::booleano); }
		;

type 	: T_DINT { $$ = Type::inteiro; }
		| T_DREAL { $$ = Type::real; }
		| T_DBOOL { $$ = Type::booleano; }
		;

params	: type T_COLON T_ID {
		printf("novo escopo");
			symtable = new ST::SymTable(symtable);
			symtable->addSymbol($3, $1);
			if(symtable->superScope == NULL)
				printf("deu errado");
			AST::Variable* var = new AST::Variable($3, NULL);
			var->type = $1;
			$$ = var;
		}
		| params T_COMMA type T_COLON T_ID {
			symtable->addSymbol($5, $3);
			AST::Variable* var = new AST::Variable($5, $1);
			var->type = $3;
			$$ = var;
		}
		| {
			printf("novo escopo");
			symtable = new ST::SymTable(symtable);
			$$ = NULL;
		}
		;

%%
