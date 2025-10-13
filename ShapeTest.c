
#include <iostream>
#include <string>
#include <cstdlib>

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
};

static double Circle_area(Circle* _this) {return PI * _this -> radius * _this -> radius;}

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
    Shape_Shape((Shape*)_this, _name);
    _this -> VPointer = Circle_VTable;
    _this -> radius = r;
    return _this;
}

struct Triangle {
    VTableType VPointer;
    const char* name;
    int base;
    int height;
};

static double Triangle_area(Triangle* _this) {return _this -> base * _this -> height / 2;}

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
    Shape_Shape((Shape*)_this, _name);
    _this -> VPointer = Square_VTable;
    _this -> side = side;
    return _this;
}

struct Rectangle {
    VTableType VPointer;
    const char* name;
    int side;
    int width;
};

static double Rectangle_area(Rectangle* _this) {return _this -> side * _this -> width;}

static void Rectangle_draw(Rectangle* _this) {
    cout << "**********************" << '\n';
    cout << "*                    *" << '\n';
    cout << "*                    *" << '\n';
    cout << "*                    *" << '\n';
    cout << "*                    *" << '\n';
    cout << "**********************" << '\n';
}

static const char* Rectangle_dims(Rectangle* _this) {
    static string s;
    s = to_string(_this -> side) + ", " + to_string(_this -> width);
    return s.c_str();
}

static VirtualTableEntry Rectangle_VTable[] = {
    {.double_method = (double_method_type) Rectangle_area},
    {.void_method = (void_method_type) Rectangle_draw},
    {.cstring_method = (cstring_method_type) Rectangle_dims}
};

static Rectangle* Rectangle_Rectangle(Rectangle* _this, const char* _name, int side, int width) {
    Square_Square((Square*)_this, _name, side);
    _this -> VPointer = Rectangle_VTable;
    _this -> width = width;
    return _this;
}

static void drawAll(Shape** shapes, int count) {
    for (int i = 0; i < count; i++) {
        shapes[i] -> VPointer[DRAW_INDEX].void_method(shapes[i]);
    }
}

static void printAll(Shape** shapes, int count) {
    for (int i = 0; i < count; ++i) {
        const char* dims = shapes[i] -> VPointer[DIMS_INDEX].cstring_method(shapes[i]);
        double area = shapes[i] -> VPointer[AREA_INDEX].double_method(shapes[i]);
        cout << shapes[i] -> name << "(" << dims << ") : " << area << "\n";
    }
}

static double totalArea(Shape** shapes, int count) {
    double sum_area = 0.0;
    for (int i = 0; i < count; i++) {
        sum_area += shapes[i] -> VPointer[AREA_INDEX].double_method(shapes[i]);
    }
    return sum_area;
}

int main(int argc, char* argv[]) {
    int arg1 = stoi(argv[1]);
    int arg2 = stoi(argv[2]);
    int arg3 = arg1 - 1;
    int arg4 = arg2 - 1;

    Shape* shapes[] = {
        (Shape*)Triangle_Triangle((Triangle*)malloc(sizeof(Triangle)), "FirstTriangle", arg1, arg2),
        (Shape*)Triangle_Triangle((Triangle*)malloc(sizeof(Triangle)), "SecondTriangle", arg3, arg4),
        (Shape*)Circle_Circle((Circle*)malloc(sizeof(Circle)), "FirstCircle", arg1),
        (Shape*)Circle_Circle((Circle*)malloc(sizeof(Circle)), "SecondCircle", arg3),
        (Shape*)Square_Square((Square*)malloc(sizeof(Square)), "FirstSquare", arg1),
        (Shape*)Square_Square((Square*)malloc(sizeof(Square)), "SecondSquare", arg3),
        (Shape*)Rectangle_Rectangle((Rectangle*)malloc(sizeof(Rectangle)), "FirstRectangle", arg1, arg2),
        (Shape*)Rectangle_Rectangle((Rectangle*)malloc(sizeof(Rectangle)), "SecondRectangle", arg3, arg4),
    };

    const size_t total = sizeof(shapes) / sizeof(shapes[0]);

    printAll(shapes, total);
    drawAll(shapes, total);
    cout << "Total : " << totalArea(shapes, total) << "\n";

    return 0;
}
