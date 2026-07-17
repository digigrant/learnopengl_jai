MAX_ENTITIES : int : 100;

Scene :: struct {
    SceneLoad :     *() -> bool = null;
    SceneInit :     *() -> bool = null;
    SceneUpdate :   *() -> bool = null;
    SceneRender :   *() -> bool = null;
    SceneUnload :   *() -> bool = null;
    
    entities :      [MAX_ENTITIES] Entity;
    root_entity :   *Entity;
};
