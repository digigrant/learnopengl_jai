#import "SDL";
#import "Math";
#import "Basic";

#import "Graphics"; // only need this for Camera. Should be removed.
#import "GL";       // only needed for window resize. should be removed.
#import "Events";

// global consts
#if OS == {
    case .WINDOWS;
        JOYSTICK_LEFT_THUMBSTICK_X  :: 0;
        JOYSTICK_LEFT_THUMBSTICK_Y  :: 1;
        JOYSTICK_RIGHT_THUMBSTICK_X :: 2;
        JOYSTICK_RIGHT_THUMBSTICK_Y :: 3;
        JOYSTICK_LEFT_TRIGGER       :: 4;
        JOYSTICK_RIGHT_TRIGGER      :: 5;

    case .LINUX;
        JOYSTICK_LEFT_THUMBSTICK_X  :: 0;
        JOYSTICK_LEFT_THUMBSTICK_Y  :: 1;
        JOYSTICK_RIGHT_THUMBSTICK_X :: 3;
        JOYSTICK_RIGHT_THUMBSTICK_Y :: 4;
        JOYSTICK_LEFT_TRIGGER       :: 2;
        JOYSTICK_RIGHT_TRIGGER      :: 5;
}

JOYSTICK_DEADZONE       :: 3200 / S16_MAX.(float);
TRIGGER_DEADZONE        :: 0.01;

// global variables
keyboard_state : *u8;
keyboard_state_prev : *u8;
keyboard_state_length : s32;
joysticks : [..] *SDL_Joystick;

Init :: () -> ok : bool {
    if SDL_InitSubSystem(SDL_INIT_JOYSTICK) {
        print("Couldn't initialize SDL_INIT_JOYSTICK: %\n", to_string(SDL_GetError()));
        return false;
    }

    keyboard_state = SDL_GetKeyboardState(*keyboard_state_length); // get pointer to array of keyboard states; doesn't need to change for lifetime of program
    if !keyboard_state {
        print("Could not get keyboard state array.\n");
        return false;
    }
    keyboard_state_prev = alloc(keyboard_state_length);
    memset(keyboard_state_prev, 0, keyboard_state_length);

    // set mouse capture settings
    SDL_ShowCursor(0); // there's no SDL_DISABLE enum?????? 
    SDL_SetRelativeMouseMode(SDL_TRUE);
    
    // gamepads
    SDL_JoystickEventState(1);
    return true;
}

Shutdown :: () {
    SDL_QuitSubSystem(SDL_INIT_JOYSTICK);
}

// TODO: there's a lot of crap in this file that maybe shouldn't be here
// "Game Engine Architecture" might shed some light on what should live here
// (It didnt)

ProcessInput :: (exit : *bool, deltaTimeSeconds : float, camera : *Camera) {
    // poll events
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        //print("RECEIVED EVENT: %\n", event.type);
        if event.type == {
            case SDL_QUIT; (exit.*) = true;
            case SDL_KEYUP;
                if event.key.keysym.sym == SDLK_ESCAPE { (exit.*) = true; }
            case SDL_WINDOWEVENT;
                if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
                    using context;
                    windowWidth, windowHeight = xx event.window.data1, xx event.window.data2;
                    // should only need to call this when window is resized
                    glViewport(0, 0, windowWidth, windowHeight);
                }
            case SDL_JOYDEVICEADDED; #through;
            case SDL_JOYDEVICEREMOVED;
                RefreshJoysticks();
            
            case SDL_MOUSEMOTION;
                event_data := cast(*EventData_MousePosition) temporary_alloc(size_of(EventData_MousePosition));
                event_data.* = .{
                    x_relative = event.motion.xrel,
                    y_relative = event.motion.yrel
                };
                NotifyEvent(.INPUT_MOUSE_POSITION, event_data);
        }
    }

    // events should be flushed. now we can read keyboard state
    movementKeyPressed := false;
    zoomKeyPressed := false;
    translation : Vector3;
    zoom : float;

    if keyboard_state[SDL_Scancode.SDL_SCANCODE_W] ApplyMovement(*translation, .{z=1.0}, *movementKeyPressed);
    if keyboard_state[SDL_Scancode.SDL_SCANCODE_S] ApplyMovement(*translation, .{z=-1.0}, *movementKeyPressed);
    if keyboard_state[SDL_Scancode.SDL_SCANCODE_A] ApplyMovement(*translation, .{x=-1.0}, *movementKeyPressed);
    if keyboard_state[SDL_Scancode.SDL_SCANCODE_D] ApplyMovement(*translation, .{x=1.0}, *movementKeyPressed);
    if keyboard_state[SDL_Scancode.SDL_SCANCODE_E] ApplyMovement(*translation, .{y=1.0}, *movementKeyPressed);
    if keyboard_state[SDL_Scancode.SDL_SCANCODE_Q] ApplyMovement(*translation, .{y=-1.0}, *movementKeyPressed);
    if keyboard_state[SDL_Scancode.SDL_SCANCODE_R] ApplyZoom(*zoom,  1.0, *zoomKeyPressed);
    if keyboard_state[SDL_Scancode.SDL_SCANCODE_F] ApplyZoom(*zoom, -1.0, *zoomKeyPressed);
    if keyboard_state[SDL_Scancode.SDL_SCANCODE_Z] && !keyboard_state_prev[SDL_Scancode.SDL_SCANCODE_Z] NotifyEvent(.INPUT_KEYBOARD_Z_PRESSED);

    // check every single key and send appropriate events 
    /*
    for 0..keyboard_state_length-1 {
        if 
    }
    */

    // at the end of keyboard input, we must copy keyboard_state to keyboard_state_prev
    memcpy(keyboard_state_prev, keyboard_state, keyboard_state_length * size_of(u8));

    // Gamepad input
    if joysticks.count > 0 {
        start_button := SDL_JoystickGetButton(joysticks[0], 7);
        if start_button then (exit.*) = true;

        left_thumbstick := GetJoystickThumbstickNormalized(joysticks[0], JOYSTICK_LEFT_THUMBSTICK_X, JOYSTICK_LEFT_THUMBSTICK_Y);
        right_thumbstick := GetJoystickThumbstickNormalized(joysticks[0], JOYSTICK_RIGHT_THUMBSTICK_X, JOYSTICK_RIGHT_THUMBSTICK_Y);

        if length(left_thumbstick) > JOYSTICK_DEADZONE {
            ApplyMovement(*translation, .{x=left_thumbstick.x}, *movementKeyPressed);
            ApplyMovement(*translation, .{z=left_thumbstick.y}, *movementKeyPressed);
        }

        if length(right_thumbstick) > JOYSTICK_DEADZONE {
            CAMERA_SENSITIVITY :: 300.0;
            CameraRotate(camera, .{right_thumbstick.y, right_thumbstick.x} * deltaTimeSeconds * CAMERA_SENSITIVITY);
        }

        //for 0..SDL_JoystickNumButtons(joysticks[0])-1 print("% ", SDL_JoystickGetButton(joysticks[0], it));
        //print("\n");

        left_shoulder := SDL_JoystickGetButton(joysticks[0], 4);
        right_shoulder := SDL_JoystickGetButton(joysticks[0], 5);
        if left_shoulder ApplyMovement(*translation, .{y=-1.0}, *movementKeyPressed);
        if right_shoulder ApplyMovement(*translation, .{y=1.0}, *movementKeyPressed);

        triggers := GetJoystickTriggersNormalized(joysticks[0]);
        ZOOM_MULTIPLIER :: 2.0;
        if triggers.x > TRIGGER_DEADZONE ApplyZoom(*zoom, -triggers.x * ZOOM_MULTIPLIER, *zoomKeyPressed);
        if triggers.y > TRIGGER_DEADZONE ApplyZoom(*zoom, triggers.y * ZOOM_MULTIPLIER, *zoomKeyPressed);
    }

    if movementKeyPressed {
        cameraSpeed := 2.5 * deltaTimeSeconds;
        CameraTranslate(camera, translation * cameraSpeed);
    }

    if zoomKeyPressed {
        zoomSpeed := 15.0 * deltaTimeSeconds;
        CameraZoom(camera, zoom * zoomSpeed);
    }
}

ApplyMovement :: (translation : *Vector3, delta : Vector3, movementKeyPressed : *bool) {
    (translation.*) += delta;
    (movementKeyPressed.*) = true;
}

ApplyZoom :: (zoom : *float, delta : float, zoomKeyPressed : *bool) {
    (zoom.*) += delta;
    (zoomKeyPressed.*) = true;
}

RefreshJoysticks :: () {
    for joysticks SDL_JoystickClose(it);
    array_reset(*joysticks);

    if SDL_NumJoysticks() > 0 {
        print("Found joysticks:\n");
        for 0..SDL_NumJoysticks()-1 {
            array_add(*joysticks, SDL_JoystickOpen(it));
            print("\tJoystick %: %\n", it, to_string(SDL_JoystickNameForIndex(it).(*u8)));
        }
    } else {
        print("No joysticks found\n");
    }
}

GetJoystickThumbstickNormalized :: (joystick : *SDL_Joystick, x_axis : s32, y_axis : s32, invert_y : bool = true) -> Vector2 {
    thumbstick_x := SDL_JoystickGetAxis(joystick, x_axis);
    thumbstick_y := ifx invert_y then ~SDL_JoystickGetAxis(joystick, y_axis) else SDL_JoystickGetAxis(joystick, y_axis);
    thumbstick_normalized : Vector2 = .{
        ifx thumbstick_x > -1 then thumbstick_x / S16_MAX.(float) else thumbstick_x / -(S16_MIN.(float)),
        ifx thumbstick_y > -1 then thumbstick_y / S16_MAX.(float) else thumbstick_y / -(S16_MIN.(float))
    };

    return thumbstick_normalized;
}

GetJoystickTriggersNormalized :: (joystick : *SDL_Joystick) -> Vector2 {
    left_trigger : s32 = SDL_JoystickGetAxis(joystick, JOYSTICK_LEFT_TRIGGER);
    right_trigger : s32 = SDL_JoystickGetAxis(joystick, JOYSTICK_RIGHT_TRIGGER);
    triggers_normalized : Vector2 = .{
        (left_trigger - S16_MIN.(s32)) / U16_MAX.(float),
        (right_trigger - S16_MIN.(s32)) / U16_MAX.(float)
    };
    return triggers_normalized;
}
