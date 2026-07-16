Transform :: struct {   // 100 bytes
    position : Vector3      = .{ 0.0, 0.0, 0.0 };
    rotation_deg : Vector3  = .{ 0.0, 0.0, 0.0 };
    scale : Vector3         = .{ 1.0, 1.0, 1.0 };

    model : Matrix4;

    is_dirty : bool = true;
};

SetTransformPosition :: (transform : *Transform, position : Vector3) {
    transform.position = position;
    transform.is_dirty = true;
}

SetTransformRotation :: (transform : *Transform, rotation_deg : Vector3) {
    transform.rotation_deg = rotation_deg;
    transform.is_dirty = true;
}

SetTransformScale :: (transform : *Transform, scale : Vector3) {
    transform.scale = scale;
    transform.is_dirty = true;
}

#scope_module
CalculateTransformModelMatrix :: (transform : *Transform) {
    using,except(scale) transform.*;

    // @TODO: rewrite this rotation_matrix stuff to use quaternions or rotors
    rotation_matrix := Matrix4_Identity;
    RotateMatrix4(*rotation_matrix, DegToRad(rotation_deg.y), V3_POS_Y);
    RotateMatrix4(*rotation_matrix, DegToRad(rotation_deg.x), V3_POS_X);
    RotateMatrix4(*rotation_matrix, DegToRad(rotation_deg.z), V3_POS_Z);

    model = Matrix4_Identity;
    scale(*model, transform.scale);
    model = rotation_matrix * model;
    translate(*model, position);

    is_dirty = false;
}
