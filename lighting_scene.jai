#import "Basic";
#import "GL";
#import "Math";
#import "Extra_Stuff";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";

CUBE_VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

layout (std140) uniform Matrices {
    mat4 projection;
    mat4 view;
};
uniform mat4 model;

out vec3 fragment_pos;
out vec3 normal;

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    fragment_pos = vec3(model * vec4(aPos, 1.0)); // change to view space
    normal = aNormal;
}
DONE

CUBE_FRAGMENT_SHADER :: #string DONE
#version 330 core
in vec3 fragment_pos;
in vec3 normal;
out vec4 fragment_color;

uniform vec3 object_color;

uniform vec3 light_pos;
uniform vec3 view_pos;

uniform vec3 ambient_color;
uniform vec3 diffuse_color;
uniform vec3 specular_color;

float specular_strength = 0.5;

void main() {
    vec3 n_normal = normalize(normal);
    vec3 light_dir = normalize(light_pos - fragment_pos); // in world space atm
    float diff = max(dot(n_normal, light_dir), 0.0);
    vec3 diffuse = diff * diffuse_color;

    vec3 view_dir = normalize(view_pos - fragment_pos);
    vec3 reflect_dir = reflect(-light_dir, n_normal);
    float spec = pow(max(dot(view_dir, reflect_dir), 0.0), 32);
    vec3 specular = specular_strength * spec * specular_color;

    vec3 result = (ambient_color + diffuse + specular) * object_color;
    fragment_color = vec4(result, 1.0);
}
DONE

LIGHT_FRAGMENT_SHADER :: #string DONE
#version 330 core
out vec4 fragment_color;

void main() {
    fragment_color = vec4(1.0);
}
DONE

CUBE_VERTICES : [216] float : .[
    // back
    -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
     0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
     0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  
     0.5,  0.5, -0.5,  0.0,  0.0, -1.0, 
    -0.5, -0.5, -0.5,  0.0,  0.0, -1.0, 
    -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,

    // front
    -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
     0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
     0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
     0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
    -0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,

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

CUBE_VERTEX_ATTRIBUTES : [2] VertexAttribute : .[.{3}, .{3} ];

main :: () {
    InitAllSystems();

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);

    camera := CreateCamera(.{ 0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

    cube_mesh := CreateMesh("cube", .{ CUBE_VERTICES, CUBE_VERTEX_ATTRIBUTES });
    defer FreeMesh(*cube_mesh);

    // technically light mesh and cube mesh can use the same VBO and different VAOs
    // can we think of an elegant way to communicate this to the Graphics module?
    // it would save us a buffer
    light_mesh := CreateMesh("light", .{ CUBE_VERTICES, CUBE_VERTEX_ATTRIBUTES});
    defer FreeMesh(*light_mesh);
    light_pos : Vector3 = .{1.2, 1.0, 2.0};

    cube_shader := CreateShader(CUBE_VERTEX_SHADER, CUBE_FRAGMENT_SHADER);
    light_shader := CreateShader(CUBE_VERTEX_SHADER, LIGHT_FRAGMENT_SHADER);

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
            cube_model := Matrix4_Identity;
            ShaderSetMat4(cube_shader, "model", *cube_model);
            ShaderSetVec3(cube_shader, "object_color", .{ 1.0, 0.5, 0.31 });
            ShaderSetVec3(cube_shader, "light_pos", light_pos);
            ShaderSetVec3(cube_shader, "view_pos", camera.position);
            ShaderSetVec3(cube_shader, "ambient_color", .{ 0.1, 0.1, 0.1 });
            ShaderSetVec3(cube_shader, "diffuse_color", .{ 1.0, 1.0, 1.0 });
            ShaderSetVec3(cube_shader, "specular_color", .{ 1.0, 1.0, 1.0 });
            DrawMesh(cube_mesh, cube_shader);
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
