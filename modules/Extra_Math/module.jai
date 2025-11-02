#import "Math";

DEG2RAD : float : PI/180.0;
RAD2DEG : float : 180.0/PI;

DegToRad :: (deg : float) -> rad : float { return deg * DEG2RAD; }
RadToDeg :: (rad : float) -> deg : float { return rad * DEG2RAD; }

// rotate matrix4 in place. this should really be in the standard library imo
RotateMatrix4 :: (m : *Matrix4, angle : float, axis : Vector3) {
    q : Quaternion;
    set_from_axis_and_angle(*q, axis, angle);
    new_m : Matrix4 = rotate(m, q);     // rotates out of place, ew
    memcpy(m, *new_m, size_of(Matrix4));
}

MakeFrustumMatrix :: (fovYRad : float, aspectRatio : float, front : float, back : float) -> Matrix4 {
    tangent := tan(fovYRad/2.0);
    top := front * tangent;
    right := top * aspectRatio;

    matrix : Matrix4;
    matrix.floats[0]   = front / right;
    matrix.floats[5]   = front / top;
    matrix.floats[10]  = -(back + front) / (back - front);
    matrix.floats[11]  = -(2 * back * front) / (back - front);
    matrix.floats[14]  = -1;
    //matrix.floats[15]  = 0;
    return matrix;
}
