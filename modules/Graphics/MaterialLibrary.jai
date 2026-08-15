#import "Basic";
#import "File";
#import "Status";
#import "Container";
#import "Asset_Importer";

MAX_COUNT_MATERIAL_LIBRARY :: 100;
MATERIAL_ASSET_DIRECTORY :: "assets//materials//";
material_library : *Container(Material);

requested_material_queue : [..] string;
file_to_load_queue : [..] string;
loaded_files :: [..] string;

InitMaterialLibrary :: () -> Status {
    status : Status;
    material_library, status = CreateContainer(Material, MAX_COUNT_MATERIAL_LIBRARY);

    if !IS_SUCCESSFUL(status) {
        print("Failed to create material library: %\n", status);
        return STATUS_FAILURE;
    }

    base_file := tprint("%//_base", MATERIAL_ASSET_DIRECTORY);
    file, ok := read_entire_file(base_file);

    // for each requested material, check if it's in the container. If not, prepare to load it.
    for * request : requested_material_queue {
        if FindInContainer(material_library, NameEquals, request) == null {
            array_append(*file_to_load_queue, tprint("%.mtl", request.*));
        }
    }

    // load files
    // for filename : file_to_load_queue
        
}

#run RegisterStatus(#code STATUS_FAILURE_FILE_DOESNT_EXIST);
#run RegisterStatus(#code STATUS_FAILURE_COULDNT_READ_FILE);

LoadFileToMaterialLibrary :: (path : string) -> Status {
    if !file_exists(path) return STATUS_FAILURE_FILE_DOESNT_EXIST;

    ok, mtl_data := ImportDataFromMtl(path);
    if !ok return STATUS_FAILURE_COULDNT_READ_FILE;
    defer array_append(*loaded_files, path);

    temp : Material;
    for mtl : mtl_data {
        // "hard data" - this could be memcpy'ed straight from the mtl data
        temp.name = mtl.name;
        temp.ambient_color = mtl.ambient_color;
        temp.diffuse_color = mtl.diffuse_color;
        temp.specular_color = mtl.specular_color;
        temp.shininess = mtl.shininess;
    }
        
        

    cursor := 0;
    material_count := ReadValue(materials_file, *cursor, int);
    material : *Material;
    for 0..material_count-1 {
        new_name := trim_right(ReadValue(materials_file, *cursor, string));
        material = AddToMaterialLibrary(new_name);
        assert(material != null);
        using material;
        ambient_color =     ReadValue(materials_file, *cursor, Vector3);
        diffuse_color =     ReadValue(materials_file, *cursor, Vector3);
        specular_color =    ReadValue(materials_file, *cursor, Vector3);
        shininess =         ReadValue(materials_file, *cursor, float);
    }
}

// Models will call this to declare the mtllib file that contains their materials
// The file must be loaded before the material can be used
PrepareFile :: (filename : string) {
    // if filename is not in loaded_files,
    // add to files_to_load
}

#run RegisterStatus(#code STATUS_FAILURE_NAME_ALREADY_EXISTS);

AddToMaterialLibrary :: (material : *Material) -> Status {
    if FindInContainer(material_library, NameEquals, *(material.*.name)) != null return STATUS_FAILURE_NAME_ALREADY_EXISTS;

    status := AddToContainer(material_library, material);
    if !IS_SUCCESSFUL(status) print("Couldn't add material to library: %\n", status);

    return STATUS_SUCCESS;
}























#scope_file

MATERIAL_LIBRARY_SIZE :: 64;
MATERIAL_LIBRARY_COUNT_TYPE :: u8;

MaterialLibrary :: struct {
    material_list : [MATERIAL_LIBRARY_SIZE] Material;    // should these be resizable, considering reallocating the array? Not sure what makes sense
    count : MATERIAL_LIBRARY_COUNT_TYPE;
};

material_library : MaterialLibrary;

#scope_export

InitMaterialLibrary :: (import_basic := true) {
    using material_library;
    memset(*material_list, 0, size_of(Material) * MATERIAL_LIBRARY_SIZE);
    count = 0;

    if import_basic ImportFileToMaterialLibrary("materials");
}

ImportFileToMaterialLibrary :: (path : string) {
    materials_file, ok := read_entire_file(path);
    if !ok {
        print("No materials file found at '%'.\n", path);
        return;
    }

    cursor := 0;
    material_count := ReadValue(materials_file, *cursor, int);
    material : *Material;
    for 0..material_count-1 {
        new_name := trim_right(ReadValue(materials_file, *cursor, string));
        material = AddToMaterialLibrary(new_name);
        assert(material != null);
        using material;
        ambient_color = ReadValue(materials_file, *cursor, Vector3);
        diffuse_color = ReadValue(materials_file, *cursor, Vector3);
        specular_color = ReadValue(materials_file, *cursor, Vector3);

        SHININESS_MULTIPLIER :: 128.0;
        shininess = ReadValue(materials_file, *cursor, float) * SHININESS_MULTIPLIER;
    }
}

BuildFromMaterialLibrary :: (name : string) -> material : *Material {
    assert(name != "");

    material := FindFromMaterialLibrary(name);
    if !material material = AddToMaterialLibrary(name);
    return material;
}

FreeEntireMaterialLibrary :: () {
    using material_library;

    for material_list FreeMaterial(*it);
}

#scope_file

FindFromMaterialLibrary :: (name : string) -> material : *Material {
    assert(name != "");
    using material_library;
    if count == 0 return null;
    
    // if we find the material return it, otherwise return null
    for 0..count-1 {
        if material_list[it].name == name return *(material_list[it]);
    }
    return null;
}

AddToMaterialLibrary :: (name : string) -> material : *Material {
    using material_library;
    assert(count < MATERIAL_LIBRARY_SIZE);
    print("Creating material: '%'\n", name);

    material := *(material_list[count]);
    count += 1;
    material.name = name;   // might as well set the name since we have it
    return material;
}
