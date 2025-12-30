#import "Basic";
#import "GL"; // we only need this for any GL features we enable in main - just temporary
#import "Math";
#import "Extra_Stuff";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";

#load "shaders.jai";
#load "vertex_data.jai";

main :: () {
    /* renderer initialization */
    InitAllSystems();

    /*
    // enable gl systems
    // we just do this here because the tutorials have me change this a lot
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_CULL_FACE);  // cull back faces
    glEnable(GL_MULTISAMPLE); // MSAA
    */

    /* set up scene */

    camera := CreateCamera(.{0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

    my_entity := Entity.{};
    my_parent := Entity.{};
    AddChildToParentEntity(*my_parent, *my_entity);

    cube_mesh := CreateMesh("cube", .{CUBE_VERTICES,VERTEX_ATTRIBUTES_POS_TEXCOORDS});
    cube_mesh.material = BuildFromMaterialLibrary("cube_mat");
    {
        using cube_mesh.material;
        diffuse_texture = BuildFromTextureLibrary("textures/marble.jpg", .DIFFUSE);
        specular_texture = BuildFromTextureLibrary("textures/white_pixel.jpg", .SPECULAR);
        shininess = 64.0;
    }

    shader := CreateShader(VERTEX_SHADER, FRAGMENT_SHADER);

    // main loop
    // timekeeping
    currTimeSeconds, prevTimeSeconds, deltaTimeSeconds : float;
    exit := false;
    while !exit {
        prevTimeSeconds = currTimeSeconds;
        currTimeSeconds = GetTimeMilliseconds()/1000.0;
        deltaTimeSeconds = currTimeSeconds - prevTimeSeconds;

        ProcessInput(*exit, deltaTimeSeconds, camera);

        new_rot := Vector3.{ 0.0, 0.0, sin(currTimeSeconds) * 20 };
        SetTransformRotation(*(my_parent.transform), new_rot);

        new_pos := Vector3.{ cos(currTimeSeconds) * 3, 0.0, sin(currTimeSeconds) * 3 };
        SetTransformPosition(*(my_entity.transform), new_pos);

        parent_pos := Vector3.{ 0.0, sin(currTimeSeconds * 0.4), 0.0 };
        SetTransformPosition(*(my_parent.transform), parent_pos);

        UpdateEntityAndChildren(*my_parent);

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

        glUseProgram(shader);
        {
            // cube
            ShaderSetMat4(shader, "model", *(my_entity.transform.model));
            DrawMesh(cube_mesh, shader);

            // cube
            ShaderSetMat4(shader, "model", *(my_parent.transform.model));
            DrawMesh(cube_mesh, shader);
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
