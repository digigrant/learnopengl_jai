// stuff that is useful for working with OpenGL

PrintBufferData :: (target : GLenum) {
    ptr := glMapBuffer(target, GL_READ_ONLY);
    print("[ ");
    for 0..10 print("%1%2", ifx it > 0 ", " else "", (ptr+it).*);
    print(" ]\n");
    glUnmapBuffer(target);
}

PrintUniformFloat :: (shader : GLuint, name : string) {
    had_errors_before, num_errors_before, last_error_before := FlushErrors();

    value : float;
    glGetUniformfv(shader, glGetUniformLocation(shader, to_c_string(name)), *value);

    had_errors_after, num_errors_after, last_error_after := FlushErrors();
    print("Uniform %: %\n", name, value);
    if had_errors_before    print("\t(% errors detected before - last error before was %)\n", num_errors_before, last_error_before);
    if had_errors_after     print("\t(% errors detected after - last error after was %)\n", num_errors_after, last_error_after);
}

PrintUniformVec3 :: (shader : GLuint, name : string) {
    had_errors_before, num_errors_before, last_error_before := FlushErrors();

    value : Vector3;
    glGetUniformfv(shader, glGetUniformLocation(shader, to_c_string(name)), xx *(value.component));

    had_errors_after, num_errors_after, last_error_after := FlushErrors();
    print("Uniform %: %\n", name, value);
    if had_errors_before    print("\t(% errors detected before - last error before was %)\n", num_errors_before, last_error_before);
    if had_errors_after     print("\t(% errors detected after - last error after was %)\n", num_errors_after, last_error_after);
}

FlushErrors :: () -> has_errors : bool, num_errors : int, latest_error : int {
    has_errors : bool = false;
    num_errors : int = 0;
    current, latest_error : int = 0;

    GetError :: (current : *int) -> has_error : bool {
        current.* = glGetError();
        return current.* != 0;
    }

    while GetError(*current) {
        latest_error = current;
        num_errors += 1;
    }

    return num_errors > 0, num_errors, latest_error;
}
