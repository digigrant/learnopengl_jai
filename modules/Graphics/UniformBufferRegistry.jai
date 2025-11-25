// The way we're managing our uniform buffers here is:
// - easy lookup for uniform buffer indices
// - easy updating uniform buffer data

// for readability it helps to have these next to each other
// this could be read from a file if it would help organize the data better
UniformBufferData :: struct {
    name : string;
    size : GLuint;
};

// the binding point will always be the same index as the name in this array
// so it is written!
UNIFORM_BUFFER_NAMES_AND_SIZES : [1] UniformBufferData : .[
    .{ "Matrices", size_of(Matrix4) * 2 },
];
//

// this really just stores the buffer objects to be freed later
uniform_buffers : [UNIFORM_BUFFER_NAMES_AND_SIZES.count] GLuint;

#scope_module

InitUniformBufferRegistry :: () {
    for * current, index : uniform_buffers {
        glGenBuffers(1, current);
        glBindBuffer(GL_UNIFORM_BUFFER, current.*);
        glBufferData(GL_UNIFORM_BUFFER, UNIFORM_BUFFER_NAMES_AND_SIZES[index].size, null, GL_STATIC_DRAW);
        glBindBuffer(GL_UNIFORM_BUFFER, 0);
        glBindBufferBase(GL_UNIFORM_BUFFER, xx index, current.*);
    }
}

LookupUniformBufferBinding :: (name : string) -> binding : int {
    for UNIFORM_BUFFER_NAMES_AND_SIZES if it.name == name return it_index;
    // didnt find it
    print("Uniform buffer '%' was not found in the registry.\n", name);
    return -1;
}

#scope_export

// this only sets one thing
// if we want to set multiple things, put it into one data buffer before feeding it in here
SetUniformBufferData :: (name : string, size : int, data : *void, offset : int = 0) {
    binding := LookupUniformBufferBinding(name);
    glBindBuffer(GL_UNIFORM_BUFFER, uniform_buffers[binding]);
    glBufferSubData(GL_UNIFORM_BUFFER, offset, size, data);
    glBindBuffer(GL_UNIFORM_BUFFER, 0);

}
