#import "Basic";
#import "GL"; // we only need this for any GL features we enable in main - just temporary
#import "Math";
#import "Extra_Stuff";
#import "Asset_Importer";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";

cubeVertices : [180] float : .[
    // Back face
    -0.5, -0.5, -0.5,  0.0, 0.0, // Bottom-left
     0.5,  0.5, -0.5,  1.0, 1.0, // top-right
     0.5, -0.5, -0.5,  1.0, 0.0, // bottom-right         
     0.5,  0.5, -0.5,  1.0, 1.0, // top-right
    -0.5, -0.5, -0.5,  0.0, 0.0, // bottom-left
    -0.5,  0.5, -0.5,  0.0, 1.0, // top-left
    // Front face
    -0.5, -0.5,  0.5,  0.0, 0.0, // bottom-left
     0.5, -0.5,  0.5,  1.0, 0.0, // bottom-right
     0.5,  0.5,  0.5,  1.0, 1.0, // top-right
     0.5,  0.5,  0.5,  1.0, 1.0, // top-right
    -0.5,  0.5,  0.5,  0.0, 1.0, // top-left
    -0.5, -0.5,  0.5,  0.0, 0.0, // bottom-left
    // Left face
    -0.5,  0.5,  0.5,  1.0, 0.0, // top-right
    -0.5,  0.5, -0.5,  1.0, 1.0, // top-left
    -0.5, -0.5, -0.5,  0.0, 1.0, // bottom-left
    -0.5, -0.5, -0.5,  0.0, 1.0, // bottom-left
    -0.5, -0.5,  0.5,  0.0, 0.0, // bottom-right
    -0.5,  0.5,  0.5,  1.0, 0.0, // top-right
    // Right face
     0.5,  0.5,  0.5,  1.0, 0.0, // top-left
     0.5, -0.5, -0.5,  0.0, 1.0, // bottom-right
     0.5,  0.5, -0.5,  1.0, 1.0, // top-right         
     0.5, -0.5, -0.5,  0.0, 1.0, // bottom-right
     0.5,  0.5,  0.5,  1.0, 0.0, // top-left
     0.5, -0.5,  0.5,  0.0, 0.0, // bottom-left     
    // Bottom face
    -0.5, -0.5, -0.5,  0.0, 1.0, // top-right
     0.5, -0.5, -0.5,  1.0, 1.0, // top-left
     0.5, -0.5,  0.5,  1.0, 0.0, // bottom-left
     0.5, -0.5,  0.5,  1.0, 0.0, // bottom-left
    -0.5, -0.5,  0.5,  0.0, 0.0, // bottom-right
    -0.5, -0.5, -0.5,  0.0, 1.0, // top-right
    // Top face
    -0.5,  0.5, -0.5,  0.0, 1.0, // top-left
     0.5,  0.5,  0.5,  1.0, 0.0, // bottom-right
     0.5,  0.5, -0.5,  1.0, 1.0, // top-right     
     0.5,  0.5,  0.5,  1.0, 0.0, // bottom-right
    -0.5,  0.5, -0.5,  0.0, 1.0, // top-left
    -0.5,  0.5,  0.5,  0.0, 0.0  // bottom-left        
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
    -5.0, -0.5, -5.0,  0.0, 2.0,
    -5.0, -0.5,  5.0,  0.0, 0.0,

     5.0, -0.5,  5.0,  2.0, 0.0,
     5.0, -0.5, -5.0,  2.0, 2.0,
    -5.0, -0.5, -5.0,  0.0, 2.0						
];

screenVertices : [24] float : .[
    -1.0, -1.0, 0.0, 0.0,
     1.0,  1.0, 1.0, 1.0,
    -1.0,  1.0, 0.0, 1.0,

    -1.0, -1.0, 0.0, 0.0,
     1.0, -1.0, 1.0, 0.0,
     1.0,  1.0, 1.0, 1.0,
];

skyboxVertices : [108] float : .[
    // positions          
    -1.0,  1.0, -1.0,
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
    -1.0,  1.0, -1.0,

    -1.0, -1.0,  1.0,
    -1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,
    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
    -1.0, -1.0,  1.0,

     1.0, -1.0, -1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0, -1.0,
     1.0, -1.0, -1.0,

    -1.0, -1.0,  1.0,
    -1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0, -1.0,  1.0,
    -1.0, -1.0,  1.0,

    -1.0,  1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,
    -1.0,  1.0, -1.0,

    -1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
     1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0
];

cuboidVertices : [216] float : .[
    // back
    -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
     0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
     0.5, -0.5, -0.5,  0.0,  0.0, -1.0, 
     0.5,  0.5, -0.5,  0.0,  0.0, -1.0, 
    -0.5, -0.5, -0.5,  0.0,  0.0, -1.0, 
    -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,

    // front
    -0.5, -0.5,  0.5,  0.0,  0.0,  1.0,
     0.5, -0.5,  0.5,  0.0,  0.0,  1.0,
     0.5,  0.5,  0.5,  0.0,  0.0,  1.0,
     0.5,  0.5,  0.5,  0.0,  0.0,  1.0,
    -0.5,  0.5,  0.5,  0.0,  0.0,  1.0,
    -0.5, -0.5,  0.5,  0.0,  0.0,  1.0,

    // left
    -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,
    -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,
    -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
    -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
    -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,
    -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,

    // right
     0.5,  0.5,  0.5,  1.0,  0.0,  0.0,
     0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
     0.5,  0.5, -0.5,  1.0,  0.0,  0.0,
     0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
     0.5,  0.5,  0.5,  1.0,  0.0,  0.0,
     0.5, -0.5,  0.5,  1.0,  0.0,  0.0,

    // bottom
    -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
     0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
     0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
     0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
    -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
    -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,

    // top
    -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
     0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
     0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
     0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
    -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
    -0.5,  0.5,  0.5,  0.0,  1.0,  0.0
];

vertexAttributes : [2] VertexAttribute : .[
    .{3},   // position
    //.{3},   // color
    .{2},   // texcoords
];

screenVertexAttributes : [2] VertexAttribute : .[
    .{2},
    .{2}
];

skyboxVertexAttributes : [1] VertexAttribute : .[
    .{3}
];

cuboidVertexAttributes : [2] VertexAttribute : .[
    .{3},
    .{3}
];

VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

layout (std140) uniform Matrices {
    mat4 projection;
    mat4 view;
};

uniform mat4 model;

out vec3 myColor;
out vec2 TexCoord;

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0f);
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

SKYBOX_VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;

out vec3 TexCoords;

uniform mat4 projection;
uniform mat4 view;

void main() {
    TexCoords = aPos;
    vec4 pos = projection * view * vec4(aPos, 1.0);
    gl_Position = pos.xyww;
}
DONE

SKYBOX_FRAGMENT_SHADER :: #string DONE
#version 330 core
out vec4 FragColor;

in vec3 TexCoords;

uniform samplerCube skybox;

void main() {
    FragColor = texture(skybox, TexCoords);
}
DONE

MIRROR_VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

out vec3 Normal;
out vec3 Position;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    Normal = mat3(transpose(inverse(model))) * aNormal; // normal matrix
    Position = vec3(model * vec4(aPos, 1.0));
    gl_Position = projection * view * vec4(Position, 1.0);
}
DONE

MIRROR_FRAGMENT_SHADER :: #string DONE
#version 330 core
out vec4 FragColor;

in vec3 Normal;
in vec3 Position;

uniform vec3 camera_pos;
uniform samplerCube skybox;

void main () {
    vec3 I = normalize(Position - camera_pos);
    vec3 R = reflect(I, normalize(Normal));
    FragColor = vec4(texture(skybox, R).rgb, 1.0);
}
DONE

GLASS_FRAGMENT_SHADER :: #string DONE
#version 330 core
out vec4 FragColor;

in vec3 Normal;
in vec3 Position;

uniform vec3 camera_pos;
uniform samplerCube skybox;

void main () {
    float ratio = 1.00 / 1.52;
    vec3 I = normalize(Position - camera_pos);
    vec3 R = refract(I, normalize(Normal), ratio);
    FragColor = vec4(texture(skybox, R).rgb, 1.0);
}
DONE

main :: () {
    InitAllSystems();

    // enable gl systems
    // we just do this here because the tutorials have me change this a lot
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_CULL_FACE);  // cull back faces

    print("hehe: %\n", GL_MAX_VERTEX_UNIFORM_COMPONENTS);

    shader := CreateShader(VERTEX_SHADER, FRAGMENT_SHADER);
    // shader isnt actually allocated or else we would have to free it
    glUniformBlockBinding(shader, glGetUniformBlockIndex(shader, "Matrices"), 0);

    texture := BuildFromTextureLibrary("textures/container.jpg", .DIFFUSE);
    // freed by texture library later

    camera := CreateCamera(.{0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

    backpack := CreateModel("models/backpack/backpack.obj");
    defer FreeModel(*backpack);

    cube_mesh := CreateMesh("cube", .{ cubeVertices, vertexAttributes },
        material = CreateMaterial("cube_mat", "textures/marble.jpg"));
    defer FreeMesh(*cube_mesh);
    
    cuboid_mesh := CreateMesh("cuboid", .{ cuboidVertices, cuboidVertexAttributes });
    defer FreeMesh(*cuboid_mesh);

    grass_mesh := CreateMesh("grass", .{ grassVertices, vertexAttributes },
        material = CreateMaterial("grass_mat", "textures/blending_transparent_window.png"));
    defer FreeMesh(*grass_mesh);

    plane_mesh := CreateMesh("plane", .{ planeVertices, vertexAttributes },
        material = CreateMaterial("plane_mat", "textures/metal.png"));
    defer FreeMesh(*plane_mesh);

    // timekeeping
    currTimeSeconds, prevTimeSeconds, deltaTimeSeconds : float;

    BlendableObject :: struct {
        distance_from_camera : float;
        index : int;
    };
    CompareBlendableObjects :: (a : *BlendableObject, b : *BlendableObject) -> int {
        diff := a.distance_from_camera - b.distance_from_camera;
        if abs(diff) < 0.0001 return 0;
        return ifx diff > 0 then 1 else -1;
    }

    blendable_objects : [..] BlendableObject;

    FBO : GLuint;
    glGenFramebuffers(1, *FBO);
    glBindFramebuffer(GL_FRAMEBUFFER, FBO);

    texture_color_buffer : GLuint;
    glGenTextures(1, *texture_color_buffer);
    glBindTexture(GL_TEXTURE_2D, texture_color_buffer);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, windowWidth, windowHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture_color_buffer, 0);

    RBO : GLuint;
    glGenRenderbuffers(1, *RBO);
    glBindRenderbuffer(GL_RENDERBUFFER, RBO);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, windowWidth, windowHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, RBO);

    if glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE {
        print("ERROR::FRAMEBUFFER:: Framebuffer is not complete!");
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);

    screen_vao, screen_vbo := CreateVertexObjects(.{screenVertices, screenVertexAttributes});
    screen_shader := CreateShader(SCREEN_VERTEX_SHADER, SCREEN_FRAGMENT_SHADER);

    skybox_faces : [6] string : .[
        "textures/skybox/right.jpg",
        "textures/skybox/left.jpg",
        "textures/skybox/top.jpg",
        "textures/skybox/bottom.jpg",
        "textures/skybox/front.jpg",
        "textures/skybox/back.jpg"
    ];
    skybox := CreateCubemap(*skybox_faces);
    skybox_vao, _ := CreateVertexObjects(.{skyboxVertices, skyboxVertexAttributes});
    skybox_shader := CreateShader(SKYBOX_VERTEX_SHADER, SKYBOX_FRAGMENT_SHADER);
    glUseProgram(skybox_shader);
    ShaderSetInt(skybox_shader, "skybox", 0);

    mirror_shader := CreateShader(MIRROR_VERTEX_SHADER, MIRROR_FRAGMENT_SHADER);
    glass_shader := CreateShader(MIRROR_VERTEX_SHADER, GLASS_FRAGMENT_SHADER);

    // create uniform buffer for matrices
    UBO_Matrices : GLuint;
    glGenBuffers(1, *UBO_Matrices);
    glBindBuffer(GL_UNIFORM_BUFFER, UBO_Matrices);
    glBufferData(GL_UNIFORM_BUFFER, 2 * size_of(Matrix4), null, GL_STATIC_DRAW);
    glBindBuffer(GL_UNIFORM_BUFFER, 0);
    glBindBufferRange(GL_UNIFORM_BUFFER, 0, UBO_Matrices, 0, 2 * size_of(Matrix4));

    // main loop
    exit := false;
    while !exit {
        prevTimeSeconds = currTimeSeconds;
        currTimeSeconds = GetTimeMilliseconds()/1000.0;
        deltaTimeSeconds = currTimeSeconds - prevTimeSeconds;

        ProcessInput(*exit, deltaTimeSeconds, camera);

        // set up first render pass
        glBindFramebuffer(GL_FRAMEBUFFER, FBO);
        glEnable(GL_DEPTH_TEST);
        glClearColor(0.1, 0.1, 0.1, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        view := CameraGetViewMatrix(camera);
        projection := make_projection_matrix(DegToRad(camera.fov), GetWindowWidth().(float)/GetWindowHeight(), 0.1, 100.0);
        // normally these get transposed when being fed into shader.
        // since we are not doing that anymore, we need to transpose them before
        // feeding them to uniform buffer. (Ugly!!)
        transposed_view := transpose(view);
        transposed_proj := transpose(projection);
        glBindBuffer(GL_UNIFORM_BUFFER, UBO_Matrices);
        glBufferSubData(GL_UNIFORM_BUFFER, 0, size_of(Matrix4), *transposed_proj);
        glBufferSubData(GL_UNIFORM_BUFFER, size_of(Matrix4), size_of(Matrix4), *transposed_view);
        glBindBuffer(GL_UNIFORM_BUFFER, 0);

        glUseProgram(shader);

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

        // mirror cuboid
        glUseProgram(mirror_shader);
        model = Matrix4_Identity;
        translate(*model, .{-10.0, 0.0, 10.0});
        ShaderSetMat4(mirror_shader, "model", *model);
        ShaderSetMat4(mirror_shader, "view", *view);
        ShaderSetMat4(mirror_shader, "projection", *projection);
        ShaderSetVec3(mirror_shader, "camera_pos", *(camera.position));
        DrawMesh(cuboid_mesh, mirror_shader);

        // glass backpack
        glUseProgram(glass_shader);
        model = Matrix4_Identity;
        translate(*model, .{10.0, 0.0, 10.0});
        ShaderSetMat4(glass_shader, "model", *model);
        ShaderSetMat4(glass_shader, "view", *view);
        ShaderSetMat4(glass_shader, "projection", *projection);
        ShaderSetVec3(glass_shader, "camera_pos", *(camera.position));
        DrawModel(backpack, glass_shader);

        // draw skybox last
        glDepthFunc(GL_LEQUAL);
        glUseProgram(skybox_shader);
        skybox_view := view;
        for 0..2 {
            using skybox_view;
            coef[it][3] = 0.0;
            coef[3][it] = 0.0;
        }

        ShaderSetMat4(skybox_shader, "view", *skybox_view);
        ShaderSetMat4(skybox_shader, "projection", *projection);
        glBindVertexArray(skybox_vao);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_CUBE_MAP, skybox.id); // DrawCubemap()
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArray(0);
        glDepthFunc(GL_LESS);

        // blendable objects
        grass_positions : [5] Vector3 : .[
            .{ -1.5,  0.0, -0.48 },
            .{  1.5,  0.0,  0.51 },
            .{  0.0,  0.0,  0.70 },
            .{ -0.3,  0.0, -2.30 },
            .{  0.5,  0.0, -0.60 }
        ];
        grass_yaws : [5] float = .[ 0.0, 0.0, 0.0, 0.0, 0.0 ];

        glUseProgram(shader);
        ShaderSetMat4(shader, "view", *view);
        ShaderSetMat4(shader, "projection", *projection);

        // sort
        array_reset(*blendable_objects);
        for pos : grass_positions array_add(*blendable_objects, .{ length(pos - camera.position), it_index });
        heap_view := Heapify(blendable_objects, CompareBlendableObjects);

        // draw
        current_blendable_object : *BlendableObject;
        for 0..blendable_objects.count -1 {
            current_blendable_object := HeapPop(*heap_view, CompareBlendableObjects);
            using,only(index) current_blendable_object;

            // prevent planes from being culled by back face culling:
            // if this plane is facing away from the camera, rotate it 180 degrees
            current_front : Vector3 = .{0.0, 0.0, cos(grass_yaws[index])};
            if dot_product(grass_positions[index] - camera.position, current_front) > 0.0 grass_yaws[index] = -(grass_yaws[index] - PI);

            model = Matrix4_Identity;
            translate(*model, grass_positions[index]);
            RotateMatrix4(*model, grass_yaws[index], .{0.0, 1.0, 0.0});
            ShaderSetMat4(shader, "model", *model);
            DrawMesh(grass_mesh, shader);
        }

        // set up second render pass
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glUseProgram(screen_shader);
        ShaderSetInt(screen_shader, "screenTexture", 0);
        glBindVertexArray(screen_vao);
        glDisable(GL_DEPTH_TEST);
        glBindTexture(GL_TEXTURE_2D, texture_color_buffer);
        glDrawArrays(GL_TRIANGLES, 0, 6);

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
