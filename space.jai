#import "Basic";
#import "GL";
#import "Math";
#import "Extra_Stuff";
#import "Asset_Importer";
#import "Random";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";

USE_INSTANCE_ARRAY :: 1;

MODEL_VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
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

INSTANCED_MODEL_VERTEX_SHADER :: #string DONE
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 2) in vec2 aTexCoords;
layout (location = 3) in mat4 instanceMatrix;

layout (std140) uniform Matrices {
    mat4 projection;
    mat4 view;
};

out vec2 tex_coords;

void main() {
    gl_Position = projection * view * instanceMatrix * vec4(aPos, 1.0);
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
    camera := CreateCamera(.{0.0, 20.0, 50.0});
    defer FreeCamera(*camera);
    
    planet := CreateModel("models/planet/planet.obj");
    defer FreeModel(*planet);

    rock := CreateModel("models/rock/rock.obj");
    defer FreeModel(*rock);

    model_shader := CreateShader(MODEL_VERTEX_SHADER, MODEL_FRAGMENT_SHADER);
    instanced_model_shader := CreateShader(INSTANCED_MODEL_VERTEX_SHADER, MODEL_FRAGMENT_SHADER);

    // timekeeping - could be moved somewhere else to do it automatically
    // "UpdateTime" or something
    // a scene manager or engine will probably manage this in the future anyway
    currTimeSeconds, prevTimeSeconds, deltaTimeSeconds : float;

    NUM_ROCKS :: 5000;
    model_matrices : [NUM_ROCKS] Matrix4; // !!!

    RADIUS :: 40.0;
    OFFSET :: 2.5;

    GetRandomDisplacement :: () -> float {
        return cast (float) ((random_get() % cast(u64) (2 * OFFSET * 100)) / 100) - OFFSET;
    }

    // build instance array
    for * model : model_matrices {
        (model.*) = Matrix4_Identity;
        angle := it_index.(float) / NUM_ROCKS * 360.0;
        x := sin(angle) * RADIUS + GetRandomDisplacement();
        y := GetRandomDisplacement() * 0.4;
        z := cos(angle) * RADIUS + GetRandomDisplacement();
        translate(model, Vector3.{x, y, z});

        scale_amount := ((random_get() % 20) / 100.0) + 0.05;
        scale(model, scale_amount);

        rotation_angle := cast(float) (random_get() % 360);
        RotateMatrix4(model, rotation_angle, .{0.4, 0.6, 0.8});

        #if USE_INSTANCE_ARRAY transpose(model);
    }

    // allocate buffer on the GPU
    instance_array : u32;
    glGenBuffers(1, *instance_array);
    glBindBuffer(GL_ARRAY_BUFFER, instance_array);
    glBufferData(GL_ARRAY_BUFFER, NUM_ROCKS * size_of(Matrix4), model_matrices.data, GL_STATIC_DRAW);

    // modify rock mesh VAO to include new instance array
    for rock_mesh : rock.meshes {
        glBindVertexArray(rock_mesh.VAO);
        glBindBuffer(GL_ARRAY_BUFFER, instance_array);
        glEnableVertexAttribArray(3);
        glVertexAttribPointer(3, 4, GL_FLOAT, GL_FALSE, size_of(Matrix4), cast(*void) 0);
        glEnableVertexAttribArray(4);
        glVertexAttribPointer(4, 4, GL_FLOAT, GL_FALSE, size_of(Matrix4), cast(*void) (1 * size_of(Vector4)));
        glEnableVertexAttribArray(5);
        glVertexAttribPointer(5, 4, GL_FLOAT, GL_FALSE, size_of(Matrix4), cast(*void) (2 * size_of(Vector4)));
        glEnableVertexAttribArray(6);
        glVertexAttribPointer(6, 4, GL_FLOAT, GL_FALSE, size_of(Matrix4), cast(*void) (3 * size_of(Vector4)));

        glVertexAttribDivisor(3, 1);
        glVertexAttribDivisor(4, 1);
        glVertexAttribDivisor(5, 1);
        glVertexAttribDivisor(6, 1);

        glBindVertexArray(0);
    }
    
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
            planet_model := Matrix4_Identity;
            translate(*planet_model, .{ 0.0, -3.0, 0.0 });
            scale(*planet_model, 4.0);
            ShaderSetMat4(model_shader, "model", *planet_model);
            DrawModel(planet, model_shader);
        }

        #if USE_INSTANCE_ARRAY {
            glUseProgram(instanced_model_shader);
            {
                for rock_mesh : rock.meshes {
                    glBindVertexArray(rock_mesh.VAO);

                    glActiveTexture(GL_TEXTURE0);
                    if rock_mesh.material glBindTexture(GL_TEXTURE_2D, rock_mesh.material.diffuse_texture.id);
                    ShaderSetInt(instanced_model_shader, "diffuse", 0);

                    glDrawArraysInstanced(GL_TRIANGLES, 0, rock_mesh.vertexData.floats.count.(u32), NUM_ROCKS);

                    glBindVertexArray(0);
                }
            }
        } else {  // Old Method - works fine!!
            glUseProgram(model_shader);
            {
                for 0..NUM_ROCKS-1 {
                    ShaderSetMat4(model_shader, "model", *(model_matrices[it]));
                    DrawModel(rock, model_shader);
                }
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
