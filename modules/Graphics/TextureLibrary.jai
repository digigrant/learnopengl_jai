#scope_file

TEXTURE_LIBRARY_SIZE :: 10;
TEXTURE_LIBRARY_COUNT_TYPE :: u8;

TextureLibrary :: struct {
    diffuse_list : [TEXTURE_LIBRARY_SIZE] *Texture;    // should these be resizable, considering reallocating the array? Not sure what makes sense
    specular_list : [TEXTURE_LIBRARY_SIZE] *Texture;
    diffuse_count, specular_count : TEXTURE_LIBRARY_COUNT_TYPE;
};

texture_library : TextureLibrary;

#scope_export

InitTextureLibrary :: () {
    using texture_library;

    for diffuse_list it = null;
    for diffuse_list it = null;
    diffuse_count, specular_count = 0;

    print("Init. texture library count: %\n", diffuse_list.count);
}

BuildFromTextureLibrary :: (path : string, texture_type : TextureType) -> texture : *Texture {
    assert(path != "");
    using texture_library;
    
    texture := FindFromTextureLibrary(path, texture_type);
    if !texture {
        print("Creating texture: '%'\n", path);
        texture = CreateTexture(path, texture_type);
        AddToTextureLibrary(texture);
    }

    return texture;
}

FreeEntireTextureLibrary :: () {
    using texture_library;

    for diffuse_list FreeTexture(*it);
    for specular_list FreeTexture(*it);
}

#scope_file

FindFromTextureLibrary :: (path : string, texture_type : TextureType) -> texture : *Texture {
    assert(path != "");
    assert(array_find(enum_values_as_enum(TextureType), texture_type));
    using texture_library;

    list : [] *Texture;
    count : TEXTURE_LIBRARY_COUNT_TYPE;

    if texture_type == {
        case .DIFFUSE; {
            list = diffuse_list;
            count = diffuse_count;
        }
        case .SPECULAR; {
            list = specular_list;
            count = specular_count;
        }
        case; print("No texture library list for type: %\n", texture_type);
    }

    if count == 0 return null;
    // if we find the texture return it, otherwise return null
    for 0..count-1 {
        texture := list[it];
        if TextureHasPath(texture, path) return texture;
    }
    return null;
}

AddToTextureLibrary :: (texture : *Texture) {
    using texture_library;

    if texture.type == {
        case .DIFFUSE; {
            diffuse_list[diffuse_count] = texture;
            diffuse_count += 1;
        }
        case .SPECULAR; {
            specular_list[specular_count] = texture;
            specular_count += 1;
        }
        case; print("No texture library list for type: %\n", texture.type);
    }
}

