#import "Compiler";
#import "File";
#import "Basic";
Status :: #import "Status";

#run {
    set_build_options_dc(.{do_output=false});

    w := compiler_create_workspace();

    intercept_flags : Intercept_Flags;
    
    options := get_build_options(w);
    options.output_type = .EXECUTABLE;
    options.output_executable_name = "tests";

    if make_directory_if_it_does_not_exist("build") {
        options.output_path = "build";
    }

    import_dirs : [..] string;
    array_add(*import_dirs, ..options.import_path);
    array_add(*import_dirs, "..");
    options.import_path = import_dirs;

    set_build_options(options, w);

    compiler_begin_intercept(w, intercept_flags);

    add_build_file("tests.jai", w);

    message_loop(w);

    compiler_end_intercept(w);
}

message_loop :: (w : Workspace) {
    while true {
        message := compiler_wait_for_message();
        if message.kind == .COMPLETE break;
        Status.HandleMessage(message);
    }
}
