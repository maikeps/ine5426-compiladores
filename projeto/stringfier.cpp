#include "stringfier.h"

std::string Stringfier::typeString(Type type, bool isArr) {
	if(isArr) {
		return "arranjo " + typeStringM(type);
	} else {
		return "variavel " + typeStringF(type);
	}
}

std::string Stringfier::typeStringM(Type type) {
	switch(type) {
		case desconhecido: return "desconhecido";
		case inteiro: return "inteiro";
		case real: return "real";
		case booleano: return "booleano";
		case composto: return "composto";
	}
}

std::string Stringfier::typeStringF(Type type) {
	switch(type) {
		case desconhecido: return "desconhecida";
		case inteiro: return "inteira";
		case real: return "real";
		case booleano: return "booleana";
		case composto: return "composta";
	}
}

std::string Stringfier::binOpString(BinOperation op) {
	switch(op) {
		case plus: return "soma";
		case sub: return "subtracao";
		case mult: return "multiplicacao";
		case _div: return "divisao";
		case gt: return "maior";
		case lt: return "menor";
		case gte: return "maior ou igual";
		case lte: return "menor ou igual";
		case eq: return "igual";
		case neq: return "diferente";
		case _and: return "e";
		case _or: return "ou";
	}
}

std::string Stringfier::unOpString(UnOperation op) {
	switch(op) {
		case _not: return "nao";
		case neg: return "menos unario";
	}
}