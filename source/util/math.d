module util.math;

import std.algorithm;
import std.range;

struct V4(T) {
    union {
        struct {
            T x, y, z, w;
        }
        T[4] e;
    }
}

struct Mat4(T) {
    T[4][4] e;

    Mat4!T add(Mat4!T a) {
        Mat4!T mat;
        foreach (i; 0..4) {
            foreach (j; 0..4) {
                mat.e[i][j] = e[i][j] + a.e[i][j];
            }
        }
        return mat;
    }

    V4!T mul(V4!T v) {
        V4!T r;
        foreach (i; 0..4) {
            T tmp = 0;
            foreach (j; 0..4) {
                tmp += (e[i][j] * v.e[j]);
            }
            r.e[i] = tmp;
        }
        return r;
    }

    Mat4!T clone() {
        Mat4!T m;
        foreach (i; 0..4) {
            foreach (j; 0..4) {
                m.e[i][j] = e[i][j];
            }
        }
        return m;
    }

    bool equals(Mat4!T m) {
        bool r = true;
        foreach (i; 0..4) {
            foreach (j; 0..4) {
                r = m.e[i][j] == e[i][j];
            }
        }
        return r;
    }
};

unittest {
    auto e = eye4!float();
    e.e[0][3] = 1;
    e.e[1][3] = 2;
    e.e[2][3] = 3;
    auto v = V4!float(2, 4, 5, 1);
    auto r = e.mul(v);
    assert(r.x == 3);
    assert(r.y == 6);
    assert(r.z == 8);
    assert(r.w == 1);
}

Mat4!T mat4(T)() {
    Mat4!T mat;
    foreach (i; 0..4) {
        foreach (j; 0..4) {
            mat.e[i][j] = 0;
        }
    }
    return mat;
}

Mat4!T eye4(T)(T v = 1) {
    auto mat = mat4!T();
    iota(0, 4).each!((e, i) => mat.e[i][i] = v);
    return mat;
} 

Mat4!T translate(T)(Mat4!T m, V4!T v) {
    auto m2 = m.clone();
    m2.e[0][3] = v.x;
    m2.e[1][3] = v.y;
    m2.e[2][3] = v.z;
    return m2;
}

unittest {
    auto v = V4!float(1, 2, 3, 1);
    auto m = translate(eye4!float(), v);
    auto expected = eye4!float();
    expected.e[0][3] = 1;
    expected.e[1][3] = 2;
    expected.e[2][3] = 3;
    assert(m.equals(expected));
}
