#pragma once
#include <string>
#include <vector>
#include <memory>
#include <iostream>
#include <fstream>

enum class NodeType {
    PROGRAM,
    VAR_DECL,
    ASSIGNMENT,
    BINARY_EXPR,
    NUMBER,
    IDENTIFIER,
    IF_STMT,
    WHILE_STMT,
    BLOCK
};

struct ASTNode {
    NodeType type;
    std::string value;
    std::vector<std::shared_ptr<ASTNode>> children;

    ASTNode(NodeType t, const std::string& val = "") : type(t), value(val) {}

    void addChild(std::shared_ptr<ASTNode> child) {
        if (child) children.push_back(child);
    }

    void toJSON(std::ostream& out, int indent = 0) const {
        std::string ind(indent * 2, ' ');
        out << ind << "{\n";
        out << ind << "  \"name\": \"" << escapeJSON(getNodeName()) << "\",\n";
        out << ind << "  \"children\": [\n";
        for (size_t i = 0; i < children.size(); ++i) {
            children[i]->toJSON(out, indent + 2);
            if (i + 1 < children.size()) out << ",";
            out << "\n";
        }
        out << ind << "  ]\n";
        out << ind << "}";
    }

    std::string generateCode(int& tempVarCounter, std::ostream& codeOut) const {
        if (type == NodeType::NUMBER || type == NodeType::IDENTIFIER) {
            return value;
        }
        if (type == NodeType::BINARY_EXPR) {
            std::string left = children[0]->generateCode(tempVarCounter, codeOut);
            std::string right = children[1]->generateCode(tempVarCounter, codeOut);
            std::string temp = "t" + std::to_string(tempVarCounter++);
            codeOut << "  " << temp << " = " << left << " " << value << " " << right << ";\n";
            return temp;
        }
        if (type == NodeType::ASSIGNMENT) {
            std::string val = children[1]->generateCode(tempVarCounter, codeOut);
            codeOut << "  " << children[0]->value << " = " << val << ";\n";
            return children[0]->value;
        }
        if (type == NodeType::VAR_DECL) {
            codeOut << "  // Decl: " << value << "\n";
            if (!children.empty()) {
                std::string val = children[0]->generateCode(tempVarCounter, codeOut);
                codeOut << "  " << value << " = " << val << ";\n";
            }
            return "";
        }
        for (const auto& child : children) {
            child->generateCode(tempVarCounter, codeOut);
        }
        return "";
    }

private:
    std::string getNodeName() const {
        switch (type) {
            case NodeType::PROGRAM: return "Program";
            case NodeType::VAR_DECL: return "VarDecl (" + value + ")";
            case NodeType::ASSIGNMENT: return "Assign (=)";
            case NodeType::BINARY_EXPR: return "Op (" + value + ")";
            case NodeType::NUMBER: return "Num: " + value;
            case NodeType::IDENTIFIER: return "ID: " + value;
            case NodeType::IF_STMT: return "If";
            case NodeType::WHILE_STMT: return "While";
            case NodeType::BLOCK: return "Block";
            default: return "Node";
        }
    }

    static std::string escapeJSON(const std::string& s) {
        std::string res;
        for (char c : s) {
            if (c == '"') res += "\\\"";
            else if (c == '\\') res += "\\\\";
            else res += c;
        }
        return res;
    }
};