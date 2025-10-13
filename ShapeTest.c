#include <iostream>
#include <string>
#include <cstring>

using namespace std;

typedef double (*double_method_type)(void*);
typedef void (*void_method_type)(void*);
typedef const char* (*cstring_method_type)(void*);

typedef union {
    double_method_type double_method;
    void_method_type void_method;
    cstring_method_type cstring_method;
} VirtualTableEntry;

typedef VirtualTableEntry* VTableType;

#define DIMS_INDEX 0
#define AREA_INDEX 1
#define DRAW_INDEX 2

#define PI 3.14159

struct Shape {
    VTableType VPointer;
    const char* name;
};

static Shape* Shape_shape(Shape* _this, const char* nm) {
    _this -> name = nm;
    return _this;
}
