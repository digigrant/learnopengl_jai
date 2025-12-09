#import "File";

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