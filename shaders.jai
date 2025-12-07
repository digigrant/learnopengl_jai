/*
    This file just contains the shader code.
    If changes are made, the program has to be recompiled.
    Is that okay? We probably wouldnt prefer it, although
    I dont feel like coming up with a better solution right now.
*/

VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

layout (std140) uniform Matrices {
    mat4 projection;
    mat4 view;
};
uniform mat4 model;

out vec2 TexCoord;

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0f);
    TexCoord = aTexCoord;
}
DONE

FRAGMENT_SHADER :: #string DONE
#version 330 core
in vec2 TexCoord;

out vec4 FragColor;

uniform sampler2D diffuse;

void main() {
    vec4 texColor = texture(diffuse, TexCoord);
    if (texColor.a < 0.1) discard;
    FragColor = texColor;
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

layout (std140) uniform Matrices {
    mat4 projection;
    mat4 view;
};

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

EXPLODE_VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 2) in vec2 aTexCoord;

out VS_OUT {
    vec2 tex_coord;
} vs_out;

layout (std140) uniform Matrices {
    mat4 projection;
    mat4 view;
};

uniform mat4 model;

void main() {
    vs_out.tex_coord = aTexCoord;
    gl_Position = projection * view * model * vec4(aPos, 1.0);
}
DONE

EXPLODE_GEOMETRY_SHADER :: #string DONE
#version 330 core
layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

in VS_OUT {
    vec2 tex_coord;
} gs_in[];

out vec2 gs_tex_coord;

uniform float time;

vec4 ExplodeVertex(vec4 position, vec3 normal) {
    float magnitude = 2.0;
    vec3 direction = normal * ((sin(time) + 1.0) / 2.0) * magnitude;
    return position + vec4(direction.xy, 0.0, 0.0);
}

void main() {
    // get normal vector
    vec3 a = vec3(gl_in[0].gl_Position) - vec3(gl_in[1].gl_Position);
    vec3 b = vec3(gl_in[2].gl_Position) - vec3(gl_in[1].gl_Position);
    vec3 normal = normalize(cross(a, b));

    gl_Position = ExplodeVertex(gl_in[0].gl_Position, normal);
    gs_tex_coord = gs_in[0].tex_coord;
    EmitVertex();
    gl_Position = ExplodeVertex(gl_in[1].gl_Position, normal);
    gs_tex_coord = gs_in[1].tex_coord;
    EmitVertex();
    gl_Position = ExplodeVertex(gl_in[2].gl_Position, normal);
    gs_tex_coord = gs_in[2].tex_coord;
    EmitVertex();

    EndPrimitive();
}
DONE

EXPLODE_FRAGMENT_SHADER :: #string DONE
#version 330 core
out vec4 FragColor;

in vec2 gs_tex_coord;

uniform sampler2D diffuse;

void main() {
    FragColor = texture(diffuse, gs_tex_coord);
}
DONE

BACKPACK_VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aTexCoords;

layout (std140) uniform Matrices {
    mat4 projection;
    mat4 view;
};
uniform mat4 model;

out vec2 tex_coords;

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    tex_coords = aTexCoords;
    // currently we dont do anything with normals here
}
DONE

BACKPACK_FRAGMENT_SHADER :: #string DONE
#version 330 core
in vec2 tex_coords;
out vec4 fragment_color;
uniform sampler2D diffuse;

void main() {
    fragment_color = texture(diffuse, tex_coords);
}
DONE

VISUALIZE_NORMALS_VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

out VS_OUT {
    vec3 normal;
} vs_out;

uniform mat4 view;
uniform mat4 model;

void main() {
    gl_Position = view * model * vec4(aPos, 1.0);
    mat3 normal_matrix = mat3(transpose(inverse(view * model)));
    vs_out.normal = normalize(vec3(vec4(normal_matrix * aNormal, 0.0)));
    // we need to save the projection for the geometry shader since
    // we have to transform the new line we're drawing  
}
DONE

VISUALIZE_NORMALS_GEOMETRY_SHADER :: #string DONE
#version 330 core
layout (triangles) in;
layout (line_strip, max_vertices = 6) out;

in VS_OUT {
    vec3 normal;
} gs_in[];

const float MAGNITUDE = 0.4;

uniform mat4 projection;

void GenerateLine(int index) {
    gl_Position = projection * gl_in[index].gl_Position;
    EmitVertex();
    gl_Position = projection * (gl_in[index].gl_Position + vec4(gs_in[index].normal, 0.0) * MAGNITUDE);
    EmitVertex();
    EndPrimitive();
}

void main() {
    GenerateLine(0);
    GenerateLine(1);
    GenerateLine(2);
}
DONE

VISUALIZE_NORMALS_FRAGMENT_SHADER :: #string DONE
#version 330 core
out vec4 fragment_color;

void main() {
    fragment_color = vec4(1.0, 1.0, 0.0, 1.0);
}
DONE

/*
*
*   LIGHTING SHADERS
*
*
*/

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
    normal = vec3(view * model * vec4(aNormal, 0.0));
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

/*** Functions ***/
vec3 CalculateDirectionalLight(DirectionalLight d_light, vec3 normal, vec3 view_dir) {
    vec3 light_dir = normalize(-d_light.direction);
    float diffuse_amount = max(dot(normal, light_dir), 0.0);

    vec3 reflect_dir = reflect(-light_dir, normal);
    float specular_amount = pow(max(dot(view_dir, reflect_dir), 0.0), material.shininess);

    vec3 ambient = d_light.ambient * vec3(texture(material.diffuse_map, tex_coords));
    vec3 diffuse = d_light.diffuse * diffuse_amount * vec3(texture(material.diffuse_map, tex_coords));
    vec3 specular = d_light.specular * specular_amount * vec3(texture(material.specular_map, tex_coords));
    return ambient + diffuse + specular;
}

vec3 CalculatePointLight(PointLight p_light, vec3 normal, vec3 frag_pos, vec3 view_dir) {
    vec3 light_dir = normalize(p_light.position - frag_pos);
    float diffuse_amount = max(dot(normal, light_dir), 0.0);

    vec3 reflect_dir = reflect(-light_dir, normal);
    float specular_amount = pow(max(dot(view_dir, reflect_dir), 0.0), material.shininess);

    vec3 ambient = p_light.ambient * vec3(texture(material.diffuse_map, tex_coords));
    vec3 diffuse = p_light.diffuse * diffuse_amount * vec3(texture(material.diffuse_map, tex_coords));
    vec3 specular = p_light.specular * specular_amount * vec3(texture(material.specular_map, tex_coords));

    float distance = length(p_light.position - frag_pos);
    float attenuation = 1.0 / (p_light.constant + (p_light.linear * distance) + 
        (p_light.quadratic * distance * distance));

    return (ambient + diffuse + specular) * attenuation;
}

// double check this. we /tired/!
vec3 CalculateSpotLight(SpotLight s_light, vec3 normal, vec3 frag_pos, vec3 view_dir) {
    vec3 light_dir = normalize(s_light.position - frag_pos);
    
    float theta = dot(light_dir, normalize(-s_light.direction)); // gives us cosine of angle
    vec3 result = s_light.ambient * vec3(texture(material.diffuse_map, tex_coords)); // ambient only

    // if spot light is pointing at the fragment, within theta,
    // add diffuse and specular lighting
    if (theta > s_light.outer_cutoff) {
        float diffuse_amount = max(dot(normal, light_dir), 0.0);

        vec3 reflect_dir = reflect(-light_dir, normal);
        float specular_amount = pow(max(dot(view_dir, reflect_dir), 0.0), material.shininess);
        
        vec3 diffuse = s_light.diffuse * diffuse_amount * vec3(texture(material.diffuse_map, tex_coords));
        vec3 specular = s_light.specular * specular_amount * vec3(texture(material.specular_map, tex_coords));

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
    // vec3 result = CalculateDirectionalLight(directional_light, n_normal, view_dir);
    /*
    for (int i = 0; i < NUMBER_POINT_LIGHTS; i++) {
        result += CalculatePointLight(point_lights[i], n_normal, frag_view_pos, view_dir);
    }
    */
    vec3 result = CalculateSpotLight(spot_light, n_normal, frag_view_pos, view_dir);
    fragment_color = vec4(result, 1.0);
}
DONE

LIGHT_FRAGMENT_SHADER :: #string DONE
#version 330 core
out vec4 fragment_color;
uniform vec3 color;

void main() {
    fragment_color = vec4(color, 1.0);
}
DONE
