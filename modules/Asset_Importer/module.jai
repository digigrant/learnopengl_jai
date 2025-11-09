#import "Basic";
#import "File";
#import "String";
#import "Graphics";

Scene :: struct {

}

Object :: struct {
    name : string;
    material_name : string; // corresponds to a named material from the mtl file

    // 1. raw floats and vertex attributes (V/N/T) - treat everything as DRAW_ARRAYS
    // easy to assemble per object, it's in the format OpenGL likes
    // less flexible, no indices
    // this one seems to be better for "dont overthink it"

    // 2. floats and indices - treat everything as DRAW_ELEMENTS - assimp does this
    // more flexible
    // have to manage a registry of vertices, wont be any more efficient if there are no duplicates
    // would be good as a backup option

    using vertexData : VertexData;
}

OBJ_Command_Dictionary :: struct {
    entries : [..] OBJ_Command_Entry;
}

OBJ_Command_Entry :: struct {
    key : string;
    value : u64;
};

AddToObjCommandDictionary :: (using dictionary : OBJ_Command_Dictionary, keyToAdd : string) {
    isAlreadyInDictionary := false;
    for *current : entries if current.key == keyToAdd {
        current.value += 1;
        isAlreadyInDictionary = true;
        break;
    }

    if !isAlreadyInDictionary array_add(*entries, .{keyToAdd, 1});
}

ImportAsset :: (path : string) -> ok : bool {
    asset, ok := read_entire_file(path);
    if !ok {
        print("Unable to import asset: %\n", path);
        return false;
    }

    material_files : [..] string;
    objects : [..] Object;
    current_vertices : [..] Vector3;
    current_normals : [..] Vector3;
    current_tex_coords : [..] Vector3;

    // parse whole file
    cursor : int = 0;
    next_newline_index, last_index : int;
    line : string;
    words : [..] string;
    word_start : int = 0;

    dictionary : OBJ_Command_Dictionary;

    while cursor < asset.count { // 2000 is an arbitrary number, this will be the entire file

        // get line
        next_newline_index = find_index_from_left(asset, #char "\n", cursor);
        line = slice(asset, cursor, next_newline_index - cursor);

        // reset trackers
        array_reset(*words);
        word_start = 0;
        last_index = 0;
        
        // get words
        for char : line {
            if char == {
                case #char "#"; break;
                case #char " "; {
                    if it_index <= word_start continue;
                    array_add(*words, slice(line, word_start, it_index - word_start));
                    word_start = it_index + 1;
                }
            }
            last_index = it_index;
        }
        // get whatever the last word was
        if word_start < last_index array_add(*words, slice(line, word_start, last_index));

        // prepare cursor for next line
        cursor = next_newline_index + 1;

        // debug stuff for starting next line
        //print("%\n", words);
        if words.count < 1 continue;

        AddToObjCommandDictionary(dictionary, words[0]);

        // parse line
        if words[0] == {
            case "mtllib"; {
                assert(words.count == 2);   // ["mtllib", material_file]
                array_add(*material_files, words[1]);
            }
            case "usemtl"; {
                assert(words.count == 2);   // ["usemtl", material_name]
                objects[objects.count-1].material_name = words[1];
            }
            case "o"; { // start a new object
                assert(words.count == 2);   // ["o", object_name]

                // if we were working on an object, finish it
                if objects.count > 0 { /* finish current object */ }

                // create new object
                new_object := New(Object);
                new_object.name = words[1];
                new_object.attributes = .[.{3}, .{3}, .{2}];   // all vertices right now will be position, normal, texCoords
                array_add(*objects, new_object);
            }
            case "v"; { // put it in the vertex buffer to be processed later
                assert(words.count == 4 || words.count == 5);   // ["v", x, y, z, (w)]
                w : float = ifx words.count == 5 then string_to_float(words[4]) else 1.0;
                array_add(*current_vertices, .{ string_to_float(words[1])/w, string_to_float(words[2])/w, string_to_float(words[3])/w });
            }
            case "vt"; { // put it in vertex texture buffer to be processed later
                assert(words.count == 2 || words.count == 3);
                v : float = ifx words.count == 3 then string_to_float(words[2]) else 0.0;
                array_add(*current_tex_coords, .{ string_to_float(words[1], v)})
            }
            case "vn"; { // put it in vertex normal buffer to be processed later
                assert(words.count == 4);
                // by default these are not normalized...
                current_normal : Vector3 = .{ string_to_float(words[1]), string_to_float(words[2]), string_to_float(words[3]) };
                normalize(current_normal);
                array_add(*current_normals, current_normal);    // if it seems like a bad idea to normalize the normals before processing them, address it here
            }
            case "s"; // idk what we do with this
            case "f"; { //put it in the face buffer to be processed later
            }
            case; print("Unknown command encountered: %", words[0]);
        }        
    }

    print("%\n", dictionary.entries);
    print("%\n", material_files);
    print("%\n", objects);

    return true;
}
