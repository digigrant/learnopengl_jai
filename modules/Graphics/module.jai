#load "Camera.jai";
#load "Cubemap.jai";
#load "FrameBuffer.jai";
#load "Material.jai";
#load "Mesh.jai";
#load "Model.jai";
#load "Shader.jai";
#load "Texture.jai";
#load "TextureLibrary.jai";
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

Init :: () -> ok : bool {
    if SDL_InitSubSystem(SDL_INIT_VIDEO) {
        print("Couldn't initialize SDL_INIT_VIDEO: %\n", to_string(SDL_GetError()));
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

    InitTextureLibrary();
    InitFrameBuffer();

    return true;
}

Shutdown :: () {
    FreeEntireTextureLibrary();
    SDL_QuitSubSystem(SDL_INIT_VIDEO);
    SDL_DestroyWindow(window);
}

GetTimeMilliseconds :: () -> t_milliseconds : u32 {
    return SDL_GetTicks();
}

SwapBuffers :: () { // maybe this should be part of a larger "DrawEverything()" function?? we're just giving it a shot
    SDL_GL_SwapWindow(window);
}

GetWindowWidth  :: () -> windowWidth : u32  { return windowWidth; }
GetWindowHeight :: () -> windowHeight : u32 { return windowHeight; }
