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

main :: () {
    InitAllSystems();

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);

    camera := CreateCamera(.{ 0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

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

    DirectionalLight :: struct {
        direction : Vector3;    // this could also be a vec4 - w=0
        ambient_color : Vector3;
        diffuse_color : Vector3;
        specular_color : Vector3;
        name : string;
    };

    directional_light := DirectionalLight.{
        name = "my_dir_light",
        direction = .{ -0.2, -1.0, -0.3 },
        ambient_color = .{0.2, 0.2, 0.2},
        diffuse_color = .{0.5, 0.5, 0.5},
        specular_color = .{1.0, 1.0, 1.0}
    };

    glUseProgram(cube_shader);
    {
        ShaderSetVec3(cube_shader, "directional_light.ambient", directional_light.ambient_color);
        ShaderSetVec3(cube_shader, "directional_light.diffuse", directional_light.diffuse_color);
        ShaderSetVec3(cube_shader, "directional_light.specular", directional_light.specular_color);
    }

    curr_time_seconds, prev_time_seconds, delta_time_seconds : float;
    exit := false;
    while !exit {
        // update time
        prev_time_seconds = curr_time_seconds;
        curr_time_seconds = GetTimeMilliseconds() / 1000.0;
        delta_time_seconds = curr_time_seconds - prev_time_seconds;

        ProcessInput(*exit, delta_time_seconds, camera);

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
            directional_light_view_dir : Vector3 = (view * make_vector4(directional_light.direction, 0.0)).xyz;
            ShaderSetVec3(cube_shader, "directional_light.direction", directional_light_view_dir);
            cube_model : Matrix4;
            for cube_pos : CUBE_POSITIONS {
                cube_model = Matrix4_Identity;
                translate(*cube_model, cube_pos);
                RotateMatrix4(*cube_model, DegToRad(20.0 * it_index), .{1.0, 0.3, 0.5});
                ShaderSetMat4(cube_shader, "model", *cube_model);

                light_view_pos : Vector3 = (view * make_vector4(light_pos, 1.0)).xyz;
                /*
                ShaderSetVec3(cube_shader, "light.view_pos", light_view_pos);
                ShaderSetVec3(cube_shader, "light.ambient", light_base_color * light_base_ambient);
                ShaderSetVec3(cube_shader, "light.diffuse", light_base_color * light_base_diffuse);
                ShaderSetVec3(cube_shader, "light.specular", light_base_color * light_base_specular);
                */
                DrawMesh(cube_mesh, cube_shader);
            }
            
        }

        glUseProgram(light_shader);
        {
            light_model := Matrix4_Identity;
            translate(*light_model, light_pos);
            scale(*light_model, 0.2);
            ShaderSetMat4(light_shader, "model", *light_model);
            DrawMesh(light_mesh, light_shader);
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
