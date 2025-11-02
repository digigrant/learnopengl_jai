#import "Basic";
#import "SDL";
#import "GL";
#import "Graphics";

SCREEN_WIDTH    :: 800;
SCREEN_HEIGHT   :: 600;

vertices : [32] float : .[
     0.5,  0.5, 0.0,   1.0, 0.0, 0.0,   1.0, 1.0,   // top right
     0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   1.0, 0.0,   // bottom right
    -0.5, -0.5, 0.0,   0.0, 0.0, 1.0,   0.0, 0.0,   // bottom left
    -0.5,  0.5, 0.0,   1.0, 1.0, 0.0,   0.0, 1.0    // top left 
];

indices : [6] u32 : .[
    0, 1, 3, // first triangle
    1, 2, 3  // second triangle
];

vertexAttributes : [3] VertexAttribute : .[
    .{3},   // position
    .{3},   // color
    .{2},   // texcoords
];

VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 myColor;
out vec2 TexCoord;

void main() {
    gl_Position = vec4(aPos, 1.0);
    myColor = aColor;
    TexCoord = aTexCoord;
}
DONE

FRAGMENT_SHADER :: #string DONE
#version 330 core
in vec3 myColor;
in vec2 TexCoord;

out vec4 FragColor;

uniform sampler2D diffuse;

void main() {
    FragColor = texture(diffuse, TexCoord);
}
DONE

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

    VAO, VBO := CreateVertexObjects(vertices, vertexAttributes);
    EBO := CreateEBO(indices, VAO);
    
    shader := CreateShader(VERTEX_SHADER, FRAGMENT_SHADER);

    texture := CreateTexture("textures/container.jpg", .TEXTURE_TYPE_DIFFUSE);

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
        glClearColor(0.2, 0.3, 0.3, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);

        // ...rendering happens here...
        glUseProgram(shader);
        glBindTexture(GL_TEXTURE_2D, texture.id);
        glBindVertexArray(VAO);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);

        // swap buffers
        SDL_GL_SwapWindow(window);
    }

    SDL_DestroyWindow(window);
    SDL_Quit();

    FreeTexture(*texture);
}

