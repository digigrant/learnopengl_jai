#import "Basic";
#import "SDL";
#import "GL";

SCREEN_WIDTH    :: 800;
SCREEN_HEIGHT   :: 600;

main :: () {
    SDL_Init(SDL_INIT_VIDEO);

    // set GL attributes
    // documentation says this should be done before window creation
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3); // OpenGL 3.3

    // create window
    width, height : u32 = SCREEN_WIDTH, SCREEN_HEIGHT;
    window := SDL_CreateWindow("LearnOpenGL_Jai", SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED, xx width, xx height,
        SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE); // can add resizing, input focus, etc
    if window == null {
        print("Could not create window: %\n", to_string(SDL_GetError()));
        return;
    }

    // create context
    gl_context := SDL_GL_CreateContext(window);
    if !gl_context {
        print("Could not create OpenGL context: %\n", to_string(SDL_GetError()));
        return;
    }

    // initialize GLAD
    gl_load(*gl, SDL_GL_GetProcAddress);
    // we should check that it was initialized correctly.... but i dont know how

    // main loop
    exit := false;
    while !exit {

        // poll events
        event : SDL_Event;
        while SDL_PollEvent(*event) {
            if event.type == {
                case SDL_QUIT; exit = true;
                case SDL_KEYUP;
                    if event.key.keysym.sym == SDLK_ESCAPE exit = true;
                case SDL_WINDOWEVENT;
                    if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
                        width, height = xx event.window.data1, xx event.window.data2;
                        // should only need to call this when window is resized
                        glViewport(0, 0, width, height);
                    }
            }
        }

        // clear buffers
        glClear(GL_COLOR_BUFFER_BIT);

        // ...rendering happens here...

        // swap buffers
        SDL_GL_SwapWindow(window);
    }

    SDL_DestroyWindow(window);
    SDL_Quit();
}

