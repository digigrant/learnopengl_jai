#import "Basic";
#import "GL";
#import "Math";
#import "Extra_Stuff";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";

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

CUBE_POSITIONS : [10] Vector3 : .[
    .{  0.0,  0.0,  0.0  },
    .{  2.0,  5.0, -15.0 },
    .{ -1.5, -2.2, -2.5  },
    .{ -3.8, -2.0, -12.3 },
    .{  2.4, -0.4, -3.5  },
    .{ -1.7,  3.0, -7.5  },
    .{  1.3, -2.0, -2.5  },
    .{  1.5,  2.0, -2.5  },
    .{  1.5,  0.2, -1.5  },
    .{ -1.3,  1.0, -1.5  }
];

POINT_LIGHT_POSITIONS : [4] Vector3 : .[
    .{  0.7,  0.2,  2.0  },
	.{  2.3, -3.3, -4.0  },
	.{ -4.0,  2.0, -12.0 },
	.{  0.0,  0.0, -3.0  }
];

POINT_LIGHT_COLORS : [4] Vector3 : .[
    .{ 1.0, 0.0, 0.0 },
    .{ 0.0, 1.0, 0.0 },
    .{ 0.0, 0.0, 1.0 },
    .{ 1.0, 0.0, 1.0 }
];

main :: () {
    InitAllSystems();

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);

    camera := CreateCamera(.{ 0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

    my_event_queue : EventQueue;
    ListenForEventType(*my_event_queue, .CAMERA_MOVE);
    NotifyEvent(.CAMERA_MOVE);
    NotifyEvent(.CAMERA_MOVE);
    print("my_event_queue: %\n", my_event_queue);

    cube_mesh := CreateMesh("cube", .{ CUBE_VERTICES, CUBE_VERTEX_ATTRIBUTES });
    cube_mesh.material = BuildFromMaterialibrary("container");
    {
        using cube_mesh.material;
        diffuse_texture = BuildFromTextureLibrary("textures/container2.png", .DIFFUSE);
        specular_texture = BuildFromTextureLibrary("textures/container2_specular.png", .SPECULAR);
        shininess = 32.0;
    }
    defer FreeMesh(*cube_mesh);

    // technically light mesh and cube mesh can use the same VBO and different VAOs
    // can we think of an elegant way to communicate this to the Graphics module?
    // it would save us a buffer
    light_mesh := CreateMesh("light", .{ CUBE_VERTICES, CUBE_VERTEX_ATTRIBUTES});
    defer FreeMesh(*light_mesh);
    light_pos : Vector3 = .{1.2, 1.0, 2.0};
    light_base_color : Vector3 = .{ 1.0, 1.0, 1.0 };
    light_base_ambient : Vector3 = .{ 0.2, 0.2, 0.2 };
    light_base_diffuse : Vector3 = .{ 0.5, 0.5, 0.5 };
    light_base_specular : Vector3 = .{ 1.0, 1.0, 1.0 };

    cube_shader := CreateShader(CUBE_VERTEX_SHADER, CUBE_FRAGMENT_SHADER);
    light_shader := CreateShader(CUBE_VERTEX_SHADER, LIGHT_FRAGMENT_SHADER);

    directional_light := DirectionalLight.{
        name = "my_dir_light",
        direction = .{ -0.2, -1.0, -0.3 },
        ambient_color = .{0.2, 0.2, 0.0},
        diffuse_color = .{0.5, 0.5, 0.0},
        specular_color = .{1.0, 1.0, 0.0}
    };

    point_lights : [4] PointLight;
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

    spot_light := SpotLight.{
        name = "my_spot_light",
        position = .{0.0, 0.0, 0.0},
        direction = .{0.0, 0.0, -1.0},
        ambient_color = .{0.2, 0.2, 0.2},
        diffuse_color = .{0.5, 0.5, 0.5},
        specular_color = .{1.0, 1.0, 1.0},
        inner_cutoff = #run cos(DegToRad(12.5)),
        outer_cutoff = #run cos(DegToRad(17.5)),
        constant = 1.0,
        linear = 0.09,
        quadratic = 0.032
    };

    // these lighting uniforms dont change from frame to frame so we can set them here
    glUseProgram(cube_shader);
    {
        ShaderSetVec3(cube_shader, "directional_light.ambient", directional_light.ambient_color);
        ShaderSetVec3(cube_shader, "directional_light.diffuse", directional_light.diffuse_color);
        ShaderSetVec3(cube_shader, "directional_light.specular", directional_light.specular_color);

        ShaderSetVec3(cube_shader, "spot_light.position", spot_light.position);
        ShaderSetVec3(cube_shader, "spot_light.direction", spot_light.direction);
        ShaderSetVec3(cube_shader, "spot_light.ambient", spot_light.ambient_color);
        ShaderSetVec3(cube_shader, "spot_light.diffuse", spot_light.diffuse_color);
        ShaderSetVec3(cube_shader, "spot_light.specular", spot_light.specular_color);
        ShaderSetFloat(cube_shader, "spot_light.inner_cutoff", spot_light.inner_cutoff);
        ShaderSetFloat(cube_shader, "spot_light.outer_cutoff", spot_light.outer_cutoff);
        ShaderSetFloat(cube_shader, "spot_light.constant", spot_light.constant);
        ShaderSetFloat(cube_shader, "spot_light.linear", spot_light.linear);
        ShaderSetFloat(cube_shader, "spot_light.quadratic", spot_light.quadratic);
    }

    curr_time_seconds, prev_time_seconds, delta_time_seconds : float;
    exit := false;
    while !exit {
        // update time
        prev_time_seconds = curr_time_seconds;
        curr_time_seconds = GetTimeMilliseconds() / 1000.0;
        delta_time_seconds = curr_time_seconds - prev_time_seconds;

        ProcessInput(*exit, delta_time_seconds, camera);

        event : EventInfo;
        while PollEvents(*my_event_queue, *event) {
            print("new event: %\n", event.type);
        }

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
            directional_light_view_dir : Vector3 = (view * make_vector4(directional_light.direction, 0.0)).xyz;
            ShaderSetVec3(cube_shader, "directional_light.direction", directional_light_view_dir);

            for p_light, i: point_lights {
                point_light_view_pos : Vector3 = (view * make_vector4(p_light.position, 1.0)).xyz;
                ShaderSetVec3(cube_shader, sprint("point_lights[%].position", i),   point_light_view_pos);
                ShaderSetVec3(cube_shader, sprint("point_lights[%].ambient", i),    p_light.ambient_color);
                ShaderSetVec3(cube_shader, sprint("point_lights[%].diffuse", i),    p_light.diffuse_color);
                ShaderSetVec3(cube_shader, sprint("point_lights[%].specular", i),   p_light.specular_color);
                ShaderSetFloat(cube_shader, sprint("point_lights[%].constant", i),  p_light.constant);
                ShaderSetFloat(cube_shader, sprint("point_lights[%].linear", i),    p_light.linear);
                ShaderSetFloat(cube_shader, sprint("point_lights[%].quadratic", i), p_light.quadratic);
            }

            // draw cubes
            cube_model : Matrix4;
            for cube_pos : CUBE_POSITIONS {
                cube_model = Matrix4_Identity;
                translate(*cube_model, cube_pos);
                RotateMatrix4(*cube_model, DegToRad(20.0 * it_index), .{1.0, 0.3, 0.5});
                ShaderSetMat4(cube_shader, "model", *cube_model);
                DrawMesh(cube_mesh, cube_shader);
            } 
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
