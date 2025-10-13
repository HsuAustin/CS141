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

#define AREA_INDEX 0
#define DRAW_INDEX 1
#define DIMS_INDEX 2

#define PI 3.14159

struct Shape {
    VTableType VPointer;
    const char* name;
};

static double Shape_area(Shape* _this) {return 0.0;}
static void Shape_draw(Shape* _this) {}
static const char* Shape_dims(Shape* _this) {return "";}

static VirtualTableEntry Shape_VTable[] = {
    {.double_method = (double_method_type) Shape_area},
    {.void_method = (void_method_type) Shape_draw},
    {.cstring_method = (cstring_method_type) Shape_dims}
};
