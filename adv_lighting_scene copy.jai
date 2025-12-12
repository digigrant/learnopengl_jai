#import "Basic";
#import "GL";
#import "Math";
#import "Extra_Stuff";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";
#import "Events";

#load "shaders.jai";

CUBE_VERTICES : [288] float : .[
    // positions        // normals          // texture coords

    // back
    -0.5, -0.5, -0.5,   0.0,  0.0, -1.0,    0.0,  0.0,
     0.5,  0.5, -0.5,   0.0,  0.0, -1.0,    1.0,  1.0,
     0.5, -0.5, -0.5,   0.0,  0.0, -1.0,    1.0,  0.0,
     0.5,  0.5, -0.5,   0.0,  0.0, -1.0,    1.0,  1.0,
    -0.5, -0.5, -0.5,   0.0,  0.0, -1.0,    0.0,  0.0,
    -0.5,  0.5, -0.5,   0.0,  0.0, -1.0,    0.0,  1.0,

    // front
    -0.5, -0.5,  0.5,   0.0,  0.0,  1.0,    0.0,  0.0,
     0.5, -0.5,  0.5,   0.0,  0.0,  1.0,    1.0,  0.0,
     0.5,  0.5,  0.5,   0.0,  0.0,  1.0,    1.0,  1.0,
     0.5,  0.5,  0.5,   0.0,  0.0,  1.0,    1.0,  1.0,
    -0.5,  0.5,  0.5,   0.0,  0.0,  1.0,    0.0,  1.0,
    -0.5, -0.5,  0.5,   0.0,  0.0,  1.0,    0.0,  0.0,

    // left
    -0.5,  0.5,  0.5,  -1.0,  0.0,  0.0,    1.0,  0.0,
    -0.5,  0.5, -0.5,  -1.0,  0.0,  0.0,    1.0,  1.0,
    -0.5, -0.5, -0.5,  -1.0,  0.0,  0.0,    0.0,  1.0,
    -0.5, -0.5, -0.5,  -1.0,  0.0,  0.0,    0.0,  1.0,
    -0.5, -0.5,  0.5,  -1.0,  0.0,  0.0,    0.0,  0.0,
    -0.5,  0.5,  0.5,  -1.0,  0.0,  0.0,    1.0,  0.0,

    // right
     0.5,  0.5,  0.5,   1.0,  0.0,  0.0,    1.0,  0.0,
     0.5, -0.5, -0.5,   1.0,  0.0,  0.0,    0.0,  1.0,
     0.5,  0.5, -0.5,   1.0,  0.0,  0.0,    1.0,  1.0,
     0.5, -0.5, -0.5,   1.0,  0.0,  0.0,    0.0,  1.0,
     0.5,  0.5,  0.5,   1.0,  0.0,  0.0,    1.0,  0.0,
     0.5, -0.5,  0.5,   1.0,  0.0,  0.0,    0.0,  0.0,

    // bottom
    -0.5, -0.5, -0.5,   0.0, -1.0,  0.0,    0.0,  1.0,
     0.5, -0.5, -0.5,   0.0, -1.0,  0.0,    1.0,  1.0,
     0.5, -0.5,  0.5,   0.0, -1.0,  0.0,    1.0,  0.0,
     0.5, -0.5,  0.5,   0.0, -1.0,  0.0,    1.0,  0.0,
    -0.5, -0.5,  0.5,   0.0, -1.0,  0.0,    0.0,  0.0,
    -0.5, -0.5, -0.5,   0.0, -1.0,  0.0,    0.0,  1.0,

    // top
    -0.5,  0.5, -0.5,   0.0,  1.0,  0.0,    0.0,  1.0,
     0.5,  0.5,  0.5,   0.0,  1.0,  0.0,    1.0,  0.0,
     0.5,  0.5, -0.5,   0.0,  1.0,  0.0,    1.0,  1.0,
     0.5,  0.5,  0.5,   0.0,  1.0,  0.0,    1.0,  0.0,
    -0.5,  0.5, -0.5,   0.0,  1.0,  0.0,    0.0,  1.0,
    -0.5,  0.5,  0.5,   0.0,  1.0,  0.0,    0.0,  0.0
];

CUBE_VERTEX_ATTRIBUTES : [3] VertexAttribute : .[.{3}, .{3}, .{2} ];

CUBE_POSITIONS : [3] Vector3 : .[
    .{  0.0, 1.5, 0.0 },
    .{  2.0, 0.0, 1.0 },
    .{ -1.0, 0.0, 2.0 }
];

PLANE_VERTICES : [48] float : .[
    // positions            // normals          // texcoords
     25.0, -0.5,  25.0,     0.0, 1.0, 0.0,      25.0, 0.0,
    -25.0, -0.5, -25.0,     0.0, 1.0, 0.0,      0.0, 25.0,
    -25.0, -0.5,  25.0,     0.0, 1.0, 0.0,      0.0, 0.0,

     25.0, -0.5,  25.0,     0.0, 1.0, 0.0,      25.0, 0.0,
     25.0, -0.5, -25.0,     0.0, 1.0, 0.0,      25.0, 25.0,
    -25.0, -0.5, -25.0,     0.0, 1.0, 0.0,      0.0, 25.0
];

PLANE_VERTEX_ATTRIBUTES : [3] VertexAttribute : .[.{3}, .{3}, .{2} ];

POINT_LIGHT_POSITIONS : [4] Vector3 : .[
    .{ -3.0,  0.0,  0.0  },
    .{ -1.0,  0.0,  0.0  },
    .{  1.0,  0.0,  0.0  },
    .{  3.0,  0.0,  0.0  }
];

POINT_LIGHT_COLORS : [4] Vector3 : .[
    .{ 0.25, 0.25, 0.25 },
    .{ 0.50, 0.50, 0.50 },
    .{ 0.75, 0.75, 0.75 },
    .{ 1.00, 1.00, 1.00 }
];

blinn := true;
blinn_changed := false;

ToggleBlinn :: () {
    blinn = !blinn;
    blinn_changed = true;
}

SHADOW_WIDTH    :: 1024;
SHADOW_HEIGHT   :: 1024;

LIGHT_POS : Vector3 : .{-2.0, 4.0, -1.0};

DEPTH_QUAD_VERTICES : [30] float : .[
    -1.0, -1.0, 0.0,    0.0, 0.0,
     1.0, -1.0, 0.0,    1.0, 0.0,
    -1.0,  1.0, 0.0,    0.0, 1.0,
    
     1.0, -1.0, 0.0,    1.0, 0.0,
     1.0,  1.0, 0.0,    1.0, 1.0,
    -1.0,  1.0, 0.0,    0.0, 1.0,
];

DEPTH_QUAD_VERTEX_ATTRIBUTES : [2] VertexAttribute : .[ .{3}, .{2} ];

main :: () {
    InitAllSystems();

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    // glEnable(GL_FRAMEBUFFER_SRGB);   // ez gamma correction
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    blinn_event_queue : EventQueue;
    ListenForEventType(*blinn_event_queue, .INPUT_KEYBOARD_Z_PRESSED);

    camera := CreateCamera(.{ 0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

    plane_mesh := CreateMesh("plane", .{ PLANE_VERTICES, PLANE_VERTEX_ATTRIBUTES });
    plane_mesh.material = BuildFromMaterialLibrary("wood_floor");
    {
        using plane_mesh.material;
        diffuse_texture = BuildFromTextureLibrary("textures/wood.png", .DIFFUSE);
        specular_texture = BuildFromTextureLibrary("textures/white_pixel.jpg", .SPECULAR);
        shininess = 32.0;
    }
    defer FreeMesh(*plane_mesh);

    // technically light mesh and cube mesh can use the same VBO and different VAOs
    // can we think of an elegant way to communicate this to the Graphics module?
    // it would save us a buffer
    cube_mesh := CreateMesh("cube", .{ CUBE_VERTICES, CUBE_VERTEX_ATTRIBUTES });
    cube_mesh.material = BuildFromMaterialLibrary("cube_mat");
    {
        using cube_mesh.material;
        diffuse_texture = BuildFromTextureLibrary("textures/marble.jpg", .DIFFUSE);
        shininess = 32.0;
    }
    defer FreeMesh(*cube_mesh);
    light_mesh := CreateMesh("light", .{ CUBE_VERTICES, CUBE_VERTEX_ATTRIBUTES });
    defer FreeMesh(*light_mesh);

    cube_shader := CreateShader(CUBE_VERTEX_SHADER, BLINN_CUBE_FRAGMENT_SHADER);
    light_shader := CreateShader(CUBE_VERTEX_SHADER, LIGHT_FRAGMENT_SHADER);

    point_lights : [#run POINT_LIGHT_POSITIONS.count] PointLight;
    for * p_light, i : point_lights {
        using p_light;
        name = sprint("point_light_%", i);
        position = POINT_LIGHT_POSITIONS[i];
        ambient_color = POINT_LIGHT_COLORS[i] * .{ 0.2, 0.2, 0.2 };
        diffuse_color = POINT_LIGHT_COLORS[i] * .{ 0.5, 0.5, 0.5 };
        specular_color = POINT_LIGHT_COLORS[i] * .{ 1.0, 1.0, 1.0 };
        constant = 1.0;
        linear = 0.09;
        quadratic = 0.032;
    }

    // these lighting uniforms dont change from frame to frame so we can set them here
    glUseProgram(cube_shader);
    {
        plane_model := Matrix4_Identity;
        ShaderSetMat4(cube_shader, "model", *plane_model);
            
        ShaderSetBool(cube_shader, "blinn", blinn);

        ShaderSetInt(cube_shader, "num_point_lights", point_lights.count);
        for p_light, i : point_lights {
            ShaderSetVec3(cube_shader, sprint("point_lights[%].ambient", i),    p_light.ambient_color);
            ShaderSetVec3(cube_shader, sprint("point_lights[%].diffuse", i),    p_light.diffuse_color);
            ShaderSetVec3(cube_shader, sprint("point_lights[%].specular", i),   p_light.specular_color);
            ShaderSetFloat(cube_shader, sprint("point_lights[%].constant", i),  p_light.constant);
            ShaderSetFloat(cube_shader, sprint("point_lights[%].linear", i),    p_light.linear);
            ShaderSetFloat(cube_shader, sprint("point_lights[%].quadratic", i), p_light.quadratic);
        }
    }

    simple_depth_shader := CreateShader(SIMPLE_DEPTH_VERTEX_SHADER, SIMPLE_DEPTH_FRAGMENT_SHADER);

    depth_map_fbo : GLuint;
    depth_map_texture : GLuint;
    {
        glGenFramebuffers(1, *depth_map_fbo);

        glGenTextures(1, *depth_map_texture);
        glBindTexture(GL_TEXTURE_2D, depth_map_texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, SHADOW_WIDTH, SHADOW_HEIGHT, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null);
        // some other stuff we may not need
    
        glBindFramebuffer(GL_FRAMEBUFFER, depth_map_fbo);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depth_map_texture, 0);
        glDrawBuffer(GL_NONE);  // we have to do this to specify that we dont want to draw color to the frame buffer
        glReadBuffer(GL_NONE);  // same
        if glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE {
            print("ERROR::FRAMEBUFFER:: Depth framebuffer is not complete!");
        }
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    depth_quad_mesh := CreateMesh("depth_quad", .{DEPTH_QUAD_VERTICES, DEPTH_QUAD_VERTEX_ATTRIBUTES});

    depth_quad_shader := CreateShader(DEPTH_QUAD_VERTEX_SHADER, DEPTH_QUAD_FRAGMENT_SHADER);
    glUseProgram(depth_quad_shader);
    ShaderSetInt(depth_quad_shader, "depth_map", 0);

    curr_time_seconds, prev_time_seconds, delta_time_seconds : float;
    exit := false;
    while !exit {
        // update time
        prev_time_seconds = curr_time_seconds;
        curr_time_seconds = GetTimeMilliseconds() / 1000.0;
        delta_time_seconds = curr_time_seconds - prev_time_seconds;

        ProcessInput(*exit, delta_time_seconds, camera);

        {
            event : EventInfo;
            while PollEvents(*blinn_event_queue, *event) {
                if event.type == {
                    case .INPUT_KEYBOARD_Z_PRESSED; ToggleBlinn();
                    case; continue;
                }
            }
        }

        // light depth pass
        glUseProgram(simple_depth_shader);
        near_plane := 1.0;
        far_plane := 7.5;
        {
            light_projection := orthographic_projection_matrix(-10.0, 10.0, -10.0, 10.0, near_plane, far_plane);
            light_view := make_look_at_matrix(LIGHT_POS, make_vector3(0.0), .{0.0, 1.0, 0.0});
            // lets remind ourselves here that matrices need to be transposed before being put into the shader. hee hoo
            light_space := light_projection * light_view;
            
            ShaderSetMat4(simple_depth_shader, "light_space", *light_space);

            // render
            glViewport(0, 0, SHADOW_WIDTH, SHADOW_HEIGHT);
            glBindFramebuffer(GL_FRAMEBUFFER, depth_map_fbo);
            glClear(GL_DEPTH_BUFFER_BIT);

            model := Matrix4_Identity;
            ShaderSetMat4(simple_depth_shader, "model", *model);
            DrawMesh(plane_mesh, simple_depth_shader);

            for cube_pos : CUBE_POSITIONS {
                model = Matrix4_Identity;
                translate(*model, cube_pos);
                if it_index == 2 RotateMatrix4(*model, #run DegToRad(60.0), #run normalize(Vector3.{1.0, 0.0, 1.0}));
                scale(*model, ifx it_index != 2 then 0.5 else 0.25);
                ShaderSetMat4(simple_depth_shader, "model", *model);
                DrawMesh(cube_mesh, simple_depth_shader);
            }

            glBindFramebuffer(GL_FRAMEBUFFER, 0); // done rendering light depth pass
        }

        glViewport(0, 0, windowWidth, windowHeight);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glUseProgram(depth_quad_shader);
        ShaderSetFloat(depth_quad_shader, "near_plane", near_plane);
        ShaderSetFloat(depth_quad_shader, "far_plane", far_plane);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, depth_map_texture);
        DrawMesh(depth_quad_mesh, depth_quad_shader);

        SwapBuffers();

        /*
        CameraUpdate(camera, delta_time_seconds);

        SetupRenderSceneToFrameBuffer();

        view := CameraGetViewMatrix(camera);
        projection := make_projection_matrix(DegToRad(camera.fov), GetWindowWidth().(float)/GetWindowHeight(), 0.1, 100.0);
        // normally these get transposed when being fed into shader.
        // since we are not doing that anymore, we need to transpose them before
        // feeding them to uniform buffer. (Ugly!!)
        transposed_view := transpose(view);
        transposed_proj := transpose(projection);
        heehoo_matrices : [2] Matrix4 = .[transposed_proj, transposed_view];

        // @TODO: improve this by not using a string compare - just use an enum
        SetUniformBufferData("Matrices", size_of(Matrix4) * 2, heehoo_matrices.data);

        glUseProgram(cube_shader);
        {
            // set up lighting uniforms in shader program
            if blinn_changed ShaderSetInt(cube_shader, "blinn", xx blinn);

            for p_light, i: point_lights {
                point_light_view_pos : Vector3 = (view * make_vector4(p_light.position, 1.0)).xyz;
                ShaderSetVec3(cube_shader, sprint("point_lights[%].position", i), point_light_view_pos);
            }

            DrawMesh(plane_mesh, cube_shader);
        }

        glUseProgram(light_shader);
        {
            light_model : Matrix4;
            for p_light : point_lights {
                light_model = Matrix4_Identity;
                translate(*light_model, p_light.position);
                scale(*light_model, 0.2);
                ShaderSetMat4(light_shader, "model", *light_model);
                ShaderSetVec3(light_shader, "color", POINT_LIGHT_COLORS[it_index]);
                DrawMesh(light_mesh, light_shader);
            }
        }

        RenderFrameBufferToScreen();
        */

        reset_temporary_storage();
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
