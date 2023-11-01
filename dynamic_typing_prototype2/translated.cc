#include "runtime.hh"

class myclass
{
public:
    // Preamble starts
    map<string,any> mem;
    map<string,any(myclass::*)(vector<any>)> func;
    map<string,int> func_params;
    myclass(const myclass &a)
    {
        func_decl();
        mem_decl();
        mem = a.mem;
        func = a.func;
        func_params = a.func_params;
    }
    // Preamble ends

    // func_def starts
    any test(vector<any> a)
    {
        return a[0];
    }
    // func_def ends
    void func_decl()
    {
        // func_decl starts
        func["test"] = &myclass::test;
        func_params["test"] = 1;
        // func_decl ends
    }
    void mem_decl()
    {
        // mem_decl starts
        // mem_decl ends
    }
    // Constructor_defination starts
    myclass()
    {
        func_decl();
        mem_decl();
    }
    myclass(any a, any b)
    {
        func_decl();
        mem_decl();
        mem["at1"] = a;
        mem["at2"] = b;
    }
    // Constructor_defination ends
};

inline void any::Constructor(const any &a)
{
    if (a.type == "myclass")
    {
        data = new myclass(*(myclass *)a.data);
        type = "myclass";
    }
}
inline void any::Destructor()
{
    if (type == "myclass")
    {
        delete (myclass *)data;
    }
}
inline any &any::Accessor(const string &id)
{
    if (type == "myclass")
    {
        myclass *ptr = (myclass *)data;

        return ptr->mem[id];
    }
}
inline any any::Runner(const string &id,const vector<any> &params)
{
    if (type == "myclass")
    {
        any (myclass::*f)(vector<any>);
        myclass *ptr = (myclass *)data;
        f = ptr->func[id];
        if (!f)
        {
            throw runtime_error(type + " does not have any method " + id);
        }
        return (ptr->*f)(params);
    }
}

int main()
{
    try
    {
        any a = any(new int(67), "int");
        const any b = any(new string("90"), "string");
        any arr = any(new vector<any>{
            any(new vector<any>{
                any(new int(9), "int")
            }, "array") ,
            any(new vector<any>{
                any(new string("hello"), "string"),
                any(new string("world"), "string")
            },"array")
        },"array");
        cout << arr.at(any(new int(2),"int")) << "\n";
    }
    catch (const runtime_error &e)
    {
        cerr << e.what() << '\n';
        return 1;
    }

    return 0;
}