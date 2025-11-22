#import "Basic";
#import "GL"; // we only need this for any GL features we enable in main - just temporary
#import "Math";
#import "Extra_Stuff";
#import "Asset_Importer";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";

points : [20] float : .[
	-0.5,  0.5, 1.0, 0.0, 0.0, // top-left
	 0.5,  0.5, 0.0, 1.0, 0.0, // top-right
	 0.5, -0.5, 0.0, 0.0, 1.0, // bottom-right
	-0.5, -0.5, 1.0, 1.0, 0.0  // bottom-left
];

VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec2 aPos;
layout (location = 1) in vec3 aColor;

out VS_OUT {
    vec3 color;
} vs_out;

void main() {
    gl_Position = vec4(aPos.x, aPos.y, 0.0, 1.0);
    //gl_PointSize = 5;
    vs_out.color = aColor;
}
DONE

GEOMETRY_SHADER :: #string DONE
#version 330 core
layout (points) in;
layout (triangle_strip, max_vertices = 5) out;

in VS_OUT {
    vec3 color;
} gs_in[];  // always an array, even if just using points

out vec3 fColor;

void build_house(vec4 position) {
    fColor = gs_in[0].color;
    gl_Position = position + vec4(-0.2, -0.2, 0.0, 0.0);
    EmitVertex();
    gl_Position = position + vec4( 0.2, -0.2, 0.0, 0.0);
    EmitVertex();
    gl_Position = position + vec4(-0.2,  0.2, 0.0, 0.0);
    EmitVertex();
    gl_Position = position + vec4( 0.2,  0.2, 0.0, 0.0);
    EmitVertex();
    gl_Position = position + vec4( 0.0,  0.4, 0.0, 0.0);
    fColor = vec3(1.0, 1.0, 1.0);
    EmitVertex();
    EndPrimitive();
}

void main() {
    build_house(gl_in[0].gl_Position);  // gl_in - built-in input array
}
DONE

FRAGMENT_SHADER :: #string DONE
#version 330 core
in vec3 fColor;
out vec4 FragColor;

void main() {
    FragColor = vec4(fColor, 1.0);
}
DONE

main :: () {
    InitAllSystems();

    // enable gl systems
    // we just do this here because the tutorials have me change this a lot
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_PROGRAM_POINT_SIZE);

    // ...

    camera := CreateCamera(.{0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

    shader := CreateShader(VERTEX_SHADER, FRAGMENT_SHADER, GEOMETRY_SHADER);
    vao, _ := CreateVertexObjects(.{points, .[ .{2}, .{3} ]});

    // main loop
    exit := false;
    currTimeSeconds, prevTimeSeconds, deltaTimeSeconds : float;
    while !exit {
        prevTimeSeconds = currTimeSeconds;
        currTimeSeconds = GetTimeMilliseconds()/1000.0;
        deltaTimeSeconds = currTimeSeconds - prevTimeSeconds;

        ProcessInput(*exit, deltaTimeSeconds, camera);

        glClearColor(0.1, 0.1, 0.1, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // ...

        glUseProgram(shader);
        glBindVertexArray(vao);
        glDrawArrays(GL_POINTS, 0, 4);

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
