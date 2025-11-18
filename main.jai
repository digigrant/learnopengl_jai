#import "Basic";
#import "GL"; // we only need this for any GL features we enable in main - just temporary
#import "Math";
#import "Extra_Stuff";
#import "Asset_Importer";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";

cubeVertices : [180] float : .[
    // positions          // texture Coords
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

grassVertices : [30] float : .[
    // positions          // texture Coords (note we set these higher than 1 (together with GL_REPEAT as texture wrapping mode). this will cause the floor texture to repeat)
    -0.5, -0.5,  0.0,    0.0, 0.0,
     0.5,  0.5,  0.0,    1.0, 1.0,
    -0.5,  0.5,  0.0,    0.0, 1.0,

    -0.5, -0.5,  0.0,    0.0, 0.0,
     0.5, -0.5,  0.0,    1.0, 0.0,
     0.5,  0.5,  0.0,    1.0, 1.0								
];

planeVertices : [30] float : .[
    // positions          // texture Coords (note we set these higher than 1 (together with GL_REPEAT as texture wrapping mode). this will cause the floor texture to repeat)
     5.0, -0.5,  5.0,  2.0, 0.0,
    -5.0, -0.5,  5.0,  0.0, 0.0,
    -5.0, -0.5, -5.0,  0.0, 2.0,

     5.0, -0.5,  5.0,  2.0, 0.0,
    -5.0, -0.5, -5.0,  0.0, 2.0,
     5.0, -0.5, -5.0,  2.0, 2.0								
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

    vec4 texColor = texture(diffuse, TexCoord);
    if (texColor.a < 0.1) discard;
    FragColor = texColor;
}
DONE

main :: () {
    InitAllSystems();

    // enable gl systems
    // we just do this here because the tutorials have me change this a lot
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    shader := CreateShader(VERTEX_SHADER, FRAGMENT_SHADER);
    // shader isnt actually allocated or else we would have to free it

    texture := BuildFromTextureLibrary("textures/container.jpg", .DIFFUSE);
    // freed by texture library later

    camera := CreateCamera(.{0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

    //backpack := CreateModel("models/backpack/backpack.obj");
    //defer FreeModel(*backpack);

    cube_mesh := CreateMesh("cube", .{ cubeVertices, vertexAttributes },
        material = CreateMaterial("cube_mat", "textures/marble.jpg"));
    defer FreeMesh(*cube_mesh);

    grass_mesh := CreateMesh("grass", .{ grassVertices, vertexAttributes },
        material = CreateMaterial("grass_mat", "textures/blending_transparent_window.png"));
    defer FreeMesh(*grass_mesh);

    plane_mesh := CreateMesh("plane", .{ planeVertices, vertexAttributes },
        material = CreateMaterial("plane_mat", "textures/metal.png"));
    defer FreeMesh(*plane_mesh);

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
        glClearColor(0.1, 0.1, 0.1, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // ...rendering happens here...

        glUseProgram(shader);

        view := CameraGetViewMatrix(camera);
        ShaderSetMat4(shader, "view", *view);

        projection := make_projection_matrix(DegToRad(camera.fov), GetWindowWidth().(float)/GetWindowHeight(), 0.1, 100.0);
        ShaderSetMat4(shader, "projection", *projection);

        //DrawModel(backpack, shader);


        // cube 1
        model := Matrix4_Identity;
        translate(*model, .{ -1.0, 0.0, -1.0 });
        ShaderSetMat4(shader, "model", *model);
        DrawMesh(cube_mesh, shader);

        model = Matrix4_Identity;
        translate(*model, .{ 2.0, 0.0, 0.0 });
        ShaderSetMat4(shader, "model", *model);
        DrawMesh(cube_mesh, shader);

        // floor
        model = Matrix4_Identity;
        ShaderSetMat4(shader, "model", *model);
        DrawMesh(plane_mesh, shader);

        grass_positions : [5] Vector3 : .[
            .{ -1.5,  0.0, -0.48 },
            .{  1.5,  0.0,  0.51 },
            .{  0.0,  0.0,  0.70 },
            .{ -0.3,  0.0, -2.30 },
            .{  0.5,  0.0, -0.60 }
        ];

        for grass_positions {
            model = Matrix4_Identity;
            translate(*model, it);
            ShaderSetMat4(shader, "model", *model);
            DrawMesh(grass_mesh, shader);
        }

        SwapBuffers();
    }
    
    ShutdownAllSystems();
}

InitAllSystems :: () -> ok : bool {
    if !Graphics.Init() || !Input.Init() {
        print("Something bad happened. Let's hit the bricks\n");
        ShutdownAllSystems();
        return false;
    }

    return true;
}

ShutdownAllSystems :: () {
    Graphics.Shutdown();
    Input.Shutdown();
}
