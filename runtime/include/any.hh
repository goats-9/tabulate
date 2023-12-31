#pragma once

class pos;
#include <string>
#include <vector>

class any
{
private:
    void Constructor(const any &a);
    void Destructor();
    any &Accessor(const std::string &id);
    any Runner(const std::string &id, const std::vector<any> &params,const pos &p);
    void construct(const any &a);
    void destruct();

public:
    void *data;
    std::string type;
    // default constructor
    any()
    {
        this->data = NULL;
        this->type = "none";
    }
    // constructor for compiler
    any(void *_data, const std::string &_type)
    {
        data = _data;
        type = _type;
    }
    // copy constructor
    any(const any &a)
    {
        construct(a);
    }
    // assignment operator
    void operator=(const any &a)
    {
        destruct();
        construct(a);
    }
    // access member
    any &access(const std::string &id,const pos&p);

    // run method
    any run(const std::string &id, const std::vector<any> &params, const pos &p);

    // accessing array elements
    any &at(const any &i,const pos &p);
    
    ~any()
    {
        destruct();
    }
};

/* operator overloading starts */

// == operator
bool operator==(const any &a, const any &b);

// != operator
bool operator!=(const any &a, const any &b);

// > operator
bool operator>(const any &a, const any &b);

// >= operator
bool operator>=(const any &a, const any &b);

// < operator
bool operator<(const any &a, const any &b);

// <= operator
bool operator<=(const any &a, const any &b);

// << operator
std::ostream &operator<<(std::ostream &o, const any &a);

/* operator overloading ends */