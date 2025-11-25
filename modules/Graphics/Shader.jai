#import "Basic";
#import "GL";
#import "Math";

STRING_BUFFER_LENGTH :: 512;

// Compiles shaders and creates shader program
CreateShader :: (vertexShaderCode : string, fragmentShaderCode : string, geometryShaderCode : string = "") -> shaderId : u32 {
    success : s32;
    string_buffer := alloc_string(STRING_BUFFER_LENGTH,, temp);

    vertexShader := glCreateShader(GL_VERTEX_SHADER);
    // glShaderSource takes an array of strings and an array of string lengths
    // for its last two arguments. Last one can be null, interestingly enough.
    // Could have multiple elements fwiw.
    glShaderSource(vertexShader, 1, *(to_c_string(vertexShaderCode)), null);
    glCompileShader(vertexShader);
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, *success);
    if !success {
        glGetShaderInfoLog(vertexShader, STRING_BUFFER_LENGTH, null, string_buffer.data);
        print("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n%\n", string_buffer);
    }

    geometryShader : GLuint;
    if geometryShaderCode != "" {
        geometryShader = glCreateShader(GL_GEOMETRY_SHADER);
        glShaderSource(geometryShader, 1, *(to_c_string(geometryShaderCode)), null);
        glCompileShader(geometryShader);
        glGetShaderiv(geometryShader, GL_COMPILE_STATUS, *success);
        if !success {
            glGetShaderInfoLog(geometryShader, STRING_BUFFER_LENGTH, null, string_buffer.data);
            print("ERROR::SHADER::GEOMETRY::COMPILATION_FAILED\n%\n", string_buffer);
        }
    }

    fragmentShader := glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, *(to_c_string(fragmentShaderCode)), null);
    glCompileShader(fragmentShader);
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, *success);
    if !success {
        glGetShaderInfoLog(fragmentShader, STRING_BUFFER_LENGTH, null, string_buffer.data);
        print("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n%\n", string_buffer);
    }

    shader := glCreateProgram();
    glAttachShader(shader, vertexShader);
    if geometryShaderCode != "" glAttachShader(shader, geometryShader);
    glAttachShader(shader, fragmentShader);
    glLinkProgram(shader);
    glGetProgramiv(shader, GL_LINK_STATUS, *success);
    if !success {
        glGetProgramInfoLog(shader, STRING_BUFFER_LENGTH, null, string_buffer.data);
        print("ERROR::SHADER::PROGRAM::LINKING_FAILED\n%\n", string_buffer);
    }

    // set any uniform buffer bindings
    // @TODO: upgrade OpenGL to 4.3+ and use GetProgramResource instead
    block_count: GLint;
    glGetProgramiv(shader, GL_ACTIVE_UNIFORM_BLOCKS, *block_count);
    for 0..block_count-1 {
        glGetActiveUniformBlockName(shader, xx it, STRING_BUFFER_LENGTH, null, string_buffer.data);
        binding := LookupUniformBufferBinding(to_string(xx string_buffer));
        if binding > -1 {
            glUniformBlockBinding(shader, xx it, binding.(u32));
        } else {
            print("Uniform block '%' could not be bound because it was not found in the registry.\n", string_buffer);
        }
    }

    // cleanup
    glDeleteShader(vertexShader);
    glDeleteShader(geometryShader);
    glDeleteShader(fragmentShader);

    // right now we just return the raw u32.
    // In the old system we allocated a Shader object and returned the pointer to
    // that, but it only had the ID in it, so I dont see a huge reason to do that.
    return shader;
}

ShaderSetInt :: (shaderId : u32, name : string, value : GLint) {
    glUniform1i(glGetUniformLocation(shaderId, to_c_string(name)), value);
}

ShaderSetFloat :: (shaderId : u32, name : string, value : float) {
    glUniform1f(glGetUniformLocation(shaderId, to_c_string(name)), value);
}

ShaderSetVec3 :: (shaderId : u32, name : string, vec3 : *Vector3) {
    glUniform3fv(glGetUniformLocation(shaderId, to_c_string(name)), 1, vec3.component.data);
}

ShaderSetMat4 :: (shaderId : u32, name : string, mat4 : *Matrix4) {
    glUniformMatrix4fv(glGetUniformLocation(shaderId, to_c_string(name)), 1, GL_TRUE, mat4.floats.data);
}
