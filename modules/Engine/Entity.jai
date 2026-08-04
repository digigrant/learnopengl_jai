ENTITY_MAX_CHILDREN :: 8;

Entity :: struct {
    data : *EntityData;
    children : [ENTITY_MAX_CHILDREN] *Entity;
    num_children : int;
    parent : *Entity;
    transform : Transform;
};

EntityData :: struct {
    name : string;
    prototype_name : string;
    starting_transform : Transform;
};

AddChildToParentEntity :: (parent : *Entity, child : *Entity) -> ok : bool {
    using,except(parent) parent.*;

    if num_children >= ENTITY_MAX_CHILDREN return false;

    children[num_children] = child;
    num_children += 1;

    child.parent = parent;

    return true;
}

UpdateEntityAndChildren :: (entity : *Entity) {
    using entity.*;

    // We assume parent entity is already clean, i.e. top-down approach
    // If child entities can modify parent then this needs to be changed
    if transform.is_dirty {
        CalculateTransformModelMatrix(*transform);
        if parent { transform.model = parent.transform.model * transform.model; }
    }

    for i : 0..num_children-1 UpdateEntityAndChildren(children[0] + i);
}

/*
CreateEntityFromData :: (data : *EntityData) -> Status {
    if !data return STATUS_FAILED;

    using data.*;
    entity_prototype := FindEntityPrototype(name);
}
*/
