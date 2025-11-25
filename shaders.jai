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

EXPLODE_VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 2) in vec2 aTexCoord;

out VS_OUT {
    vec2 tex_coord;
} vs_out;

uniform mat4 projection;
uniform mat4 view;
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
    return position + vec4(direction, 0.0);
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

VISUALIZE_NORMALS_VERTEX_SHADER :: #string DONE
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

out VS_OUT {
    vec3 normal;
} vs_out;

uniform mat4 view;
uniform mat4 model;

void main() {
    // @TODO: brain is dead. continue tomorrow
}
DONE
