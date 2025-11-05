#import "Math";

DrawType :: enum u8 {
    NONE            :: 0;
    DRAW_TRIANGLES;
    DRAW_ELEMENTS;
};

Mesh :: struct {
    vertexData : VertexData;
    indices : [] u32;
    textures : [] Texture;
    VAO, VBO, EBO : u32;
    drawType : DrawType;
};

// create a mesh. indices and textures are optional
CreateMesh :: (vertexData : VertexData, indices : [] u32 = .{ -1, null }, textures : [] Texture = .{ -1, null }) -> mesh : *Mesh {
    mesh := New(Mesh);
    if !mesh return null;

    mesh.vertexData = vertexData;
    mesh.indices = indices;
    mesh.textures = textures;
    mesh.VAO, mesh.VBO = CreateVertexObjects(vertexData);
    mesh.drawType = ifx indices.data then .DRAW_ELEMENTS else .DRAW_TRIANGLES;

    return mesh;
}