CXX = g++
CXXFLAGS = -std=c++17 -Wall

all: parser

parser.tab.cpp parser.tab.hpp: parser.y
	bison -d -o parser.tab.cpp parser.y

lex.yy.c: lexer.l parser.tab.hpp
	flex lexer.l

parser: lex.yy.c parser.tab.cpp main.cpp ast.hpp
	$(CXX) $(CXXFLAGS) -o parser parser.tab.cpp lex.yy.c main.cpp

clean:
	rm -f parser lex.yy.c parser.tab.cpp parser.tab.hpp visualizer/ast.json generated_code.ir
