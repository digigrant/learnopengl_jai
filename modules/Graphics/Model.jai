Model :: struct {
    meshes : [] *Mesh;
    directory : string;
};

CreateModel :: (path : string) -> model : *Model {

}

DrawModel :: (using model : *Model, shader : *Shader) {
    for meshes DrawMesh(it, shader);
}
