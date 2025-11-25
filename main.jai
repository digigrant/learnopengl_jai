#import "Basic";
#import "GL"; // we only need this for any GL features we enable in main - just temporary
#import "Math";
#import "Extra_Stuff";
#import "Asset_Importer";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";

#load "shaders.jai";
#load "vertex_data.jai";

main :: () {
    /* renderer initialization */
    InitAllSystems();

    // enable gl systems
    // we just do this here because the tutorials have me change this a lot
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_CULL_FACE);  // cull back faces

    /* set up scene */

    shader := CreateShader(VERTEX_SHADER, FRAGMENT_SHADER);
    // shader isnt actually allocated or else we would have to free it

    //texture := BuildFromTextureLibrary("textures/container.jpg", .DIFFUSE);
    // freed by texture library later

    camera := CreateCamera(.{0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

    backpack := CreateModel("models/backpack/backpack.obj");
    defer FreeModel(*backpack);

    cube_mesh := CreateMesh("cube", .{ CUBE_VERTICES, VERTEX_ATTRIBUTES_POS_TEXCOORDS },
        material = CreateMaterial("cube_mat", "textures/marble.jpg"));
    defer FreeMesh(*cube_mesh);

    grass_mesh := CreateMesh("grass", .{ GRASS_VERTICES, VERTEX_ATTRIBUTES_POS_TEXCOORDS },
        material = CreateMaterial("grass_mat", "textures/blending_transparent_window.png"));
    defer FreeMesh(*grass_mesh);

    plane_mesh := CreateMesh("plane", .{ PLANE_VERTICES, VERTEX_ATTRIBUTES_POS_TEXCOORDS },
        material = CreateMaterial("plane_mat", "textures/metal.png"));
    defer FreeMesh(*plane_mesh);

    // timekeeping
    currTimeSeconds, prevTimeSeconds, deltaTimeSeconds : float;

    BlendableObject :: struct {
        distance_from_camera : float;
        index : int;
    };
    CompareBlendableObjects :: (a : *BlendableObject, b : *BlendableObject) -> int {
        diff := a.distance_from_camera - b.distance_from_camera;
        if abs(diff) < 0.0001 return 0;
        return ifx diff > 0 then 1 else -1;
    }

    blendable_objects : [..] BlendableObject;

    skybox_faces : [6] string : .[
        "textures/skybox/right.jpg",
        "textures/skybox/left.jpg",
        "textures/skybox/top.jpg",
        "textures/skybox/bottom.jpg",
        "textures/skybox/front.jpg",
        "textures/skybox/back.jpg"
    ];
    skybox := CreateCubemap(*skybox_faces);
    skybox_vao, _ := CreateVertexObjects(.{SKYBOX_VERTICES, SKYBOX_VERTEX_ATTRIBUTES});
    skybox_shader := CreateShader(SKYBOX_VERTEX_SHADER, SKYBOX_FRAGMENT_SHADER);
    glUseProgram(skybox_shader);
    ShaderSetInt(skybox_shader, "skybox", 0);

    mirror_shader := CreateShader(MIRROR_VERTEX_SHADER, MIRROR_FRAGMENT_SHADER);
    glass_shader := CreateShader(MIRROR_VERTEX_SHADER, GLASS_FRAGMENT_SHADER);
    explode_shader := CreateShader(EXPLODE_VERTEX_SHADER, EXPLODE_FRAGMENT_SHADER, EXPLODE_GEOMETRY_SHADER);

    // main loop
    exit := false;
    while !exit {
        prevTimeSeconds = currTimeSeconds;
        currTimeSeconds = GetTimeMilliseconds()/1000.0;
        deltaTimeSeconds = currTimeSeconds - prevTimeSeconds;

        ProcessInput(*exit, deltaTimeSeconds, camera);

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

        // cube 1
        model := Matrix4_Identity;
        translate(*model, .{ -1.0, 0.0, -1.0 });
        ShaderSetMat4(shader, "model", *model);
        DrawMesh(cube_mesh, shader);

        model = Matrix4_Identity;
        translate(*model, .{ 2.0, 0.0, 0.0 });
        ShaderSetMat4(shader, "model", *model);
        DrawMesh(cube_mesh, shader);

        // floor
        model = Matrix4_Identity;
        ShaderSetMat4(shader, "model", *model);
        DrawMesh(plane_mesh, shader);

        // mirror backpack
        glUseProgram(mirror_shader);
        model = Matrix4_Identity;
        translate(*model, .{-10.0, 0.0, 10.0});
        ShaderSetMat4(mirror_shader, "model", *model);
        ShaderSetMat4(mirror_shader, "view", *view);
        ShaderSetMat4(mirror_shader, "projection", *projection);
        ShaderSetVec3(mirror_shader, "camera_pos", *(camera.position));
        DrawModel(backpack, mirror_shader);

        // glass backpack
        glUseProgram(glass_shader);
        model = Matrix4_Identity;
        translate(*model, .{0.0, 0.0, 10.0});
        ShaderSetMat4(glass_shader, "model", *model);
        ShaderSetMat4(glass_shader, "view", *view);
        ShaderSetMat4(glass_shader, "projection", *projection);
        ShaderSetVec3(glass_shader, "camera_pos", *(camera.position));
        DrawModel(backpack, glass_shader);

        // exploding backpack
        glUseProgram(explode_shader);
        model = Matrix4_Identity;
        translate(*model, .{10.0, 0.0, 10.0});
        ShaderSetMat4(explode_shader, "model", *model);
        ShaderSetMat4(explode_shader, "view", *view);
        ShaderSetMat4(explode_shader, "projection", *projection);
        ShaderSetFloat(explode_shader, "time", currTimeSeconds);
        DrawModel(backpack, explode_shader);

        // draw skybox last
        glDepthFunc(GL_LEQUAL);
        glUseProgram(skybox_shader);
        skybox_view := view;
        for 0..2 {
            using skybox_view;
            coef[it][3] = 0.0;
            coef[3][it] = 0.0;
        }

        ShaderSetMat4(skybox_shader, "view", *skybox_view);
        ShaderSetMat4(skybox_shader, "projection", *projection);
        glBindVertexArray(skybox_vao);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_CUBE_MAP, skybox.id); // DrawCubemap()
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArray(0);
        glDepthFunc(GL_LESS);

        // blendable objects
        grass_positions : [5] Vector3 : .[
            .{ -1.5,  0.0, -0.48 },
            .{  1.5,  0.0,  0.51 },
            .{  0.0,  0.0,  0.70 },
            .{ -0.3,  0.0, -2.30 },
            .{  0.5,  0.0, -0.60 }
        ];
        grass_yaws : [5] float = .[ 0.0, 0.0, 0.0, 0.0, 0.0 ];

        glUseProgram(shader);
        ShaderSetMat4(shader, "view", *view);
        ShaderSetMat4(shader, "projection", *projection);

        // sort
        array_reset(*blendable_objects);
        // this maybe doesnt need to be reset every frame, just re-initialize each member. O(N)
        // also we should prob be using temp allocator for this anyways? Maybe?
        for pos : grass_positions array_add(*blendable_objects, .{ length(pos - camera.position), it_index });
        heap_view := Heapify(blendable_objects, CompareBlendableObjects);

        // draw
        current_blendable_object : *BlendableObject;
        for 0..blendable_objects.count -1 {
            current_blendable_object := HeapPop(*heap_view, CompareBlendableObjects);
            using,only(index) current_blendable_object;

            // prevent planes from being culled by back face culling:
            // if this plane is facing away from the camera, rotate it 180 degrees. Hacky!
            current_front : Vector3 = .{0.0, 0.0, cos(grass_yaws[index])};
            if dot_product(grass_positions[index] - camera.position, current_front) > 0.0 grass_yaws[index] = -(grass_yaws[index] - PI);

            model = Matrix4_Identity;
            translate(*model, grass_positions[index]);
            RotateMatrix4(*model, grass_yaws[index], .{0.0, 1.0, 0.0});
            ShaderSetMat4(shader, "model", *model);
            DrawMesh(grass_mesh, shader);
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
