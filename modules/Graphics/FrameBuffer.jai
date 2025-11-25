#scope_file

// globals
frame_buffer    : GLuint;
color_buffer    : GLuint;
screen_vao      : GLuint;
screen_shader   : GLuint;

// screen vertex data
SCREEN_VERTICES : [24] float : .[
    -1.0, -1.0, 0.0, 0.0,
     1.0,  1.0, 1.0, 1.0,
    -1.0,  1.0, 0.0, 1.0,

    -1.0, -1.0, 0.0, 0.0,
     1.0, -1.0, 1.0, 0.0,
     1.0,  1.0, 1.0, 1.0,
];
SCREEN_VERTEX_ATTRIBUTES : [2] VertexAttribute : .[
    .{2},
    .{2}
];

// screen shaders
SCREEN_VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 aTexCoords;

out vec2 TexCoords;

void main() {
    gl_Position = vec4(aPos.x, aPos.y, 0.0, 1.0);
    TexCoords = aTexCoords;
}
DONE

SCREEN_FRAGMENT_SHADER :: #string DONE
#version 330 core
out vec4 FragColor;

in vec2 TexCoords;
uniform sampler2D screenTexture;

void main() {
    FragColor = texture(screenTexture, TexCoords);
}
DONE

#scope_module

// @TODO: we probably need to re-initialize this every time we change the window size
/*
    setting up frame buffer
    what does a user need to know about the frame buffer?
    1. on system startup, create a frame buffer
    2. at start of drawing, render scene to the frame buffer
    3. at end of drawing, render frame buffer to screen
    user doesnt really need to know anything about screen VAO and screen shader
    except to be able to say what they want them to be, i.e. post processing.
    user should not care about setting up frame buffer an screen shader, it would be
    very simple and convenient for the graphics library to just automatically do that
*/

InitFrameBuffer :: () {
    glGenFramebuffers(1, *frame_buffer);
    glGenTextures(1, *color_buffer);

    RBO : GLuint;
    glGenRenderbuffers(1, *RBO);

    // bind frame buffer
    glBindFramebuffer(GL_FRAMEBUFFER, frame_buffer);
    // setup texture attachment
    glBindTexture(GL_TEXTURE_2D, color_buffer);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, windowWidth, windowHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    // setup render buffer attachment
    glBindRenderbuffer(GL_RENDERBUFFER, RBO);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, windowWidth, windowHeight);

    // set attachments
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, color_buffer, 0);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, RBO);
    if glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE {
        print("ERROR::FRAMEBUFFER:: Framebuffer is not complete!");
    }

    // unbind everything
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);

    // create screen vao and shader
    screen_vao, _ = CreateVertexObjects(.{SCREEN_VERTICES, SCREEN_VERTEX_ATTRIBUTES});
    screen_shader = CreateShader(SCREEN_VERTEX_SHADER, SCREEN_FRAGMENT_SHADER);
}

#scope_export

// set up first render pass to the frame buffer
SetupRenderSceneToFrameBuffer :: () {
    glBindFramebuffer(GL_FRAMEBUFFER, frame_buffer);
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
}

// set up and draw second render pass to screen
RenderFrameBufferToScreen :: () {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glDisable(GL_DEPTH_TEST);

    glUseProgram(screen_shader);
    ShaderSetInt(screen_shader, "screenTexture", 0);
    glBindTexture(GL_TEXTURE_2D, color_buffer);

    glBindVertexArray(screen_vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);

    SwapBuffers();
}
