#import "Math";

DEG2RAD : float : PI/180.0;
RAD2DEG : float : 180.0/PI;

V3_POS_X :: Vector3.{ 1.0, 0.0, 0.0};
V3_NEG_X :: Vector3.{-1.0, 0.0, 0.0};
V3_POS_Y :: Vector3.{ 0.0, 1.0, 0.0};
V3_NEG_Y :: Vector3.{ 0.0,-1.0, 0.0};
V3_POS_Z :: Vector3.{ 0.0, 0.0, 1.0};
V3_NEG_Z :: Vector3.{ 0.0, 0.0,-1.0};

DegToRad :: (deg : float) -> rad : float { return deg * DEG2RAD; }
RadToDeg :: (rad : float) -> deg : float { return rad * DEG2RAD; }

// rotate matrix4 in place. this should really be in the standard library imo
RotateMatrix4 :: (m : *Matrix4, angle : float, axis : Vector3) {
    q : Quaternion;
    set_from_axis_and_angle(*q, axis, angle);
    new_m : Matrix4 = rotate(m, q);     // rotates out of place, ew
    memcpy(m, *new_m, size_of(Matrix4));
}

// why the hell is this not in the standard Math lib x_x
Log2 :: (x : $T) -> float {
    return log(x.(float)) / #run log(2);
}
