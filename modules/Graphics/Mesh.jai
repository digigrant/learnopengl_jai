#import "Math";

DrawType :: enum u8 {
    NONE            :: 0;
    DRAW_ARRAYS;
    DRAW_ELEMENTS;
};

Mesh :: struct {
    vertexData : VertexData;
    indices : [] u32;
    textures : [] Texture;
    VAO, VBO, EBO : u32;
    drawType : DrawType;
    material : *Material;
};

// create a mesh. indices and textures are optional
CreateMesh :: (vertexData : VertexData, indices : [] u32 = .{ -1, null }, textures : [] Texture = .{ -1, null }, material : *Material = null) -> mesh : *Mesh {
    mesh := New(Mesh);
    if !mesh return null;

    mesh.vertexData = vertexData;
    mesh.indices = indices;
    mesh.textures = textures;
    mesh.drawType = ifx indices.data then .DRAW_ELEMENTS else .DRAW_ARRAYS;
    mesh.material = material;

    mesh.VAO, mesh.VBO = CreateVertexObjects(vertexData);

    return mesh;
}

FreeMesh :: (mesh : **Mesh) {
    if !mesh || !(mesh.*) return;
    free(mesh.*);
    (mesh.*) = null;
}

DrawMesh :: (using mesh : *Mesh, shader : u32) {
    /*
    typeCounts : [#run enum_names(TextureType).count] u8;
    name, number : string;
    for texture : textures {
        glActiveTexture(GL_TEXTURE0 + it_index.(u32));
        name = enum_names(TextureType)[texture.type];
        number = sprint("%", typeCounts[texture.type]);

        ShaderSetInt(shader, sprint("material.%0%1", name, number), texture.id.(s32));
        glBindTexture(GL_TEXTURE_2D, texture.id);
    }
    */
    glActiveTexture(GL_TEXTURE0);
    ShaderSetInt(shader, "diffuse", material.diffuse_texture.id.(s32));
    glBindTexture(GL_TEXTURE_2D, material.diffuse_texture.id);

    glBindVertexArray(VAO);
    if mesh.drawType == {
        case .DRAW_ARRAYS;      glDrawArrays(GL_TRIANGLES, 0, mesh.vertexData.floats.count.(u32));
        case .DRAW_ELEMENTS;    glDrawElements(GL_TRIANGLES, mesh.indices.count.(u32), GL_UNSIGNED_INT, null);
        case; print("No draw type for mesh\n");
    }
    glBindVertexArray(0);
}
