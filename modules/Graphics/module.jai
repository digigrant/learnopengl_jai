#load "Camera.jai";
#load "Material.jai";
#load "Mesh.jai";
#load "Model.jai";
#load "Shader.jai";
#load "Texture.jai";
#load "TextureLibrary.jai";
#load "VertexObjects.jai";

#import "SDL";
#import "GL";

#if OS == {
    case .WINDOWS;
        JOYSTICK_LEFT_THUMBSTICK_X  :: 0;
        JOYSTICK_LEFT_THUMBSTICK_Y  :: 1;
        JOYSTICK_RIGHT_THUMBSTICK_X :: 2;
        JOYSTICK_RIGHT_THUMBSTICK_Y :: 3;
        JOYSTICK_LEFT_TRIGGER       :: 4;
        JOYSTICK_RIGHT_TRIGGER      :: 5;
        CAMERA_SENSITIVITY :: 0.08;

    case .LINUX;
        JOYSTICK_LEFT_THUMBSTICK_X  :: 0;
        JOYSTICK_LEFT_THUMBSTICK_Y  :: 1;
        JOYSTICK_RIGHT_THUMBSTICK_X :: 3;
        JOYSTICK_RIGHT_THUMBSTICK_Y :: 4;
        JOYSTICK_LEFT_TRIGGER       :: 2;
        JOYSTICK_RIGHT_TRIGGER      :: 5;
        CAMERA_SENSITIVITY :: 3.0;
}

// global consts
DEFAULT_WINDOW_WIDTH    :: 800;
DEFAULT_WINDOW_HEIGHT   :: 600;

JOYSTICK_DEADZONE       :: 3200 / S16_MAX.(float);
TRIGGER_DEADZONE        :: 0.01;

// global variables
window : *SDL_Window;
windowWidth : u32 = DEFAULT_WINDOW_WIDTH;
windowHeight : u32 = DEFAULT_WINDOW_HEIGHT;
keyboardState : *u8;
joysticks : [..] *SDL_Joystick;

Init :: () -> ok : bool {
    if SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK) {
        print("Couldn't initialize SDL: %\n", to_string(SDL_GetError()));
        return false;
    }

    // set GL attributes
    // documentation says this should be done before window creation
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3); // OpenGL 3.3

    // create window
    window = SDL_CreateWindow("LearnOpenGL_Jai", SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED, xx windowWidth, xx windowHeight,
        SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE); // can add resizing, input focus, etc
    if window == null {
        print("Could not create window: %\n", to_string(SDL_GetError()));
        return false;
    }

    // create gl context
    // we dont really need this later
    gl_context := SDL_GL_CreateContext(window);
    if !gl_context {
        print("Could not create OpenGL context: %\n", to_string(SDL_GetError()));
        return false;
    }

    // initialize GLAD
    gl_load(*gl, SDL_GL_GetProcAddress);
    // we should check that it was initialized correctly.... but i dont know how

    keyboardState = SDL_GetKeyboardState(null); // get pointer to array of keyboard states; doesn't need to change for lifetime of program
    if !keyboardState {
        print("Could not get keyboard state array.\n");
        return false;
    }

    // set mouse capture settings
    SDL_ShowCursor(0); // there's no SDL_DISABLE enum?????? 
    SDL_SetRelativeMouseMode(SDL_TRUE);

    
    // gamepads
    SDL_JoystickEventState(1);

    return true;
}

Shutdown :: () {
    SDL_DestroyWindow(window);
    SDL_Quit();
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
                xoffset := event.motion.xrel * 0.1;
                yoffset := event.motion.yrel * 0.1;
                CameraRotate(camera, .{-yoffset, xoffset});

        }
    }

    // events should be flushed. now we can read keyboard state
    movementKeyPressed := false;
    zoomKeyPressed := false;
    translation : Vector3;
    zoom : float;

    if keyboardState[SDL_Scancode.SDL_SCANCODE_W] ApplyMovement(*translation, .{z=1.0}, *movementKeyPressed);
    if keyboardState[SDL_Scancode.SDL_SCANCODE_S] ApplyMovement(*translation, .{z=-1.0}, *movementKeyPressed);
    if keyboardState[SDL_Scancode.SDL_SCANCODE_A] ApplyMovement(*translation, .{x=-1.0}, *movementKeyPressed);
    if keyboardState[SDL_Scancode.SDL_SCANCODE_D] ApplyMovement(*translation, .{x=1.0}, *movementKeyPressed);
    if keyboardState[SDL_Scancode.SDL_SCANCODE_E] ApplyMovement(*translation, .{y=1.0}, *movementKeyPressed);
    if keyboardState[SDL_Scancode.SDL_SCANCODE_Q] ApplyMovement(*translation, .{y=-1.0}, *movementKeyPressed);
    if keyboardState[SDL_Scancode.SDL_SCANCODE_R] ApplyZoom(*zoom,  1.0, *zoomKeyPressed);
    if keyboardState[SDL_Scancode.SDL_SCANCODE_F] ApplyZoom(*zoom, -1.0, *zoomKeyPressed);

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
            CameraRotate(camera, .{right_thumbstick.y, right_thumbstick.x} * CAMERA_SENSITIVITY);
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

GetTimeMilliseconds :: () -> t_milliseconds : u32 {
    return SDL_GetTicks();
}

SwapBuffers :: () { // maybe this should be part of a larger "DrawEverything()" function?? we're just giving it a shot
    SDL_GL_SwapWindow(window);
}

ApplyMovement :: (translation : *Vector3, delta : Vector3, movementKeyPressed : *bool) {
    (translation.*) += delta;
    (movementKeyPressed.*) = true;
}

ApplyZoom :: (zoom : *float, delta : float, zoomKeyPressed : *bool) {
    (zoom.*) += delta;
    (zoomKeyPressed.*) = true;
}

GetWindowWidth  :: () -> windowWidth : u32  { return windowWidth; }
GetWindowHeight :: () -> windowHeight : u32 { return windowHeight; }

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
