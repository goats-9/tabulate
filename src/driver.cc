#include "../include/driver.hh"
#include "runtime_env.hh"
#include <iostream>
#include <cstring>

extern FILE *yyin;
extern int yy_flex_debug;

namespace tabulate
{
    driver::driver()
    {
        // Initialize variables
        trace_parsing = false;
        trace_scanning = false;
        isLexOut = false;
        scope_level = 0;
        while_level = 0;
        num_main = 0;
        in_main = false;
        in_func = false;
        in_struct = false;
        in_construct = false;
        driver::symtab_init();
    }

    int driver::parse(const std::string &f)
    {
        // setting file name
        file = f;
        // initialize the location
        location.initialize(&file);
        if (scan_begin())
            return 1;
        // opening file
        outFile.open(remove_extension() + ".cc");
        // including preamble
        outFile << "#include \"" << RUNTIME_HEADER << "\"\n";
        outFile << "state st(\"" << file << "\");\n";
        // parsing starts
        yy::parser parse(*this);
        parse.set_debug_level(trace_parsing);
        int res = parse();
        // parsing ends
        scan_end();
        outFile.close();
        if (!res)
        {
            res = compile();
        }
        return res;
    }
    
    int driver::compile()
    {
        int res = std::system(("g++ " + remove_extension() + ".cc -g -L. -lruntime -o" + remove_extension() + ".out").c_str());
        return res;
    }

    bool driver::check_extension()
    {
        return true;
        // if (file.substr(file.find_last_of(".") + 1) == "tblt")
        //     return true;
        // return false;
    }
    
    // remove extension
    std::string driver::remove_extension()
    {
        return file.substr(0,file.find_last_of("."));
    }

    void driver::handleToken(yy::parser::symbol_type token, const std::string &text)
    {
        if (isLexOut)
        {
            std::cout << token.name() << ": " << text << "\n";
        }
    }
    
    int driver::scan_begin()
    {
        yy_flex_debug = trace_scanning;
        // checking extension
        if (!check_extension())
        {
            std::cerr << "Enter a .tblt file\n";
            return 1;
        }
        
        // opening file
        if (!(yyin = fopen(file.c_str(), "r")))
        {
            std::cerr << "cannot open " << file << ": " << strerror(errno) << '\n';
            return 1;
        }
        return 0;
    }

    void driver::scan_end()
    {
        fclose(yyin);
    }

    void driver::symtab_init() {
        // Initialize function symbol table with standard
        // functions offered by Tabulate
        std::vector<std::string> biop_func_names = 
        {
            "ADD",
            "SUB",
            "MUL",
            "DIV",
            "MOD",
            "POW",
            "BOR",
            "BAND",
            "BXOR",
            "BLS",
            "BRS",
            "AND",
            "OR",
            "XOR",
            "MODULUS",
            "POWER"
        };
        std::vector<std::string> uniop_func_names = 
        {
            "NOT",
            "BNOT",
            "TYPEOF",
            "LENGTH",
            "DISP",
            "SUM",
            "MINIMUM",
            "MAXIMUM",
            "AVERAGE",
            "PRODUCT",
            "COUNT",
            "CEILING",
            "FLOOR"
        };
        std::vector<std::string> biop_paramlist = {"p1","p2"};
        std::vector<std::string> uniop_paramlist = {"p1"};
        func_symtrec frec;
        frec.level = 0;
        frec.paramlist = biop_paramlist;
        for (auto u : biop_func_names) {
            symtab_func.tabulate_symtab[u].push(frec);
        }
        frec.paramlist = uniop_paramlist;
        for (auto u :uniop_func_names) {
            symtab_func.tabulate_symtab[u].push(frec);
        }
        // Initialize the symbol table with datatypes
        // offered by Tabulate
        std::vector<std::string> dtype_list = 
        {
            "table",
            "cell"
        };
        dtype_symtrec drec;
        drec.level = 0;
        drec.constr_args = {0,1};
        for (auto u : dtype_list) {
            symtab_dtype.tabulate_symtab[u].push(drec);
        }
    }

    void driver::delete_scope() {
        driver::symtab_dtype.delete_scope(driver::scope_level);
        driver::symtab_func.delete_scope(driver::scope_level);
        driver::symtab_id.delete_scope(driver::scope_level);
    }
}
