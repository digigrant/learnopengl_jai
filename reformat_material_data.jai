#run {
    set_build_options_dc(.{do_output = false});
    w := compiler_create_workspace();

    materials_file, ok := read_entire_file("materials");
    if !ok {
        print("No materials file found.\n");
        return;
    }

    cursor := 0;
    material_count := ReadValue(materials_file, *cursor, int);
    // materials : [] MaterialData = .{ count = material_count, data = temporary_alloc(material_count * size_of(MaterialData)) };

    builder: String_Builder;
    init_string_builder(*builder);

    for 0..material_count-1 {
        print_to_builder(*builder, "%\n", ReadValue(materials_file, *cursor, string));
        for 0..2 {
            for 0..2 print_to_builder(*builder, "%", ReadValue(materials_file, *cursor, string));
            print_to_builder(*builder, "\n");
        }
        print_to_builder(*builder, "%\n\n", ReadValue(materials_file, *cursor, string));
    }

    write_entire_file("new_materials", *builder);
}

MaterialData :: struct {
    name : string;
    ambient : Vector3;
    diffuse : Vector3;
    specular : Vector3;
    shininess : float;
}

#import "Compiler";
#import "Basic";
#import "File";
#import "String";
#import "Math";
#import "Asset_Importer";