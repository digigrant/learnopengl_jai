#load "Camera.jai";
#load "Shader.jai";
#load "Texture.jai";
#load "VertexObjects.jai";

#import "SDL";
#import "GL";

// global consts
DEFAULT_WINDOW_WIDTH    :: 800;
DEFAULT_WINDOW_HEIGHT   :: 600;

// global variables
window : *SDL_Window;
windowWidth : u32 = DEFAULT_WINDOW_WIDTH;
windowHeight : u32 = DEFAULT_WINDOW_HEIGHT;
keyboardState : *u8;

Init :: () -> ok : bool {
    SDL_Init(SDL_INIT_VIDEO);

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

    return true;
}

Shutdown :: () {
    SDL_DestroyWindow(window);
    SDL_Quit();
}

// TODO: there's a lot of crap in this file that maybe shouldn't be here
// "Game Engine Architecture" might shed some light on what should live here

ProcessInput :: (exit : *bool, deltaTimeSeconds : float, camera : *Camera) {
    // poll events
    event : SDL_Event;
    while SDL_PollEvent(*event) {
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
