#include "vector.h"
#include <iostream>

using namespace std;

int main() {
    Vector<int> intVec{1, 3, 5, 7, 9};
    Vector<double> doubleVec{1.5, 2.5, 3.5, 4.5};
    Vector<int> iv{intVec};
    Vector<double> dv{doubleVec};

    cout << "intVec" << intVec << endl;
    cout << "iv" << iv << endl;
    cout << "doubleVec" << doubleVec << endl;
    cout << "dv" << dv << endl;

    cout << "intVec size: " << intVec.size() << endl;
    cout << "doubleVec size: " << doubleVec.size() << endl;

    // size()
    cout << "intVec size: " << intVec.size() << endl;
    cout << "doubleVec size: " << doubleVec.size() << endl;

    // operator [] (non-const)
    iv[0] = 100;
    cout << "iv: " << iv << endl;

    // operator [] (const)
    const Vector<int>& v = intVec;
    int firstConst = v[0];
    cout << "firstConst: " << firstConst << endl;

    // operator *
    cout << "intVec * iv: " << (intVec * iv) << endl;
    cout << "doubleVec * dv: " << (doubleVec * dv) << endl;

    // operator +
    Vector<int> intVec2{4, 5, 6, 7};
    Vector<int> sum = intVec + intVec2;
    cout << "sum: " << sum << endl;

    // operator =
    Vector<int> intVec3(2);
    intVec3 = intVec;
    cout << "intVec3: " << intVec3 << endl;

    // operator == & operator !=
    cout << (intVec == iv) << endl;
    cout << (intVec != iv) << endl;

    // friend operator * & friend operator +
    Vector<int> scaled = 3 * intVec;
    Vector<int> added = 10 + intVec;
    cout << "scaled" << scaled << endl;
    cout << "added" << added << endl;

    return 0;
}
