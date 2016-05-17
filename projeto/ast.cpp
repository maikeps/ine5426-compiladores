#include "ast.h"

using namespace AST;

extern ST::SymTable* symtable;
extern FT::FunTable* funtable;

std::string Block::printTree() {
	std::string retorno = "";
	for(Node* node : nodes) {
		if(node != NULL)
			retorno += node->printTree() + "\n";
	}
	return retorno;
}

std::string UnOp::printTree() {
	std::string retorno = "";
	retorno = next->printTree() + ")";
	retorno = "((" + Stringfier::unOpString(op) + " " + Stringfier::typeStringM(next->type) + ") " + retorno;
	this->type = next->type;
	return retorno;
}

std::string BinOp::printTree() {
	std::string retorno, lvalue, rvalue;
	retorno = "";
	lvalue = left->printTree();
	rvalue = right->printTree();
	std::string opString = Stringfier::binOpString(op);
	if (left->type != right->type){
		if(left->type == Type::inteiro && right->type == Type::real){
			lvalue += " para real";
		} else if (left->type == Type::real && right->type == Type::inteiro){
			rvalue += " para real";
		}
	}
    switch(op){
	case plus: case sub: case mult: case _div:
		retorno = "(" + lvalue + " (" + opString + " " + Stringfier::typeStringF(this->type) + ") " + rvalue + ")";
		break;
	case gt: case lt: case gte: case lte: case eq: case neq:
		retorno = "(" + lvalue + " (" + opString + " " + Stringfier::typeStringM(this->type) + ") " + rvalue + ")";
		break;
	case _and: case _or:
		retorno = "(" + lvalue + " (" + opString + " " + Stringfier::typeStringM(this->type) + ") " + rvalue + ")";
		break;
    }
    return retorno;
}

std::string Variable::printTree() {
	std::string retorno = Stringfier::typeString(this->type, this->arrExpr != NULL) + " " + this->name;
	if(this->arrExpr != NULL) {
		retorno += " {+indice: " + arrExpr->printTree() + "}";
	}
	return retorno;
}

std::string Const::printTree() {
	std::string retorno = "valor " + Stringfier::typeStringM(this->type) + " " + this->value;
	return retorno;
}

std::string AssignVar::printTree() {
	std::string retorno, lvalue, rvalue;
	retorno = "";
	lvalue = left->printTree();
	rvalue = right->printTree();
	if (left->type != right->type && left->type == Type::real && right->type == Type::inteiro){
		rvalue += " para real";
	}
	return "Atribuicao de valor para " + lvalue + ": " + rvalue;;
}

std::string DeclVar::printTree() {
	std::string retorno = "";
	
	Variable* next = (Variable *)this->next;
	bool isArr = next->arrExpr != NULL;
	retorno = "Declaracao de " + Stringfier::typeString(next->type, isArr);
	if(isArr) {
		retorno += " de tamanho " + ((Const*)(next->arrExpr))->value;
	}
	retorno += ": ";
	
	std::string vars = next->name;
	next = (Variable *)next->next;
	while(next != NULL){
		vars = next->name + ", " + vars;
		next = (Variable *)next->next;
	}
	retorno += vars;
	return retorno;
}

std::string Par::printTree() {
	std::string retorno = "((abre parenteses) " + this->content->printTree() + " (fecha parenteses))";
	return retorno;
}

std::string FunCall::printTree() {
	std::string retorno = "chamada de funcao " + Stringfier::typeStringF(this->type) + " " + this->name;
	retorno += " " + params->printTree();
	return retorno;
}

std::string Parameters::printTree(){
	std::string retorno = "{+parametros: ";
	retorno += this->parametros[0]->printTree();
	for(int i = 1; i < this->parametros.size(); i++){
		retorno += ", " + this->parametros[i]->printTree();
	}
	retorno += "}";
	return retorno;
}

std::string DeclFunc::printTree() {
	FT::Function* fun = funtable->getFunction(this->funName);
	std::string retorno = "Declaracao de funcao " + Stringfier::typeStringF(fun->returnType) + ": " + this->funName + "\n";
	retorno += "+parametros:\n";
	for(ST::Symbol* param : fun->parameters){
		retorno += "Parametro " + Stringfier::typeStringM(param->type) + ": " /*+ nome*/ + "\n";//TODO nome
	}
	retorno += "Fim declaracao";
	return retorno;
}

std::string DefFunc::printTree() {
	FT::Function* fun = funtable->getFunction(this->funName);
	std::string retorno = "Definicao de funcao " + Stringfier::typeStringF(fun->returnType) + ": " + this->funName + "\n";
	retorno += "+parametros:\n";
	for(ST::Symbol* param : fun->parameters){
		retorno += "Parametro " + Stringfier::typeStringM(param->type) + ": " /*+ nome*/ + "\n";//TODO nome
	}
	retorno += "+corpo:\n";
	retorno += this->code->printTree();
	retorno += "Fim definicao";
	return retorno;
}

std::string Return::printTree() {
	return "Retorno de funcao: " + this->expr->printTree();
}