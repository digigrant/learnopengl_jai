KEYWORD_NEW_SHADER  :: "#shader";
KEYWORD_VERTEX      :: "vertex";
KEYWORD_FRAGMENT    :: "fragment";
KEYWORD_GEOMETRY    :: "geometry";

ReadShadersFromFile :: (path : string) -> ok : bool {
    file, ok := read_entire_file(path);
    if !ok {
        print("Unable to read file: %\n", path);
        return false;
    }

    // need big pool of memory for shader code,
    // probably in the shader library

    vertex_shaders : [..] string;
    fragment_shaders : [..] string;
    geometry_shaders : [..] string;

    cursor := 0;
    line_end := 0;
    shader_code_start := 0;
    shader_code_end := 0;
    done := false;
    list_to_append_to : *[..] string;
    type : string;

    // consume first new shader keyword
    assert(VerifyKeywordNewShader(file, cursor, read_first_char=true));
    cursor += KEYWORD_NEW_SHADER.count + 1;

    while !done {
        // read next shader tag
        line_end = find_index_from_left(file, #char "\n", cursor);
        type = slice(file, cursor, line_end - cursor);
        if type == {
            case KEYWORD_VERTEX;    list_to_append_to = *vertex_shaders;
            case KEYWORD_GEOMETRY;  list_to_append_to = *geometry_shaders;
            case KEYWORD_FRAGMENT;  list_to_append_to = *fragment_shaders;
        }
        cursor = line_end + 1;
        // cursor is on starting line of shader code
        
        shader_code_start = cursor;
        shader_code_end = -1;
        while true {
            cursor = find_index_from_left(file, #char "#", cursor);
            if cursor == -1 {
                shader_code_end, cursor = file.count;
                done = true;
                break;
            }
            if VerifyKeywordNewShader(file, cursor) {
                shader_code_end = cursor;
                cursor += KEYWORD_NEW_SHADER.count + 1;
                break;
            }
            // otherwise ignore and continue
            cursor += 1;
        }
        // cursor is either at EOF or after new shader keyword

        new_string := alloc(shader_code_end - shader_code_start);
        memcpy(new_string, file.data + shader_code_start, shader_code_end - shader_code_start);
        array_add(list_to_append_to, .{count = shader_code_end - shader_code_start, data = new_string});
    }

    print("vertex_shaders: %\n\n", vertex_shaders);
    print("geometry_shaders: %\n\n", geometry_shaders);
    print("fragment_shaders: %\n\n", fragment_shaders);

    for vertex_shaders free(it.data);
    for fragment_shaders free(it.data);
    for geometry_shaders free(it.data);

    return true;
}

VerifyKeywordNewShader :: (file : string, cursor : int, $read_first_char : bool = false) -> bool {
    START :: #ifx read_first_char 0 else 1;
    // compare text in front of cursor to KEYWORD_NEW_SHADER + " "
    for START..KEYWORD_NEW_SHADER.count if file[cursor+it] != ifx it < KEYWORD_NEW_SHADER.count then KEYWORD_NEW_SHADER[it] else #char " " return false;
    return true;
}
