#import "Math";
#import "Extra_Stuff";
#import "Events";

Camera :: struct {
    position : Vector3;

    // all rotations are stored in radians
    using rotation : Vector3;
    #overlay (x) pitch : float;
    #overlay (y) yaw : float;

    right : Vector3;
    up : Vector3;
    front : Vector3;
    world_up : Vector3;

    fov : float;

    event_queue : EventQueue;
};

PITCH_MAX :: #run DegToRad(89.0);
FOV_MIN :: 1.0;
FOV_MAX :: 45.0;

CreateCamera :: (initialPosition : Vector3 = .{0.0, 0.0, 0.0}, initialRotationDeg : Vector3 = .{0.0, -90.0, 0.0}, worldUp : Vector3 = .{0.0, 1.0, 0.0}) -> camera : *Camera {
    camera := New(Camera);
    if camera == null return null;

    using camera;

    world_up = worldUp;
    position = initialPosition;
    rotation = .{
        DegToRad(initialRotationDeg.x),
        DegToRad(initialRotationDeg.y),
        DegToRad(initialRotationDeg.z)
    };
    fov = 45.0;

    UpdateVectors(camera);

    ListenForEventType(*event_queue, .INPUT_MOUSE_POSITION);

    return camera;
}

CameraUpdate :: (using camera : *Camera, delta_time_seconds : float) {
    event : EventInfo;
    while PollEvents(*event_queue, *event) {
        if event.type == {
            case .INPUT_MOUSE_POSITION; {
                CAMERA_MOTION_MULTIPLIER :: 0.1;
                data := cast(*EventData_MousePosition) event.data;
                CameraRotate(camera, .{
                    -data.y_relative * CAMERA_MOTION_MULTIPLIER,
                     data.x_relative * CAMERA_MOTION_MULTIPLIER
                });
            }
            case; print("Unexpected event type: %\n", event.type);
        }
    }
}

FreeCamera :: (camera : **Camera) {
    if camera == null || (camera.*) == null return;
    free(camera.*);
    (camera.*) = null;
}

CameraTranslate :: (using camera : *Camera, translation : Vector3) {
    position += translation.x * right;
    position += translation.y * up; 
    position += translation.z * front;
    // could this be done using matrix multiplication? maybe
}

CameraRotate :: (using camera : *Camera, rotationDeg : Vector2) {
    rotation += Vector3.{
        DegToRad(rotationDeg.x),
        DegToRad(rotationDeg.y),
        0.0
    };
    Clamp(*pitch, -PITCH_MAX, PITCH_MAX);
    UpdateVectors(camera);
}

// TODO: roll your own. Close to something very good
CameraGetViewMatrix :: (using camera : *Camera) -> view : Matrix4 {
    return make_look_at_matrix(position, position + front, up, false);
}

CameraZoom :: (using camera : *Camera, deltaFov : float) {
    fov -= deltaFov;
    Clamp(*fov, FOV_MIN, FOV_MAX);
}

#scope_file

UpdateVectors :: (using camera : *Camera) {
    // first calculate front vector using pitch and yaw
    front = .{
        cos(yaw) * cos(pitch),
        sin(pitch),
        sin(yaw) * cos(pitch)
    };

    // next calculate right vector using front and world_up
    right = normalize(cross(world_up, -front));

    // finally calculate actual up vector
    up = normalize(cross(-front, right));

    /*
    print("right: %\n", right);
    print("up: %\n", up);
    print("front: %\n", front);
    */
}