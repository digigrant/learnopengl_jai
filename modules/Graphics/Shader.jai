#import "Basic";
#import "GL";
#import "Math";

MAX_INFO_LOG_LENGTH :: 512;

// Compiles shaders and creates shader program
CreateShader :: (vertexShaderCode : string, fragmentShaderCode : string) -> shaderId : u32 {
    success : s32;
    infoLog : string;

    vertexShader := glCreateShader(GL_VERTEX_SHADER);
    // glShaderSource takes an array of strings and an array of string lengths
    // for its last two arguments. Last one can be null, interestingly enough.
    // Could have multiple elements fwiw.
    glShaderSource(vertexShader, 1, *(to_c_string(vertexShaderCode)), null);
    glCompileShader(vertexShader);
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, *success);
    if !success {
        glGetShaderInfoLog(vertexShader, MAX_INFO_LOG_LENGTH, null, to_c_string(infoLog));
        print("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n%\n", infoLog);
    }

    fragmentShader := glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, *(to_c_string(fragmentShaderCode)), null);
    glCompileShader(fragmentShader);
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, *success);
    if !success {
        glGetShaderInfoLog(fragmentShader, MAX_INFO_LOG_LENGTH, null, to_c_string(infoLog));
        print("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n%\n", infoLog);
    }

    shader := glCreateProgram();
    glAttachShader(shader, vertexShader);
    glAttachShader(shader, fragmentShader);
    glLinkProgram(shader);
    glGetProgramiv(shader, GL_LINK_STATUS, *success);
    if !success {
        glGetProgramInfoLog(shader, 512, null, to_c_string(infoLog));
        print("ERROR::SHADER::PROGRAM::LINKING_FAILED\n%\n", infoLog);
    }

    // cleanup
    glDeleteShader(vertexShader);
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
