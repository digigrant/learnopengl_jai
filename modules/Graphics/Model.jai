#import "String";
#import "Asset_Importer";

Model :: struct {
    meshes : [..] *Mesh;
    directory : string;
};

CreateModel :: (path : string) -> model : *Model {
    obj_ok, obj_data := ImportDataFromObj("models/backpack/backpack.obj");
    if !obj_ok {
        print("Model: could not load '%'\n", path);
        return null;
    }

    model := New(Model);
    model.directory = slice(path, 0, find_index_from_right(path, "/"));

    materials : [..] *MtlData; // @TODO we should probably have a material library
    mtl_ok : bool;
    mtl_data : [] *MtlData;
    for filename : obj_data.material_files {
        mtl_ok, mtl_data = ImportDataFromMtl(join(model.directory, "/", filename));
        if !mtl_ok {
            print("Model: could not read material file '%'\n", filename);
            continue;
        }

        old_count := materials.count;
        array_resize(*materials, materials.count + mtl_data.count);
        for mtl_data materials[old_count + it_index] = it;
    }

    // add meshes
    array_resize(*(model.meshes), obj_data.objects.count);
    for object : obj_data.objects {
        new_material : *Material = null;    // @TODO we should really really have a Material library
        for mtl : materials if object.material_name == mtl.name {
            new_material = CreateMaterialfromMtlData(mtl);
        }
        model.meshes[it_index] = CreateMesh(object.vertexData, material=new_material);
    }

    return model;
}

DrawModel :: (model : *Model, shader : u32) {
    for model.meshes DrawMesh(it, shader);
}

FreeModel :: (model : **Model) {
    if !model || !(model.*) return;

    for model.*.meshes FreeMesh(*it);
    free(model.*);
    (model.*) = null;
    return;
}
