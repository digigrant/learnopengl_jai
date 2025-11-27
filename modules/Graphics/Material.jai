Material :: struct {
    name : string;

    ambient_color : Vector3;
    diffuse_color : Vector3;
    specular_color : Vector3;
    shininess : float;

    /*
    transparency : float;   // [0,1]; could also be 'dissolve', which is inverted 
    transmission_filter_color : Vector3;
    refraction_index : float;   // [0.001, 10.0]; values below 1.0 behave oddly
    */

    // illumination_model : IlluminationModel;

    diffuse_texture : *Texture;
    // normal_texture_name : string;
    specular_texture : *Texture;

    // PBR
    // emissive_color : Vector3;

    // there can be other things too but I dont really care about those for now
};

CreateMaterial :: (name : string, diffuse_texture_path : string = .{}) -> material : *Material {
    material := New(Material);
    if !material return null;
    
    material.name = name;

    if diffuse_texture_path.data {
        material.diffuse_texture = BuildFromTextureLibrary(diffuse_texture_path, .DIFFUSE);
    }

    return material;
}

CreateMaterialfromMtlData :: (mtl_data : *MtlData) -> material : *Material {
    material := New(Material);
    {
        using material.*;
        name = mtl_data.name;
        ambient_color = mtl_data.ambient_color;
        diffuse_color = mtl_data.diffuse_color;
        specular_color = mtl_data.specular_color;
        shininess = mtl_data.shininess;
        if mtl_data.diffuse_texture_path != "" {
            diffuse_texture = BuildFromTextureLibrary(mtl_data.diffuse_texture_path, .DIFFUSE);   // @TODO Implement texture library
        }
        if mtl_data.specular_texture_path != "" {
            specular_texture = BuildFromTextureLibrary(mtl_data.specular_texture_path, .SPECULAR);
        }
    }

    return material;
}

FreeMaterial :: (material : **Material) {
    if !material || !(material.*) return;
    free(material.*);
    (material.*) = null;
}