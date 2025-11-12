#import "Math";

DrawType :: enum u8 {
    NONE            :: 0;
    DRAW_ARRAYS;
    DRAW_ELEMENTS;
};

Mesh :: struct {
    name : string;
    vertexData : VertexData;
    indices : [] u32;
    textures : [] Texture;
    VAO, VBO, EBO : u32;
    drawType : DrawType;
    material : *Material;
};

// create a mesh. indices and textures are optional
CreateMesh :: (name : string, vertexData : VertexData, indices : [] u32 = .{}, textures : [] Texture = .{}, material : *Material = null) -> mesh : *Mesh {
    mesh := New(Mesh);
    if !mesh return null;

    mesh.name = name;
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
    glBindVertexArray(VAO);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, material.diffuse_texture.id);
    ShaderSetInt(shader, "diffuse", 0);

    if mesh.drawType == {
        case .DRAW_ARRAYS;      glDrawArrays(GL_TRIANGLES, 0, mesh.vertexData.floats.count.(u32));
        case .DRAW_ELEMENTS;    glDrawElements(GL_TRIANGLES, mesh.indices.count.(u32), GL_UNSIGNED_INT, null);
        case; print("No draw type for mesh\n");
    }
    glBindVertexArray(0);
}
