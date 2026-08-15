// EntityLibrary is responsible for:
// - loading entity recipes from file and storing in entity_recipe_container
// - creating entity prototypes from recipes and storing in entity_prototype_container
// - building entity instances from prototypes

#import "Basic";
#import "File";
#import "Status";
#import "Container";
#import "Asset_Importer";

ENTITY_LIBRARY_PROTOTYPE_RECIPE_CONTAINER_SIZE :: 100;
ENTITY_LIBRARY_PROTOTYPE_RECIPE_CONTAINER_COUNT_TYPE :: u8;
ENTITY_LIBRARY_PROTOTYPE_CONTAINER_SIZE :: 100;
ENTITY_LIBRARY_PROTOTYPE_CONTAINER_COUNT_TYPE :: u8;

MAX_COUNT_ENTITY_RECIPE_LIBRARY :: 100;
entity_recipe_library : *Container(EntityRecipe);

ENTITY_ASSET_DIRECTORY :: "assets//entities//";

// @TODO: do compile-time check: size can fit in count type (i.e. cant have size 256 in u8 count type)

EntityRecipe :: struct {
    name : string;
    mesh_name : string;
    material_name : string;
    shader_program_name : string;
};

InitEntityRecipeLibrary :: () -> Status {
    status : Status;
    entity_recipe_library, status = CreateContainer(EntityRecipe, MAX_COUNT_ENTITY_RECIPE_LIBRARY);
    if !IS_SUCCESSFUL(status) {
        print("Failed to create entity recipe library: %\n", status);
        return STATUS_FAILURE;
    }

    base_file := tprint("%//_base", ENTITY_ASSET_DIRECTORY);
    status = ImportFileToEntityLibrary(base_file);

    if !IS_SUCCESSFUL(status) {
        print("Failed to import base file: '%'\n", base_file);
        return STATUS_FAILURE;
    }

    return STATUS_SUCCESS;
}

#run RegisterStatus(#code STATUS_FAILURE_RECIPE_ALREADY_EXISTS_IN_LIBRARY);

AddEntityRecipeToLibrary :: (p_recipe : *EntityRecipe) -> Status {
    if !p_recipe return STATUS_FAILURE;
    
    // Check if this recipe already exists in the library
    if FindInContainer(entity_recipe_library, NameEquals, *(p_recipe.*.name)) != null return STATUS_FAILURE_RECIPE_ALREADY_EXISTS_IN_LIBRARY;

    status := AddToContainer(entity_recipe_library, p_recipe);

    if !IS_SUCCESSFUL(status) print("Couldn't add recipe to library: %\n", status);

    return STATUS_SUCCESS;
}

#run RegisterStatus(#code STATUS_FAILURE_COULDNT_READ_FILE);

ImportFileToEntityLibrary :: (path : string) -> Status {
    file, ok := read_entire_file(path);
    if !ok return STATUS_FAILURE_COULDNT_READ_FILE;

    cursor := 0;
    count := ReadValue(file, *cursor, int);
    temp : EntityRecipe;
    for 0..count-1 {
        memset(*temp, 0, size_of(EntityRecipe));
        temp.name =                 ReadValue(file, *cursor, string);
        temp.mesh_name =            ReadValue(file, *cursor, string);
        temp.material_name =        ReadValue(file, *cursor, string);
        temp.shader_program_name =  ReadValue(file, *cursor, string);
        
        if !IS_SUCCESSFUL(AddEntityRecipeToLibrary(*temp)) {
            print("Couldn't add recipe '%' to library.\n", temp.name);
        }
    }

    return STATUS_SUCCESS;
}

PrintEntityRecipeLibrary :: () { PrintContainer(entity_recipe_library); }







/*

EntityPrototype :: struct {
    recipe : *EntityPrototypeRecipe;
    mesh : *Mesh;
    material : *Material;
    shader_program : *ShaderProgram;
};

#scope_module



CloneEntityFromPrototype :: (name : string) -> entity : *Entity {
    assert(name != "");
    
    entity := FindEntityPrototypeInLibrary(name);
    if !entity return null;


}

#scope_file


BuildEntityPrototypeFromRecipe :: (recipe_name : string) -> Status, *{
    if recipe_name == "" return STATUS_FAILED;
    if entity_prototype_count >= ENTITY_LIBRARY_PROTOTYPE_CONTAINER_SIZE return STATUS_FAILED;

    entity_prototype_recipe := FindEntityPrototypeRecipeInLibrary(recipe_name);

    // Create entity prototype from recipe
    print("Building EntityPrototype: '%'\n", name);

    entity_prototype = *(entity_prototype_container[count]);
    {
        using entity_prototype_recipe.*;
        using entity_prototype.*;

        recipe = entity_prototype_recipe;
        mesh = FindMesh(mesh_name);
        material = FindFromMaterialLibrary(material_name)
        shader_program = FindShaderProgram(shader_program_name);
    }
    
    entity_prototype_count += 1;
    return STATUS_SUCCESS;
}

FindEntityPrototypeRecipeInLibrary :: (recipe_name : string) -> entity_prototype_recipe : *EntityPrototypeRecipe {
    assert(recipe_name != "");
    using entity_library;
    if entity_prototype_recipe_count == 0 return null;

    for 0..entity_prototype_recipe_count-1 {
        if entity_prototype_recipe_container[it].name == recipe_name return *(entity_prototype_recipe_container[it]);
    }

    return null;
}

#scope_module

FindEntityPrototypeInLibrary :: (name : string) -> entity_prototype : *EntityPrototype {
    assert(name != "");
    using entity_library;
    if entity_prototype_count == 0 return null;

    for 0..entity_prototype_count-1 {
        if entity_prototype_container[it].recipe.*.name == name return *(entity_prototype_container[it]);
    }

    return null;
}
*/
