#import "Basic";
#import "GL"; // we only need this for any GL features we enable in main - just temporary
#import "Graphics";
#import "Math";
#import "Extra_Math";
#import "Asset_Importer";

vertexFloats : [180] float : .[
    -0.5, -0.5, -0.5,  0.0, 0.0,
     0.5, -0.5, -0.5,  1.0, 0.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
    -0.5,  0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 0.0,

    -0.5, -0.5,  0.5,  0.0, 0.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 1.0,
     0.5,  0.5,  0.5,  1.0, 1.0,
    -0.5,  0.5,  0.5,  0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,

    -0.5,  0.5,  0.5,  1.0, 0.0,
    -0.5,  0.5, -0.5,  1.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,
    -0.5,  0.5,  0.5,  1.0, 0.0,

     0.5,  0.5,  0.5,  1.0, 0.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5,  0.5,  0.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 0.0,

    -0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5, -0.5,  1.0, 1.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,

    -0.5,  0.5, -0.5,  0.0, 1.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5,  0.5,  0.5,  1.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 0.0,
    -0.5,  0.5,  0.5,  0.0, 0.0,
    -0.5,  0.5, -0.5,  0.0, 1.0
];

indices : [6] u32 : .[
    0, 1, 3, // first triangle
    1, 2, 3  // second triangle
];

vertexAttributes : [2] VertexAttribute : .[
    .{3},   // position
    //.{3},   // color
    .{2},   // texcoords
];

VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
//layout (location = 1) in vec3 aColor;
layout (location = 1) in vec2 aTexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec3 myColor;
out vec2 TexCoord;

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0f);
    //gl_Position = vec4(aPos, 1.0);
    //myColor = aColor;
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
    if !Init() {
        print("Something bad happened. Let's hit the bricks\n");
        Shutdown();
        return;
    }

    // enable gl systems
    // we just do this here because the tutorials have me change this a lot
    glEnable(GL_DEPTH_TEST);

    shader := CreateShader(VERTEX_SHADER, FRAGMENT_SHADER);
    // shader isnt actually allocated or else we would have to free it

    texture := CreateTexture("textures/container.jpg", .DIFFUSE);
    defer FreeTexture(*texture);

    //mesh := CreateMesh(.{ vertexFloats, vertexAttributes }, textures = .[texture]);
    //defer FreeMesh(*mesh);

    camera := CreateCamera(.{0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

    ok, data := ImportDataFromObj("/home/grant/Documents/learnopengl_jai/models/backpack/backpack.obj");
    if !ok {
        print("We didnt do it kid\n");
        return;
    }

    meshes : [..] *Mesh;
    for object : data.objects {
        array_add(*meshes, CreateMesh(object.vertexData));
    }

    // timekeeping
    currTimeSeconds, prevTimeSeconds, deltaTimeSeconds : float;

    // main loop
    exit := false;
    while !exit {
        prevTimeSeconds = currTimeSeconds;
        currTimeSeconds = GetTimeMilliseconds()/1000.0;
        deltaTimeSeconds = currTimeSeconds - prevTimeSeconds;

        ProcessInput(*exit, deltaTimeSeconds, camera);

        // clear buffers
        glClearColor(0.2, 0.3, 0.3, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // ...rendering happens here...

        glUseProgram(shader);
        model := Matrix4_Identity;
        RotateMatrix4(*model, currTimeSeconds * #run DegToRad(50.0), .{0.5, 1.0, 0.0});
        ShaderSetMat4(shader, "model", *model);

        view := CameraGetViewMatrix(camera);
        ShaderSetMat4(shader, "view", *view);

        projection := make_projection_matrix(DegToRad(camera.fov), GetWindowWidth().(float)/GetWindowHeight(), 0.1, 100.0);
        ShaderSetMat4(shader, "projection", *projection);

        for mesh : meshes DrawMesh(mesh, shader);

        SwapBuffers();
    }

    for meshes {
        FreeMesh(*it);
    }
    
    Shutdown();
}
