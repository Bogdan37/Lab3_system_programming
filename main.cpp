#include <iostream>
#include <fstream>
#include <cstdio>
#include <memory>
#include "ast.hpp"

extern int yyparse();
extern FILE* yyin;
extern std::shared_ptr<ASTNode> root;

int main(int argc, char** argv) {
    FILE* file = nullptr;
    if (argc > 1) {
        file = fopen(argv[1], "r");
        if (!file) {
            std::cerr << "Не вдалося відкрити файл " << argv[1] << std::endl;
            return 1;
        }
        yyin = file;
    }

    std::cout << "Початок розбору..." << std::endl;
    if (yyparse() == 0 && root) {
        std::cout << "Розбір успішний!" << std::endl;

        std::ofstream jsonFile("visualizer/ast.json");
        root->toJSON(jsonFile);
        jsonFile.close();
        std::cout << "Дерево збережено у visualizer/ast.json" << std::endl;

        std::ofstream codeFile("generated_code.ir");
        int tempCounter = 0;
        codeFile << "// --- Згенерований IR код ---\n";
        root->generateCode(tempCounter, codeFile);
        codeFile.close();
        std::cout << "Згенерований код збережено у generated_code.ir" << std::endl;
    } else {
        std::cerr << "Помилка під час парсингу." << std::endl;
    }

    if (file) {
        fclose(file);
    }

    return 0;
}