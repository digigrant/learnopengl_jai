#import "Compiler";
#import "File";

#run {
    set_build_options_dc(.{do_output=false});

    w := compiler_create_workspace();

    {   // main executable
        options := get_build_options(w);
        options.output_type = .EXECUTABLE;
        options.output_executable_name = "adv_lighting_scene";

        if make_directory_if_it_does_not_exist("build") {
            options.output_path = "build";
        }
        set_build_options(options, w);

        add_build_file("adv_lighting_scene.jai", w);
    }
}
