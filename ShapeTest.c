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

// Shape

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

// Circle

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
    Shape_Shape((Shape*)_this, name);
    _this -> VPointer = Circle_VTable;
    _this -> radius = r;
    return _this;
}

// Square

struct Square {
    VTableType VPointer;
    const char* name;
    int side;
};

static double Square_area(Square* _this) {return _this -> side * _this -> side;}

static void Square_draw(Square* _this) {
    cout << "*****************" << '\n';
    cout << "*               *" << '\n';
    cout << "*               *" << '\n';
    cout << "*               *" << '\n';
    cout << "*               *" << '\n';
    cout << "*               *" << '\n';
    cout << "*               *" << '\n';
    cout << "*****************" << '\n';
}

static const char* Square_dims(Square* _this) {
    static string s;
    s = to_string(_this -> side);
    return s.c_str();
}

static VirtualTableEntry Square_VTable[] = {
    {.double_method = (double_method_type) Square_area},
    {.void_method = (void_method_type) Square_draw},
    {.cstring_method = (cstring_method_type) Square_dims}
};

static Square* Square_Square(Square* _this, const char* _name, int side) {
    Shape_Shape((Shape*)_this, name);
    _this -> VPointer = Square_VTable;
    _this -> side = side;
    return _this;
}

// Rectangle

struct Rectangle {
    VTableType VPointer;
    const char* name;
    int width;
    int height;
};

static double Rectangle_area(Rectangle* _this) {return _this -> width * _this -> height;}

static void Rectangle_draw(Rectangle* _this) {
    cout << "*****************" << '\n';
    cout << "*               *" << '\n';
    cout << "*               *" << '\n';
    cout << "*               *" << '\n';
    cout << "*               *" << '\n';
    cout << "*****************" << '\n';
}

static const char* Rectangle_dims(Rectangle* _this) {
    static string s;
    s = to_string(_this -> width) + ", " + to_string(_this -> height);
    return s.c_str();
}

static VirtualTableEntry Rectangle_VTable[] = {
    {.double_method = (double_method_type) Rectangle_area},
    {.void_method = (void_method_type) Rectangle_draw},
    {.cstring_method = (cstring_method_type) Rectangle_dims}
};

static Rectangle* Rectangle_Rectangle(Rectangle* _this, const char* _name, int width, int height) {
    Shape_Shape((Shape*)_this, _name);
    _this -> VPointer = Rectangle_VTable;
    _this -> width = width;
    _this -> height = height;
    return _this;
}

// Triangle

struct Triangle {
    VTableType VPointer;
    const char* name;
    int base;
    int height;
};

static double Triangle_area(Triangle* _this) {return 0.5 * _this -> base * _this -> height;}

static void Triangle_draw(Triangle* _this) {
    cout << "        *   " << '\n';
    cout << "      *   *  " << '\n';
    cout << "     *     * " << '\n';
    cout << "    *       * " << '\n';
    cout << "   *         * " << '\n';
    cout << "  *           * " << '\n';
    cout << " *             * " << '\n';
    cout << "*****************" << '\n';
}

static const char* Triangle_dims(Triangle* _this) {
    static string s;
    s = to_string(_this -> base) + ", " + to_string(_this -> height);
    return s.c_str();
}

static VirtualTableEntry Triangle_VTable[] = {
    {.double_method = (double_method_type) Triangle_area},
    {.void_method = (void_method_type) Triangle_draw},
    {.cstring_method = (cstring_method_type) Triangle_dims},
};

static Triangle* Triangle_Triangle(Triangle* _this, const char* _name, int base, int height) {
    Shape_Shape((Shape*)_this, _name);
    _this -> VPointer = Triangle_VTable;
    _this -> base = base;
    _this -> height = height;
    return _this;
}

// Picture functions

static double total_area(Shape** shapes, int count) {
    double sum_area = 0.0;
    for (int i = 0; i < count; i++) {
        sum_area += shapes[i] -> VPointer[AREA_INDEX].double_method(shapes[i]);
    }
    return sum_area;
}
