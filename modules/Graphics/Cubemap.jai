#import "GL";
#import "stb_image";

Cubemap :: struct {
    paths : [6] string;
    id : u32;
};

CreateCubemap :: (faces : *[6] string) -> cubemap : *Cubemap {
    cubemap := New(Cubemap);
    glGenTextures(1, *(cubemap.id));
    glBindTexture(GL_TEXTURE_CUBE_MAP, cubemap.id);

    stbi_set_flip_vertically_on_load(1);

    width, height, nr_channels : s32;
    for path : faces.* {
        data := stbi_load(to_c_string(path), *width, *height, *nr_channels, 0);
        defer stbi_image_free(data);

        if !data {
            print("Cubemap tex failed to load at path: %\n", path);
            continue;
        }

        glTexImage2D(xx (GL_TEXTURE_CUBE_MAP_POSITIVE_X + it_index),
            0, GL_RGB, width.(u32), height.(u32), 0, GL_RGB, GL_UNSIGNED_BYTE, data
        );
        cubemap.paths[it_index] = path;
    }

    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

    return cubemap;
}
