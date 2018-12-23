module util.math;

import std.algorithm;
import std.range;
import std.math;


struct V3(T) {
    union {
        struct {
            T x, y, z;
        }
        T[3] e;
    }
    
    this(T x, T y, T z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    this(T[] v) {
        x = v[0];
        y = v[1];
        z = v[2];
    }

    V3!T add(T)(V3!T v) {
        return V3!T(vec_add!T(this.e, v.e));
    }

    V3!T sub(T)(V3!T v) {
        return V3!T(vec_sub!T(this.e, v.e));
    }

    T dot(T)(V3!T v) {
        return vec_dot!T(this.e, v.e);
    }

    V3!T norm(T)() {
        return V3!T(vec_norm(this.e));
    }
}

struct V4(T) {
    union {
        struct {
            T x, y, z, w;
        }
        T[4] e;
    }

    V4!T add(T)(V4!T v) {
        return V4!T(vec_add!T(this.e, v.e));
    }

    V4!T sub(T)(V4!T v) {
        return V4!T(vec_sub!T(this.e, v.e));
    }

    T dot(T)(V4!T v) {
        return vec_dot(this.e, v.e);
    }

    V4!T norm(T)() {
        return V4!T(vec_norm(this.e));
    }
}

T[] vec_sub(T)(T[] v1, T[] v2) {
    T[] r;
    foreach (i; 0..v1.length) {
        r ~= v1[i] - v2[i];
    }
    return r;
}

T[] vec_add(T)(T[] v1, T[] v2) {
    T[] r;
    foreach (i; 0..v1.length) {
        r ~= v1[i] + v2[i];
    }
    return r;
}

T vec_dot(T)(T[] v1, T[] v2) {
    T r = 0;
    foreach (i; 0..v1.length) {
        r += (v1[i] + v2[i]);
    }
    return r;
}

T[] vec_norm(T)(T[] v) {
    T length = 0;
    foreach (i; 0..v.length) {
        length += v[i] * v[i];
    }
    T denom = sqrt(length);
    T[] r;
    foreach (i; 0..v.length) {
        r ~= v[i] / denom;
    }
    return r;
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

    Mat4!T transpose() {
        Mat4!T m;
        foreach (i; 0..4) {
            foreach (j; 0..4) {
                m.e[i][j] = e[j][i];
            }
        }
        return m;
    }

    float[16] to_gl() {
        float[16] r;
        auto n = 0;
        foreach (i; 0..4) {
            foreach (j; 0..4) {
                r[n] = e[i][j];
                n++;
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

double to_rad(double d) {
    return d * PI / 180;
}

struct Quat(T) {
    //docs: https://www.gamasutra.com/view/feature/131686/rotating_objects_using_quaternions.php
    //we use the transpose of the rotation matrix though
	union {
		struct {
			T w, x, y, z;
		}
		T[4] e;
	}

    this(T)(V3!T axis, T angle)
    {
        w = cos(angle / 2.0);
        x = axis.x * sin(angle / 2.0f);
        y = axis.y * sin(angle / 2.0f);
        z = axis.z * sin(angle / 2.0f);
    }

    V3!T get_axis(T)()
    {
        V3!T r;
        T length = sqrt(x * x + y * y + z * z);
        if (length > 0.0f)
        {
            r.x = x / length;
            r.y = y / length;
            r.z = z / length;
        }
        return r;
    }

    Quat!T conj(T)()
    {
        Quat r;
        r.x = -x;
        r.y = -y;
        r.z = -z;
        r.w = w;
        return r;
    }

    V4!T to_v4(T)()
    {
        V4!T r;
        r.x = x;
        r.y = y;
        r.z = z;
        r.w = w;
        return r;
    }

    Mat4!T rotation_matrix(T)()
    {
        auto x2 = x + x;
        auto y2 = y + y;
        auto z2 = z + z;
        auto xx = x * x2;
        auto xy = x * y2;
        auto xz = x * z2;
        auto yy = y * y2;
        auto yz = y * z2;
        auto zz = z * z2;
        auto wx = w * x2;
        auto wy = w * y2;
        auto wz = w * z2;

        Mat4!T r;
        r.e[0][0] = 1 - yy - zz;
        r.e[1][0] = xy + wz;
        r.e[2][0] = xz - wy;
        r.e[3][0] = 0;
        r.e[0][1] = xy - wz;
        r.e[1][1] = 1 - xx - zz;
        r.e[2][1] = yz + wx;
        r.e[3][1] = 0;
        r.e[0][2] = xz + wy;
        r.e[1][2] = yz - wx;
        r.e[2][2] = 1 - xx - yy;
        r.e[3][2] = 0;
        r.e[0][3] = 0;
        r.e[1][3] = 0;
        r.e[2][3] = 0;
        r.e[3][3] = 1;
        return r;
    }

    T dot(T)(Quat!T q2)
    {
        return w * q2.w + x * q2.x + y * q2.y + z * q2.z;
    }

    Quad norm(T)()
    {
        Quad q;
        T length = sqrt(this.dot(this));
        if (length > 0.0)
        {
            q.w = w / length;
            q.x = x / length;
            q.y = y / length;
            q.z = z / length;
        }
        return q;
    }

    V3!T apply_rotation_to(T)(V3!T v)
    {
        V4!T tmp = { v.x, v.y, v.z, 1.0f };
        V4!T new_v= this.rotation_matrix().mul(tmp);
        return V3!T( new_v.x, new_v.y, new_v.z );
    }

}

//t is a parametrized value that goes from 0 to 1
//see wikipedia on slerp
//Quat quat_slerp(Quat Start, Quat Finish, r32 t)
//{
	//Quat V1 	= quat_norm(Start);
	//Quat V2 	= quat_norm(Finish);
	//r32 Dot 	= quat_dot(V1, V2);

    //const double DOT_THRESHOLD = 0.9995;
    //if (fm_Abs(Dot) > DOT_THRESHOLD) 
    //{
        // If the inputs are too close, linearly interpolate
        // and normalize the result.
        //Quat Result = Start + t*(Finish - Start);
        //Result = quat_norm(Result);
        //return Result;
    //}

	// If the dot product is negative, the quaternions
    // have opposite handed-ness and slerp won't take
    // the shorter path. Fix by reversing one quaternion. (see wikipedia)
    //if (Dot < 0.0f) {
        //V2 = -V2;
        //Dot = -Dot;
    //} 
	//r32 Theta_0 = acos(Dot);
	//r32 Theta 	= Theta_0 * t;
	//Quat V3 	= quat_norm(V2 - V1*Dot);

	//return V1 * cos(Theta) + V3 * sin(Theta);
//}

