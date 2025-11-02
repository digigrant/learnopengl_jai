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
