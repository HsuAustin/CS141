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

static Shape* Shape_Shape(Shape* _this, const char* _name) {
    _this -> VPointer = Shape_VTable;
    _this -> name = _name;
    return _this;
}

struct Circle {
    VTableType VPointer;
    const char* name;
    int radius;
}

static const char* Circle_area(Circle* _this) {return PI * _this -> radius * _this -> radius;}
static void Circle_draw(Circle* _this) {
    cout << "       ***   " << '\n';
    cout << "   *         *" << '\n';
    cout << " *             *" << '\n';
    cout << "*               *" << '\n';
    cout << "*               *" << '\n';
    cout << " *             *" << '\n';
    cout << "   *         *" << '\n';
    cout << "       ***   " << '\n';
}
static const char* Circle_dims(Circle* _this) {
    static string s;
    s = to_string(_this -> radius);
    return s.c_str();
}

static VirtualTableEntry Circle_VTable[] = {
    {.double_method = (double_method_type) Circle_area},
    {.void_method = (void_method_type) Circle_draw},
    {.cstring_method = (cstring_method_type) Circle_dims}
};

static Circle* Circle_Circle(Circle* _this, const char* _name, int r) {
    Shape_Shape(Shape* _this, name);
    _this -> VPointer = Circle_VTable;
    _this -> radius = r;
    return _this;
}
