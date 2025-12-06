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
layout (location = 2) in vec2 aTexCoords;

layout (std140) uniform Matrices {
    mat4 projection;
    mat4 view;
};
uniform mat4 model;

out vec3 frag_view_pos;
out vec3 normal;
out vec2 tex_coords;

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    frag_view_pos = vec3(view * model * vec4(aPos, 1.0)); // change to view space
    normal = vec3(view * vec4(aNormal, 0.0));
    tex_coords = aTexCoords;
}
DONE

CUBE_FRAGMENT_SHADER :: #string DONE
#version 330 core
in vec3 frag_view_pos;
in vec3 normal;
in vec2 tex_coords;
out vec4 fragment_color;

/*** Structs ***/

struct Material {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;

    /*
        The streets say you should use a 1x1 white texture by default
        so you are always sampling a texture, and there are no branches.
        I guess we should do that
    */
    sampler2D diffuse_map;
    sampler2D specular_map;
};
uniform Material material;

struct DirectionalLight {
    vec3 direction;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};
uniform DirectionalLight directional_light;

struct PointLight {
    vec3 position;

    float constant;
    float linear;
    float quadratic;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};
#define NUMBER_POINT_LIGHTS 4
uniform PointLight point_lights[NUMBER_POINT_LIGHTS];

struct SpotLight {
    vec3 position;
    vec3 direction;
    float inner_cutoff;
    float outer_cutoff;

    float constant;
    float linear;
    float quadratic;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};
uniform SpotLight spot_light;

/*
struct Light {
    vec3 view_pos;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};
uniform Light light;
*/

/*** Functions ***/
vec3 CalculateDirectionalLight(DirectionalLight d_light, vec3 normal, vec3 view_dir) {
    vec3 light_dir = normalize(-d_light.direction);
    float diffuse_amount = max(dot(normal, light_dir), 0.0);

    vec3 reflect_dir = reflect(-light_dir, normal);
    float specular_amount = pow(max(dot(view_dir, reflect_dir), 0.0), material.shininess);

    vec3 ambient = d_light.ambient * vec3(texture(material.diffuse, tex_coords));
    vec3 diffuse = d_light.diffuse * diffuse_amount * vec3(texture(material.diffuse, tex_coords));
    vec3 specular = d_light.specular * specular_amount * vec3(texture(material.specular, tex_coords));
    return ambient + diffuse + specular;
}

vec3 CalculatePointLight(PointLight p_light, vec3 normal, vec3 frag_pos, vec3 view_dir) {
    vec3 light_dir = normalize(p_light.position - frag_pos);
    float diffuse_amount = max(dot(normal, light_dir), 0.0);

    vec3 reflect_dir = reflect(-light_dir, normal);
    float specular_amount = pow(max(dot(view_dir, reflect_dir), 0.0), material.shininess);

    vec3 ambient = p_light.ambient * vec3(texture(material.diffuse, tex_coords));
    vec3 diffuse = p_light.diffuse * diffuse_amount * vec3(texture(material.diffuse, tex_coords));
    vec3 specular = p_light.specular * specular_amount * vec3(texture(material.specular, tex_coords));

    float distance = length(p_light.position - frag_pos);
    float attenuation = 1.0 / (p_light.constant + (p_light.linear * distance) + 
        (p_light.quadratic * distance * distance));

    return (ambient + diffuse + specular) * attenuation;
}

// double check this. we /tired/!
vec3 CalculateSpotLight(SpotLight s_light, vec3 normal, vec3 frag_pos, vec3 view_dir) {
    vec3 light_dir = normalize(s_light.position - frag_pos);
    
    float theta = dot(light_dir, normalize(-s_light.direction)); // gives us cosine of angle
    vec3 result = s_light.ambient * vec3(texture(material.diffuse, tex_coords)); // ambient only

    // if spot light is pointing at the fragment, within theta,
    // add diffuse and specular lighting
    if (theta > s_light.outer_cutoff) {
        float diffuse_amount = max(dot(normal, light_dir), 0.0);

        vec3 reflect_dir = reflect(-light_dir, normal);
        float specular_amount = pow(max(dot(view_dir, reflect_dir), 0.0), material.shininess);
        
        vec3 diffuse = s_light.diffuse * diffuse_amount * vec3(texture(material.diffuse, tex_coords));
        vec3 specular = s_light.specular * specular_amount * vec3(texture(material.specular, tex_coords));

        float epsilon = s_light.inner_cutoff - s_light.outer_cutoff;
        float intensity = clamp((theta - s_light.outer_cutoff) / epsilon, 0.0, 1.0);

        result += (diffuse + specular) * intensity;
    }

    float distance = length(s_light.position - frag_pos);
    float attenuation = 1.0 / (s_light.constant + (s_light.linear * distance) + 
        (s_light.quadratic * distance * distance));

    return result * attenuation;
}

void main() {
    vec3 n_normal = normalize(normal);
    vec3 view_dir = normalize(-frag_view_pos);
    vec3 result = CalculateDirectionalLight(directional_light, n_normal, view_dir);
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
    cube_mesh.material = BuildFromMaterialibrary("gold");
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
            light_view_pos : Vector3 = (view * make_vector4(light_pos, 1.0)).xyz;
            ShaderSetVec3(cube_shader, "light.view_pos", light_view_pos);
            ShaderSetVec3(cube_shader, "light.ambient", light_base_color * light_base_ambient);
            ShaderSetVec3(cube_shader, "light.diffuse", light_base_color * light_base_diffuse);
            ShaderSetVec3(cube_shader, "light.specular", light_base_color * light_base_specular);
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
