#import "Basic";
#import "GL";
#import "stb_image";

Texture :: struct {
    path : string;
    id : u32;
    type : TextureType;
};

TextureType :: enum {
    NONE :: 0;
    TEXTURE_TYPE_DIFFUSE;
    TEXTURE_TYPE_SPECULAR;
};

CreateTexture :: (texture_path : string, texture_type : TextureType) -> texture : *Texture {
    stbi_set_flip_vertically_on_load(1);
    width, height, nrChannels : s32;
    data := stbi_load(to_c_string(texture_path), *width, *height, *nrChannels, 0);
    if data == null {
        print("Failed to load texture: %\n", texture_path);
        return null;
    }

    texture : *Texture = New(Texture);
    using texture;
    path = texture_path;
    type = texture_type;
    glGenTextures(1, *id);

    format : GLenum;
    if nrChannels == {
        case 1; format = GL_RED;
        case 3; format = GL_RGB;
        case 4; format = GL_RGBA;
    }

    glBindTexture(GL_TEXTURE_2D, id);
    glTexImage2D(GL_TEXTURE_2D, 0, xx format, width.(u32), height.(u32), 0, format, GL_UNSIGNED_BYTE, data);
    glGenerateMipmap(GL_TEXTURE_2D);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,
        ifx format == GL_RGBA then GL_CLAMP_TO_EDGE.(GLint) else GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
        ifx format == GL_RGBA then GL_CLAMP_TO_EDGE.(GLint) else GL_REPEAT);

    stbi_image_free(data);
    return texture;
}

FreeTexture :: (texture : **Texture) {
    if !texture || !(texture.*) return;
    free(texture.*);
    (texture.*) = null;
}
