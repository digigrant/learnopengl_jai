#import "Basic";
#import "SDL";
#import "GL";

SCREEN_WIDTH    :: 800;
SCREEN_HEIGHT   :: 600;

vertices : [9] float : .[
    -0.5, -0.5,  0.0,
     0.5, -0.5,  0.0,
     0.0,  0.5,  0.0,
];

VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;

void main() {
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
DONE

FRAGMENT_SHADER :: #string DONE
#version 330 core
out vec4 FragColor;

void main() {
    FragColor = vec4(1.0, 0.5, 0.2, 1.0);
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

    VAO, VBO : u32;
    glGenVertexArrays(1, *VAO);
    glGenBuffers(1, *VBO);
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, 36, *vertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * size_of(float), cast(*void)0);
    glBindVertexArray(0);

    // make the shader
    vertexShader, fragmentShader, shader : u32;
    success : s32;
    infoLog : string;

    vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, *(to_c_string(VERTEX_SHADER)), null);
    glCompileShader(vertexShader);
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, *success);
    if !success {
        glGetShaderInfoLog(vertexShader, 512, null, to_c_string(infoLog));
        print("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n%\n", infoLog);
    }

    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, *(to_c_string(FRAGMENT_SHADER)), null);
    glCompileShader(fragmentShader);
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, *success);
    if !success {
        glGetShaderInfoLog(fragmentShader, 512, null, to_c_string(infoLog));
        print("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n%\n", infoLog);
    }

    shader = glCreateProgram();
    glAttachShader(shader, vertexShader);
    glAttachShader(shader, fragmentShader);
    glLinkProgram(shader);
    glGetProgramiv(shader, GL_LINK_STATUS, *success);
    if !success {
        glGetProgramInfoLog(shader, 512, null, to_c_string(infoLog));
        print("ERROR::SHADER::PROGRAM::LINKING_FAILED\n%\n", infoLog);
    }
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);



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
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        // swap buffers
        SDL_GL_SwapWindow(window);
    }

    SDL_DestroyWindow(window);
    SDL_Quit();
}

