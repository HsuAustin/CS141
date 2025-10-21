#ifndef VECTOR_H
#define VECTOR_H
#include <iostream>
using namespace std;

template <typename T>
class vector {
    private:
        size_t sz;
        T* buf;

    public:
        Vector(size_t sz): sz(sz), buf(nullptr) {if (sz > 0) {buf = new T[sz]();}}

        Vector(initializer_list<T> L): sz(L.size()), buf(nullptr) {
            if (sz > 0) {
                buf = new T[sz];
                size_t i = 0;
                for (auto j = L.begin(); j != L.end(); ++j, ++i) {buf[i] = *j;}
            }
        } 

        ~Vector() {
            delete [] buf;
            buf = nullptr;
            sz = 0;
        }

        Vector(const Vector &v): sz(v.sz), buf(nullptr) {
            if (sz > 0) {
                buf = new T[sz];
                for (size_t i = 0; i < sz; i++) {buf[i] = v.buf[i];}
            }
        }

        size_t size() const {return sz;}

        T& operator [] (const int i) {
            if (i < 0 || static_cast<size_t> i >= sz) {throw out_of_range("Vector index out of bounds");}
            return buf[i];
        }

        T operator [] (const int i) const {
            if (i < 0 || static_cast<size_t> i >= sz) {throw out_of_range("Vector index out of bounds");}
            return buf[i];
        }

        T operator * (const Vector &v) const {
            if (sz == 0 || v.sz == 0) {return T{};}
            size_t n = (sz < v.sz) ? sz : v.sz;
            T sum = T{};
            for (size_t i = 0; i < n; i++) {sum += buf[i] * v.buf[i];}
            return sum;
        }

        Vector operator + (const Vector &v) const {
            const size_t n = (sz > v.sz) ? sz : v.sz;
            Vector<T> out(n);
            for (size_t i = 0; i < n; i++) {
                T a = (i < sz) ? buf[i] : T{};
                T b = (i < v.sz) ? v.buf[i] : T{};
                out.buf[i] = a + b;
            }
            return out;
        }

        const Vector& operator = (const Vector &v) {
            if (this == &v) {return *this;}
            delete [] buf;
            buf = nullptr;
            sz = v.sz;
            if (sz > 0) {
                buf = new T[sz];
                for (size_t i = 0; i < sz; i++) {buf[i] = v.buf[i];}
            }
            return *this;
        }

        bool operator == (const Vector &v) const {
            if (sz != v.sz) {return false;}
            for (size_t i = 0; i < sz; i++) {if (!(buf[i] == v.buf[i])) {return false;}}
            return true;
        }

        bool operator != (const Vector &v) const {return !(*this == v);}

        inline friend Vector operator * (const int scale, const Vector &v) {
            Vector<T> out(v.sz);
            for (size_t i = 0; i < v.sz; i++) {out.buf[i] = static_cast<T> scale * v.buf[i];}
            return out;
        }

        inline friend Vector operator + (const int adder, const Vector &v) {
            Vector<T> out(v.sz);
            for (size_t i = 0; i < v.sz; i++) {out.buf[i] = v.buf[i] + static_cast<T> adder;}
            return out;
        }

        inline friend ostream& operator << (ostream &o, const Vector &v) {
            o << '(';
            for (size_t i = 0; i < v.sz; i++) {
                o << v.buf[i];
                if (i + 1 < v.sz) {o << ", ";}
            }
            o << ')';
            return o;
        }
};

#endif
