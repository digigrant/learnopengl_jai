ENTITY_MAX_CHILDREN :: 8;

Entity :: struct {
    children : [ENTITY_MAX_CHILDREN] *Entity;
    num_children : int;
    parent : *Entity;
    transform : Transform;
};

AddChildToParentEntity :: (parent : *Entity, child : *Entity) {
    using,except(parent) parent.*;
    if num_children >= ENTITY_MAX_CHILDREN {
        print("Max children reached.\n");
        return;
    }

    children[num_children] = child;
    num_children += 1;

    child.parent = parent;
}

UpdateEntityAndChildren :: (entity : *Entity) {
    using entity.*;

    if transform.is_dirty {
        if parent {
            CalculateTransformModelMatrix(*transform, parent.transform.model);
        } else {
            CalculateTransformModelMatrix(*transform);   
        }

        for i : 0..num_children-1 CalculateTransformModelMatrix(*(children[i].transform), transform.model);
        return;
    }

    for i : 0..num_children-1 UpdateEntityAndChildren(children[0] + i);
}
