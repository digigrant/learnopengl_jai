// stuff that is useful for working with OpenGL

PrintBufferData :: (target : GLenum) {
    ptr := glMapBuffer(target, GL_READ_ONLY);
    print("[ ");
    for 0..10 print("%1%2", ifx it > 0 ", " else "", (ptr+it).*);
    print(" ]\n");
    glUnmapBuffer(target);
}
