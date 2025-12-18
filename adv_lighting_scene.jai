#import "Basic";
#import "GL";
#import "Math";
#import "Extra_Stuff";

using,except (Init, Shutdown) Graphics :: #import "Graphics";
using,except (Init, Shutdown) Input :: #import "Input";
#import "Events";

#load "shaders.jai";
// using,only (SKYBOX_VERTICES, SKYBOX_VERTEX_ATTRIBUTES) #load "vertex_data.jai";

CUBE_VERTICES : [288] float : .[
    // positions        // normals          // texture coords

    // back
    -1.0, -1.0, -1.0,   0.0,  0.0, -1.0,    0.0,  0.0,
     1.0,  1.0, -1.0,   0.0,  0.0, -1.0,    1.0,  1.0,
     1.0, -1.0, -1.0,   0.0,  0.0, -1.0,    1.0,  0.0,
     1.0,  1.0, -1.0,   0.0,  0.0, -1.0,    1.0,  1.0,
    -1.0, -1.0, -1.0,   0.0,  0.0, -1.0,    0.0,  0.0,
    -1.0,  1.0, -1.0,   0.0,  0.0, -1.0,    0.0,  1.0,

    // front
    -1.0, -1.0,  1.0,   0.0,  0.0,  1.0,    0.0,  0.0,
     1.0, -1.0,  1.0,   0.0,  0.0,  1.0,    1.0,  0.0,
     1.0,  1.0,  1.0,   0.0,  0.0,  1.0,    1.0,  1.0,
     1.0,  1.0,  1.0,   0.0,  0.0,  1.0,    1.0,  1.0,
    -1.0,  1.0,  1.0,   0.0,  0.0,  1.0,    0.0,  1.0,
    -1.0, -1.0,  1.0,   0.0,  0.0,  1.0,    0.0,  0.0,

    // left
    -1.0,  1.0,  1.0,  -1.0,  0.0,  0.0,    1.0,  0.0,
    -1.0,  1.0, -1.0,  -1.0,  0.0,  0.0,    1.0,  1.0,
    -1.0, -1.0, -1.0,  -1.0,  0.0,  0.0,    0.0,  1.0,
    -1.0, -1.0, -1.0,  -1.0,  0.0,  0.0,    0.0,  1.0,
    -1.0, -1.0,  1.0,  -1.0,  0.0,  0.0,    0.0,  0.0,
    -1.0,  1.0,  1.0,  -1.0,  0.0,  0.0,    1.0,  0.0,

    // right
     1.0,  1.0,  1.0,   1.0,  0.0,  0.0,    1.0,  0.0,
     1.0, -1.0, -1.0,   1.0,  0.0,  0.0,    0.0,  1.0,
     1.0,  1.0, -1.0,   1.0,  0.0,  0.0,    1.0,  1.0,
     1.0, -1.0, -1.0,   1.0,  0.0,  0.0,    0.0,  1.0,
     1.0,  1.0,  1.0,   1.0,  0.0,  0.0,    1.0,  0.0,
     1.0, -1.0,  1.0,   1.0,  0.0,  0.0,    0.0,  0.0,

    // bottom
    -1.0, -1.0, -1.0,   0.0, -1.0,  0.0,    0.0,  1.0,
     1.0, -1.0, -1.0,   0.0, -1.0,  0.0,    1.0,  1.0,
     1.0, -1.0,  1.0,   0.0, -1.0,  0.0,    1.0,  0.0,
     1.0, -1.0,  1.0,   0.0, -1.0,  0.0,    1.0,  0.0,
    -1.0, -1.0,  1.0,   0.0, -1.0,  0.0,    0.0,  0.0,
    -1.0, -1.0, -1.0,   0.0, -1.0,  0.0,    0.0,  1.0,

    // top
    -1.0,  1.0, -1.0,   0.0,  1.0,  0.0,    0.0,  1.0,
     1.0,  1.0,  1.0,   0.0,  1.0,  0.0,    1.0,  0.0,
     1.0,  1.0, -1.0,   0.0,  1.0,  0.0,    1.0,  1.0,
     1.0,  1.0,  1.0,   0.0,  1.0,  0.0,    1.0,  0.0,
    -1.0,  1.0, -1.0,   0.0,  1.0,  0.0,    0.0,  1.0,
    -1.0,  1.0,  1.0,   0.0,  1.0,  0.0,    0.0,  0.0
];

CUBE_VERTEX_ATTRIBUTES : [3] VertexAttribute : .[.{3}, .{3}, .{2} ];

CUBE_POSITIONS : [3] Vector3 : .[
    .{  0.0, 1.5, 0.0 },
    .{  2.0, 0.0, 1.0 },
    .{ -1.0, 0.0, 2.0 }
];

PLANE_VERTICES : [48] float : .[
    // positions            // normals          // texcoords
     25.0, -0.5,  25.0,     0.0, 1.0, 0.0,      25.0, 0.0,
    -25.0, -0.5, -25.0,     0.0, 1.0, 0.0,      0.0, 25.0,
    -25.0, -0.5,  25.0,     0.0, 1.0, 0.0,      0.0, 0.0,

     25.0, -0.5,  25.0,     0.0, 1.0, 0.0,      25.0, 0.0,
     25.0, -0.5, -25.0,     0.0, 1.0, 0.0,      25.0, 25.0,
    -25.0, -0.5, -25.0,     0.0, 1.0, 0.0,      0.0, 25.0
];

PLANE_VERTEX_ATTRIBUTES : [3] VertexAttribute : .[.{3}, .{3}, .{2} ];

SHADOW_WIDTH    :: 1024;
SHADOW_HEIGHT   :: 1024;
SHADOW_ASPECT_RATIO :: cast(float) SHADOW_WIDTH / SHADOW_HEIGHT;

DIRECTIONAL_LIGHT :: DirectionalLight.{
    direction       = .{ 2.0,-4.0, 1.0 },    // -pos
    ambient_color   = .{ 0.2, 0.2, 0.2 },
    diffuse_color   = .{ 0.5, 0.5, 0.5 },
    specular_color  = .{ 1.0, 1.0, 1.0 }
};

DEPTH_QUAD_VERTICES : [20] float : .[
    0.2, 1.0, 0.0, 0.0, 1.0,
    0.2, 0.2, 0.0, 0.0, 0.0,
    1.0, 1.0, 0.0, 1.0, 1.0,
    1.0, 0.2, 0.0, 1.0, 0.0,
];

/*** Skybox ***/

SKYBOX_VERTEX_ATTRIBUTES : [1] VertexAttribute : .[
    .{3}
];

SKYBOX_VERTICES : [108] float : .[
    // positions          
    -1.0,  1.0, -1.0,
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
    -1.0,  1.0, -1.0,

    -1.0, -1.0,  1.0,
    -1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,
    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
    -1.0, -1.0,  1.0,

     1.0, -1.0, -1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0, -1.0,
     1.0, -1.0, -1.0,

    -1.0, -1.0,  1.0,
    -1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0, -1.0,  1.0,
    -1.0, -1.0,  1.0,

    -1.0,  1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,
    -1.0,  1.0, -1.0,

    -1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
     1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0
];

DEPTH_QUAD_VERTEX_ATTRIBUTES : [2] VertexAttribute : .[ .{3}, .{2} ];

main :: () {
    InitAllSystems();

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);

    /*** CAMERA ***/
    camera := CreateCamera(.{ 0.0, 0.0, 3.0});
    defer FreeCamera(*camera);

    /*** MESHES ***/

    // PLANE
    plane_mesh := CreateMesh("plane", .{ PLANE_VERTICES, PLANE_VERTEX_ATTRIBUTES });
    plane_mesh.material = BuildFromMaterialLibrary("wood_floor");
    {
        using plane_mesh.material;
        diffuse_texture = BuildFromTextureLibrary("textures/wood.png", .DIFFUSE);
        specular_texture = BuildFromTextureLibrary("textures/white_pixel.jpg", .SPECULAR);
        shininess = 32.0;
    }
    defer FreeMesh(*plane_mesh);

    // CUBE
    cube_mesh := CreateMesh("cube", .{ CUBE_VERTICES, CUBE_VERTEX_ATTRIBUTES });
    cube_mesh.material = BuildFromMaterialLibrary("cube_mat");
    {
        using cube_mesh.material;
        diffuse_texture = BuildFromTextureLibrary("textures/marble.jpg", .DIFFUSE);
        specular_texture = BuildFromTextureLibrary("textures/white_pixel.jpg", .SPECULAR);
        shininess = 64.0;
    }
    defer FreeMesh(*cube_mesh);

    // DEPTH_QUAD - TEMPORARY
    depth_quad_mesh := CreateMesh("depth_quad", .{DEPTH_QUAD_VERTICES, DEPTH_QUAD_VERTEX_ATTRIBUTES});
    defer FreeMesh(*depth_quad_mesh);

    /*** SHADERS ***/

    simple_depth_shader := CreateShader(SIMPLE_DEPTH_VERTEX_SHADER, SIMPLE_DEPTH_FRAGMENT_SHADER);

    simple_depth_cubemap_shader := CreateShader(
        SIMPLE_DEPTH_CUBEMAP_VERTEX_SHADER,
        SIMPLE_DEPTH_CUBEMAP_FRAGMENT_SHADER,
        SIMPLE_DEPTH_CUBEMAP_GEOMETRY_SHADER);

    depth_quad_shader := CreateShader(DEPTH_QUAD_VERTEX_SHADER, DEPTH_QUAD_FRAGMENT_SHADER);
    {
        glUseProgram(depth_quad_shader);
        ShaderSetInt(depth_quad_shader, "depth_map", 0);
    }
    // cube_shader := CreateShader(CUBE_VERTEX_SHADER, BLINN_CUBE_FRAGMENT_SHADER);

    skybox_vao, _ := CreateVertexObjects(.{SKYBOX_VERTICES, SKYBOX_VERTEX_ATTRIBUTES});
    skybox_shader := CreateShader(SKYBOX_VERTEX_SHADER, SKYBOX_FRAGMENT_SHADER);
    glUseProgram(skybox_shader);
    ShaderSetInt(skybox_shader, "skybox", 0);

    

    depth_map_fbo : GLuint;
    glGenFramebuffers(1, *depth_map_fbo);

    depth_map_texture : GLuint;
    {
        glGenTextures(1, *depth_map_texture);
        glBindTexture(GL_TEXTURE_2D, depth_map_texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, SHADOW_WIDTH, SHADOW_HEIGHT, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
        DEPTH_MAP_BORDER_COLOR : Vector4 : #run make_vector4(1.0);
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, *(DEPTH_MAP_BORDER_COLOR.x));
    
        glBindFramebuffer(GL_FRAMEBUFFER, depth_map_fbo);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depth_map_texture, 0);
        glDrawBuffer(GL_NONE);  // we have to do this to specify that we dont want to draw color to the frame buffer
        glReadBuffer(GL_NONE);  // same
        if glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE {
            print("ERROR::FRAMEBUFFER:: Depth framebuffer is not complete!");
        }
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    depth_cube_map_texture : GLuint;
    {
        glGenTextures(1, *depth_cube_map_texture);
        glBindTexture(GL_TEXTURE_CUBE_MAP, depth_cube_map_texture);
        for 0..5 glTexImage2D(cast(GLuint) (GL_TEXTURE_CUBE_MAP_POSITIVE_X + it), 0,
            GL_DEPTH_COMPONENT, SHADOW_WIDTH, SHADOW_HEIGHT, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

        glBindFramebuffer(GL_FRAMEBUFFER, depth_map_fbo);
        glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, depth_cube_map_texture, 0);
        glDrawBuffer(GL_NONE);  // we have to do this to specify that we dont want to draw color to the frame buffer
        glReadBuffer(GL_NONE);  // same
        if glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE {
            print("ERROR::FRAMEBUFFER:: Depth framebuffer is not complete!");
        }
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }



    shadow_shader := CreateShader(SHADOW_VERTEX_SHADER, BLINN_SHADOW_FRAGMENT_SHADER);
    {
        glUseProgram(shadow_shader);
        ShaderSetTexture2D(shadow_shader, "shadow_map", depth_map_texture, 2);
        ShaderSetVec3(shadow_shader, "directional_light.ambient", DIRECTIONAL_LIGHT.ambient_color);
        ShaderSetVec3(shadow_shader, "directional_light.diffuse", DIRECTIONAL_LIGHT.diffuse_color);
        ShaderSetVec3(shadow_shader, "directional_light.specular", DIRECTIONAL_LIGHT.specular_color);
    }


    point_light : PointLight;
    {
        using point_light;
        position = .{ 2.0, 2.0, 0.0 };

        ambient_color = .{ 0.2, 0.2, 0.2 };
        diffuse_color = .{ 0.5, 0.5, 0.5 };
        specular_color = .{ 1.0, 1.0, 1.0 };

        constant = 1.0;
        linear = 0.09;
        quadratic = 0.032;
    }

    omnidirectional_shadow_shader := CreateShader(OMNIDIRECTIONAL_SHADOWS_VERTEX_SHADER, OMNIDIRECTIONAL_SHADOWS_FRAGMENT_SHADER);
    {
        glUseProgram(omnidirectional_shadow_shader);
        ShaderSetTexture(omnidirectional_shadow_shader, "shadow_map", depth_cube_map_texture, GL_TEXTURE_CUBE_MAP, 2);
        ShaderSetInt(omnidirectional_shadow_shader, "num_point_lights", 1);
        {
            ShaderSetVec3(omnidirectional_shadow_shader, "point_lights[0].ambient", point_light.ambient_color);
            ShaderSetVec3(omnidirectional_shadow_shader, "point_lights[0].diffuse", point_light.diffuse_color);
            ShaderSetVec3(omnidirectional_shadow_shader, "point_lights[0].specular", point_light.specular_color);
            ShaderSetFloat(omnidirectional_shadow_shader, "point_lights[0].constant", point_light.constant);
            ShaderSetFloat(omnidirectional_shadow_shader, "point_lights[0].linear", point_light.linear);
            ShaderSetFloat(omnidirectional_shadow_shader, "point_lights[0].quadratic", point_light.quadratic);
        }
        
    }

    point_light_shader := CreateShader(CUBE_VERTEX_SHADER, LIGHT_FRAGMENT_SHADER);
    {
        glUseProgram(point_light_shader);
        ShaderSetVec3(point_light_shader, "color", point_light.specular_color);
    }

    
    
    

    
    

    curr_time_seconds, prev_time_seconds, delta_time_seconds : float;
    exit := false;
    while !exit {
        // update time
        prev_time_seconds = curr_time_seconds;
        curr_time_seconds = GetTimeMilliseconds() / 1000.0;
        delta_time_seconds = curr_time_seconds - prev_time_seconds;

        ProcessInput(*exit, delta_time_seconds, camera);

        /*  We might not need this at all anymore
        glClearColor(0.1, 0.1, 0.1, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        */

        /*
        // spin the directional light
        t_matrix := Matrix4_Identity;
        RotateMatrix4(*t_matrix, DegToRad(curr_time_seconds * 20.0), .{0, 1, 0});
        current_light_dir := (t_matrix * make_vector4(DIRECTIONAL_LIGHT.direction, 0.0)).xyz;
        */
        

        /*
        near_plane := 1.0;
        far_plane := 7.5;
        light_space : Matrix4;
        {   // directional light depth pass
            glUseProgram(simple_depth_shader);

            light_projection := orthographic_projection_matrix(-10.0, 10.0, -10.0, 10.0, near_plane, far_plane);
            // in LearnOpenGL this "look_at" function seems to roll the camera as well
            // it doesnt do it here and it probably ought to not do that. Just FYI
            light_view := make_look_at_matrix(-current_light_dir, make_vector3(0.0), .{0.0, 1.0, 0.0}, false);
            light_space = light_projection * light_view;
            
            ShaderSetMat4(simple_depth_shader, "light_space", *light_space);

            // render all things in scene
            glViewport(0, 0, SHADOW_WIDTH, SHADOW_HEIGHT);
            glBindFramebuffer(GL_FRAMEBUFFER, depth_map_fbo);
            glClear(GL_DEPTH_BUFFER_BIT);

            model := Matrix4_Identity;
            ShaderSetMat4(simple_depth_shader, "model", *model);
            DrawMesh(plane_mesh, simple_depth_shader);

            //glCullFace(GL_FRONT);

            for cube_pos : CUBE_POSITIONS {
                model = Matrix4_Identity;
                translate(*model, cube_pos);
                if it_index == 2 RotateMatrix4(*model, #run DegToRad(60.0), #run normalize(Vector3.{1.0, 0.0, 1.0}));
                scale(*model, ifx it_index != 2 then 0.5 else 0.25);
                ShaderSetMat4(simple_depth_shader, "model", *model);
                DrawMesh(cube_mesh, simple_depth_shader);
            }

            //glCullFace(GL_BACK);

            glBindFramebuffer(GL_FRAMEBUFFER, 0); // done rendering light depth pass
        }
        */


        // spin the point light
        t_matrix := Matrix4_Identity;
        RotateMatrix4(*t_matrix, DegToRad(curr_time_seconds * 20.0), .{0, 1, 0});
        point_light_pos := (t_matrix * make_vector4(point_light.position, 1.0)).xyz;


        near := 1.0;
        far := 25.0;
        {   // render to depth cubemap
            glViewport(0, 0, SHADOW_WIDTH, SHADOW_HEIGHT);
            glBindFramebuffer(GL_FRAMEBUFFER, depth_map_fbo);
            glClear(GL_DEPTH_BUFFER_BIT);

            // set up shader
            glUseProgram(simple_depth_cubemap_shader);
            ShaderSetFloat(simple_depth_cubemap_shader, "far_plane", far);

            //point_light_pos := point_light.position;

            ShaderSetVec3(simple_depth_cubemap_shader, "light_pos", point_light_pos);
            shadow_projection := make_projection_matrix(#run DegToRad(90.0), SHADOW_ASPECT_RATIO, near, far);   // optional param for depth_range_01
            shadow_transforms : *[6] Matrix4 = temporary_alloc(6 * size_of(Matrix4));
            {
                shadow_transforms.*[0] = shadow_projection * make_look_at_matrix(point_light_pos, point_light_pos + V3_POS_X, V3_NEG_Y, false);
                shadow_transforms.*[1] = shadow_projection * make_look_at_matrix(point_light_pos, point_light_pos + V3_NEG_X, V3_NEG_Y, false);
                shadow_transforms.*[2] = shadow_projection * make_look_at_matrix(point_light_pos, point_light_pos + V3_POS_Y, V3_POS_Z, false);
                shadow_transforms.*[3] = shadow_projection * make_look_at_matrix(point_light_pos, point_light_pos + V3_NEG_Y, V3_NEG_Z, false);
                shadow_transforms.*[4] = shadow_projection * make_look_at_matrix(point_light_pos, point_light_pos + V3_POS_Z, V3_NEG_Y, false);
                shadow_transforms.*[5] = shadow_projection * make_look_at_matrix(point_light_pos, point_light_pos + V3_NEG_Z, V3_NEG_Y, false);
            }
            for t, i : shadow_transforms.* ShaderSetMat4(simple_depth_cubemap_shader, sprint("shadow_matrices[%]", i), *t);

            // render all things in scene
            model := Matrix4_Identity;
            ShaderSetMat4(simple_depth_cubemap_shader, "model", *model);
            DrawMesh(plane_mesh, simple_depth_cubemap_shader);

            //glCullFace(GL_FRONT);

            for cube_pos : CUBE_POSITIONS {
                model = Matrix4_Identity;
                translate(*model, cube_pos);
                if it_index == 2 RotateMatrix4(*model, #run DegToRad(60.0), #run normalize(Vector3.{1.0, 0.0, 1.0}));
                scale(*model, ifx it_index != 2 then 0.5 else 0.25);
                ShaderSetMat4(simple_depth_cubemap_shader, "model", *model);
                DrawMesh(cube_mesh, simple_depth_cubemap_shader);
            }

            glBindFramebuffer(GL_FRAMEBUFFER, 0); // done rendering light depth pass
        }
        



        
        CameraUpdate(camera, delta_time_seconds);

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

        

        SetupRenderSceneToFrameBuffer();
        glViewport(0, 0, windowWidth, windowHeight);    // should maybe move to function

        
        /*
        // draw skybox last
        glUseProgram(skybox_shader);
        {
            glDepthFunc(GL_LEQUAL);

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
            glBindTexture(GL_TEXTURE_CUBE_MAP, depth_cube_map_texture); // DrawCubemap()
            glDrawArrays(GL_TRIANGLES, 0, 36);
            glBindVertexArray(0);

            glDepthFunc(GL_LESS);
        }
        */

        
        /*
        {   // render scene (directional light)
            glViewport(0, 0, windowWidth, windowHeight);

            glUseProgram(shadow_shader);
            directional_light_view_dir : Vector3 = (view * make_vector4(current_light_dir, 0.0)).xyz;
            ShaderSetVec3(shadow_shader, "directional_light.direction", directional_light_view_dir);
            ShaderSetMat4(shadow_shader, "light_space", *light_space);

            model := Matrix4_Identity;
            ShaderSetMat4(shadow_shader, "model", *model);
            DrawMesh(plane_mesh, shadow_shader);

            for cube_pos : CUBE_POSITIONS {
                model = Matrix4_Identity;
                translate(*model, cube_pos);
                if it_index == 2 RotateMatrix4(*model, #run DegToRad(60.0), #run normalize(Vector3.{1.0, 0.0, 1.0}));
                scale(*model, ifx it_index != 2 then 0.5 else 0.25);
                ShaderSetMat4(shadow_shader, "model", *model);
                DrawMesh(cube_mesh, shadow_shader);
            }
        }
        */

        
        

        
        point_light_view_pos := (view * make_vector4(point_light_pos, 1.0)).xyz;

        {   // render scene (point lights)
            glUseProgram(omnidirectional_shadow_shader);
            ShaderSetVec3(omnidirectional_shadow_shader, "point_lights[0].position", point_light_view_pos);
            ShaderSetVec3(omnidirectional_shadow_shader, "point_light_pos_world_space", point_light_pos);
            ShaderSetFloat(omnidirectional_shadow_shader, "far_plane", far);

            model := Matrix4_Identity;
            ShaderSetMat4(omnidirectional_shadow_shader, "model", *model);
            DrawMesh(plane_mesh, omnidirectional_shadow_shader);

            for cube_pos : CUBE_POSITIONS {
                model = Matrix4_Identity;
                translate(*model, cube_pos);
                if it_index == 2 RotateMatrix4(*model, #run DegToRad(60.0), #run normalize(Vector3.{1.0, 0.0, 1.0}));
                scale(*model, ifx it_index != 2 then 0.5 else 0.25);
                ShaderSetMat4(omnidirectional_shadow_shader, "model", *model);
                DrawMesh(cube_mesh, omnidirectional_shadow_shader);
            }
        }

        {
            glUseProgram(point_light_shader);

            model := Matrix4_Identity;
            translate(*model, point_light_pos);
            scale(*model, 0.1);
            ShaderSetMat4(point_light_shader, "model", *model);
            DrawMesh(cube_mesh, point_light_shader);
        }
        

        /*
        {   // render depth PIP window
            glUseProgram(depth_quad_shader);
            ShaderSetFloat(depth_quad_shader, "near_plane", near_plane);
            ShaderSetFloat(depth_quad_shader, "far_plane", far_plane);
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, depth_map_texture);
            //DrawMesh(depth_quad_mesh, depth_quad_shader);
            glBindVertexArray(depth_quad_mesh.VAO);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            glBindVertexArray(0);
        }
        */

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
