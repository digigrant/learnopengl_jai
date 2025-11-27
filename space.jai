#import "Basic";
#import "GL";
#import "Math";
#import "Extra_Stuff";
#import "Asset_Importer";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";

MODEL_VERTEX_SHADER :: #string DONE
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
}
DONE

MODEL_FRAGMENT_SHADER :: #string DONE
#version 330 core
in vec2 tex_coords;
out vec4 fragment_color;
uniform sampler2D diffuse;

void main() {
    fragment_color = texture(diffuse, tex_coords);
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

    // camera should be easier to create - will we ever need more than 1 at a time??
    // could just be something we tell the graphics module to make for us
    camera := CreateCamera(.{0.0, 2.0, 10.0});
    defer FreeCamera(*camera);

    planet := CreateModel("models/planet/planet.obj");
    defer FreeModel(*planet);

    rock := CreateModel("models/rock/rock.obj");
    // have to add rock texture manually - ew
    for rock : rock.meshes rock.material.diffuse_texture = BuildFromTextureLibrary("models/rock/rock.png", .DIFFUSE);
    defer FreeModel(*rock);

    model_shader := CreateShader(MODEL_VERTEX_SHADER, MODEL_FRAGMENT_SHADER);

    // timekeeping - could be moved somewhere else to do it automatically
    // "UpdateTime" or something
    // a scene manager or engine will probably manage this in the future anyway
    currTimeSeconds, prevTimeSeconds, deltaTimeSeconds : float;
    model : Matrix4;
    exit := false;
    while !exit {
        prevTimeSeconds = currTimeSeconds;
        currTimeSeconds = GetTimeMilliseconds()/1000.0;
        deltaTimeSeconds = currTimeSeconds - prevTimeSeconds;

        ProcessInput(*exit, deltaTimeSeconds, camera);

        SetupRenderSceneToFrameBuffer();

        // will these be handled automatically in the future?
        // maybe by a scene system
        // certain objects still need custom view matrix e.g. skybox
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

        glUseProgram(model_shader);
        {
            model = Matrix4_Identity;
            translate(*model, .{ 0.0, 0.0, 0.0 });
            ShaderSetMat4(model_shader, "model", *model);
            DrawModel(planet, model_shader);

            model = Matrix4_Identity;
            translate(*model, .{ -10.0, 0.0, 0.0 });
            ShaderSetMat4(model_shader, "model", *model);
            DrawModel(rock, model_shader);
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
