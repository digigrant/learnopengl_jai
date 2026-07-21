// EntityLibrary is responsible for:
// - loading entity recipes from file and storing in entity_recipe_container
// - creating entity prototypes from recipes and storing in entity_prototype_container
// - building entity instances from prototypes

#import "File";

#scope_file

ENTITY_LIBRARY_PROTOTYPE_RECIPE_CONTAINER_SIZE :: 100;
ENTITY_LIBRARY_PROTOTYPE_RECIPE_CONTAINER_COUNT_TYPE :: u8;
ENTITY_LIBRARY_PROTOTYPE_CONTAINER_SIZE :: 100;
ENTITY_LIBRARY_PROTOTYPE_CONTAINER_COUNT_TYPE :: u8;

// @TODO: do compile-time check: size can fit in count type (i.e. cant have size 256 in u8 count type)

EntityPrototypeRecipe :: struct {
    name : string;
    mesh_name : string;
    material_name : string;
    shader_program_name : string;
};

EntityPrototype :: struct {
    recipe : *EntityPrototypeRecipe;
    mesh : *Mesh;
    material : *Material;
    shader_program : *ShaderProgram;
};

EntityLibrary :: struct {
    entity_prototype_recipe_container : [ENTITY_LIBRARY_PROTOTYPE_RECIPE_CONTAINER_SIZE] EntityPrototypeRecipe;
    entity_prototype_container : [ENTITY_LIBRARY_PROTOTYPE_CONTAINER_SIZE] EntityPrototype;
    entity_prototype_recipe_count : ENTITY_LIBRARY_PROTOTYPE_RECIPE_CONTAINER_COUNT_TYPE;
    entity_prototype_count : ENTITY_LIBRARY_PROTOTYPE_CONTAINER_COUNT_TYPE;
};

entity_library : EntityLibrary;

#scope_module

InitEntityLibrary :: () -> Status {
    using entity_library;
    memset(*entity_prototype_recipe_container, 0, size_of(EntityPrototypeRecipe) * ENTITY_LIBRARY_PROTOTYPE_RECIPE_CONTAINER_SIZE);
    memset(*entity_prototype_container, 0, size_of(EntityPrototype) * ENTITY_LIBRARY_PROTOTYPE_CONTAINER_SIZE);
    entity_prototype_recipe_count = 0;
    entity_prototype_count = 0;

    return STATUS_SUCCESS;
}

STATUS_FAILED_COULDNT_READ_FILE : Status : LOCAL_STATUS_PREFIX || 1;

ImportFileToEntityLibrary :: (path : string) -> Status {
    file, ok := read_entire_file(path);
    if !ok return STATUS_FAILED_COULDNT_READ_FILE;

    cursor := 0;
    count := ReadValue(file, *cursor, int);
    temp : EntityPrototypeRecipe;
    for 0..count-1 {
        memset(*temp, 0, size_of(EntityPrototypeRecipe));
        temp.name = ReadValue(file, *cursor, string);
        temp.mesh_name = ReadValue(file, *cursor, string);
        temp.material_name = ReadValue(file, *cursor, string);
        temp.shader_program_name = ReadValue(file, *cursor, string);
        
        if !IS_SUCCESSFUL(AddEntityPrototypeRecipeToLibrary(*temp)) {
            print("Couldn't add recipe '%' to library.\n", temp.name);
        }
    }

    return STATUS_SUCCESS;
}

CloneEntityFromPrototype :: (name : string) -> entity : *Entity {
    assert(name != "");
    
    entity := FindEntityPrototypeInLibrary(name);
    if !entity return null;


}

#scope_file

STATUS_FAILED_ALREADY_EXISTS :: LOCAL_STATUS_PREFIX || 2;
AddEntityPrototypeRecipeToLibrary :: (p_recipe : *EntityPrototypeRecipe) -> Status {
    if !p_recipe return STATUS_FAILED;
    if entity_prototype_recipe_count >= ENTITY_LIBRARY_PROTOTYPE_RECIPE_CONTAINER_SIZE return STATUS_FAILED;

    // Sweep for existing entity prototype recipe
    for 0..entity_prototype_recipe_count-1 {
        if entity_prototype_recipe_container[it].name == p_recipe.*.name return STATUS_FAILED_ALREADY_EXISTS;
    }

    memcpy(*(entity_prototype_recipe_container[entity_prototype_recipe_count], p_recipe, size_of(EntityPrototypeRecipe)));
    entity_prototype_recipe_count += 1;

    print("Added EntityPrototypeRecipe: '%'\n",entity_prototype_recipe_container[entity_prototype_recipe_count-1].name);
    
    return STATUS_SUCCESS;
}

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
