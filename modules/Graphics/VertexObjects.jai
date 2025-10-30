#import "GL";

VertexAttribute :: struct {
    // so far this only has one property, but we could imagine it having more,
    // like data type or isNormalized
    size : u8; // must be 1-4
};

CreateVertexObjects :: (vertices : [] float, attributes : [] VertexAttribute) -> VAO : u32, VBO : u32 {
    VAO, VBO : u32;

    glGenVertexArrays(1, *VAO);
    glGenBuffers(1, *VBO);

    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);

    // load vertex data into buffer
    // may want to add usage type as an argument but for right now we only use GL_STATIC_DRAW
    glBufferData(GL_ARRAY_BUFFER, vertices.count * size_of(float), vertices.data, GL_STATIC_DRAW);
    
    // configure vertex attributes
    strideLength : u32 = 0;
    for attribute : attributes strideLength += attribute.size;
    currentStart := 0;
    for attribute, index : attributes {
        glEnableVertexAttribArray(xx index);
        glVertexAttribPointer(xx index, attribute.size, GL_FLOAT, GL_FALSE, strideLength * size_of(float), cast(*void) (currentStart * size_of(float)));
        currentStart += attribute.size;
    }

    glBindVertexArray(0);
    return VAO, VBO;
}
