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

PLANE_VERTICES : [48] float : .[
    // positions            // normals          // texcoords
     10.0, -0.5,  10.0,     0.0, 1.0, 0.0,      10.0, 0.0,
    -10.0, -0.5, -10.0,     0.0, 1.0, 0.0,      0.0, 10.0,
    -10.0, -0.5,  10.0,     0.0, 1.0, 0.0,      0.0, 0.0,

     10.0, -0.5,  10.0,     0.0, 1.0, 0.0,      10.0, 0.0,
     10.0, -0.5, -10.0,     0.0, 1.0, 0.0,      10.0, 10.0,
    -10.0, -0.5, -10.0,     0.0, 1.0, 0.0,      0.0, 10.0
];

PLANE_VERTEX_ATTRIBUTES : [3] VertexAttribute : .[.{3}, .{3}, .{2} ];

POINT_LIGHT_POSITIONS : [1] Vector3 : .[
    .{  0.0,  0.0,  0.0  }
];

POINT_LIGHT_COLORS : [1] Vector3 : .[
    .{ 1.0, 1.0, 1.0 }
];

blinn := true;
blinn_changed := false;
blinn_key_current, blinn_key_prev := false;

ToggleBlinn :: () {
    blinn = !blinn;
    blinn_changed = true;
}

main :: () {
    InitAllSystems();

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);

    blinn_event_queue : EventQueue;
    ListenForEventType(*blinn_event_queue, .INPUT_KEYBOARD_Z);

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
    light_mesh := CreateMesh("light", .{ CUBE_VERTICES, CUBE_VERTEX_ATTRIBUTES });
    defer FreeMesh(*light_mesh);

    cube_shader := CreateShader(CUBE_VERTEX_SHADER, BLINN_CUBE_FRAGMENT_SHADER);
    light_shader := CreateShader(CUBE_VERTEX_SHADER, LIGHT_FRAGMENT_SHADER);

    point_lights : [1] PointLight;
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

    curr_time_seconds, prev_time_seconds, delta_time_seconds : float;
    exit := false;
    while !exit {
        // update time
        prev_time_seconds = curr_time_seconds;
        curr_time_seconds = GetTimeMilliseconds() / 1000.0;
        delta_time_seconds = curr_time_seconds - prev_time_seconds;

        ProcessInput(*exit, delta_time_seconds, camera);

        {
            blinn_key_current = false;
            event : EventInfo;
            while PollEvents(*blinn_event_queue, *event) {
                if event.type == {
                    case .INPUT_KEYBOARD_Z; blinn_key_current = true;
                    case; continue;
                }
            }

            if blinn_key_current && !blinn_key_prev ToggleBlinn();
            blinn_key_prev = blinn_key_current;
        }

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
