/* Abstract Syntax Tree */
#pragma once

#include <vector>
#include "symtable.h"
#include "types.h"

namespace AST {

enum UnOperation {
	decl,
	_not,
	neg
};

enum BinOperation {
	plus,
	sub,
	mult,
	div,
	gt,
	lt,
	gte,
	lte,
	eq,
	neq,
	_and,
	_or,
	assign
};

class Node;

typedef std::vector<Node*> NodeList;

class Node {
public:
    virtual ~Node() {}
    virtual std::string printTree() {return "";}
    Type type;
};

class Block : public Node {
public:
	NodeList nodes;
	Block() {}
	std::string printTree();
};

class UnOp : public Node {
public:
	UnOperation op;
	Node* next;

	UnOp(UnOperation op, Node* next) : op(op), next(next) {}
	std::string printTree();
};

class BinOp : public Node {
public:
	BinOperation op;
	Node* left;
	Node* right;

	BinOp(Node* left, BinOperation op, Node* right) : left(left), op(op), right(right) {}
	std::string printTree();
};

class Variable : public Node {
public:
	std::string name;
	Node* next;
	Variable(std::string name, Node* next) : name(name), next(next) {}
	std::string printTree();
};

class Const : public Node {
public:
	std::string value;
	Const(std::string value, Type type) : value(value) {
		this->type = type;
	}
	std::string printTree();
};

}