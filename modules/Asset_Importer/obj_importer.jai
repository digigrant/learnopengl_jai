#import "Basic";
#import "File";
#import "String";
#import "Graphics";
#import "Math";

ObjData :: struct {
    objects : [] *Object;
    material_files : [] string;
};

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
};

#scope_file

VertexEntries :: struct {
    position_index, normal_index, texcoord_index : int;
};

OBJ_Command_Dictionary :: struct {
    entries : [..] OBJ_Command_Entry;
}

OBJ_Command_Entry :: struct {
    key : string;
    value : u64;
};

#scope_export

ImportDataFromObj :: (path : string) -> ok : bool, data : *ObjData {
    asset, ok := read_entire_file(path);
    if !ok {
        print("Unable to import asset: %\n", path);
        return false, null;
    }

    data : *ObjData = New(ObjData);

    material_files : [..] string;
    objects : [..] *Object;
    all_positions : [..] Vector3;
    all_normals : [..] Vector3;
    all_tex_coords : [..] Vector2;
    object_vertices : [..] VertexEntries;

    // V/N/T entries are 1-based in OBJ. We just add an empty entry in the 0 slot. No biggie
    array_add(*all_positions, .{ 0.0, 0.0, 0.0 });
    array_add(*all_normals, .{ 0.0, 0.0, 0.0 });
    array_add(*all_tex_coords, .{ 0.0, 0.0 });

    // ultimately we want a giant array of floats for each object, which can be fed directly into the vertex buffer.
    // we get this array of floats using the face ("f") entries in the OBJ, which correspond to indices of V/T/N entries that were previously entered
    // (we also need to read material data for each material, but this can be done separately)

    // parse whole file
    cursor : int = 0;
    words : [] string;

    dictionary : OBJ_Command_Dictionary;

    while cursor < asset.count { // 2000 is an arbitrary number, this will be the entire file

        words = ParseLineForWords(asset, *cursor);

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
                if objects.count > 0 {
                    ProcessObjectVertices(objects[objects.count - 1], object_vertices, all_positions, all_normals, all_tex_coords);
                    array_reset(*object_vertices);
                }

                // create new object
                new_object := New(Object);
                new_object.name = words[1];
                new_object.attributes = .[.{3}, .{3}, .{2}];   // all vertices right now will be position, normal, texCoords
                array_add(*objects, new_object);
            }
            case "v"; { // put it in the vertex buffer to be processed later
                assert(words.count == 4 || words.count == 5);   // ["v", x, y, z, (w)]
                w : float = ifx words.count == 5 then string_to_float(words[4]) else 1.0;
                array_add(*all_positions, .{ string_to_float(words[1])/w, string_to_float(words[2])/w, string_to_float(words[3])/w });
            }
            case "vt"; { // put it in vertex texture buffer to be processed later
                assert(words.count == 2 || words.count == 3);
                v : float = ifx words.count == 3 then string_to_float(words[2]) else 0.0;
                array_add(*all_tex_coords, .{ string_to_float(words[1]), v });
            }
            case "vn"; { // put it in vertex normal buffer to be processed later
                assert(words.count == 4);
                // by default these are not normalized...
                current_normal : Vector3 = .{ string_to_float(words[1]), string_to_float(words[2]), string_to_float(words[3]) };
                normalize(current_normal);
                array_add(*all_normals, current_normal);    // if it seems like a bad idea to normalize the normals before processing them, address it here
            }
            case "s"; // idk what we do with this
            case "f"; { //put it in the face buffer to be processed later
                assert(words.count == 4);
                // individual words will definitely have v, and may optionally also have t and n
                // any missing components should get a value of 0
                // remember negative values are allowed - indexing from the back

                for 1..3 {  // add 3 object vertices for the face 
                    p, t, n : int;
                    /* Fuck this
                    v_end, t_end : int;
                    v_end = find_index_from_left(words[it], #char "/");
                    v = string_to_int(ifx v_end > -1 then slice(words[it], 0, v_end) else words[it]);
                    if v_end > -1 {
                        t_end = find_index_from_left(words[it], #char "/", v_end + 1);
                        has_t : bool = (t_end - v_end) != 1;    // ----> "//"
                        t = ifx has_t
                            then string_to_int(ifx t_end > -1
                                then slice(words[it], v_end + 1, t_end - v_end)
                                else slice(words[it], v_end + 1, words[it].count - v_end))
                            else 0;
                        if (t_end > -1) {

                        }
                    }
                    */

                    components := split(words[it], "/");
                    p = string_to_int(components[0]);
                    t = ifx components.count > 1 && components[1].count > 0 then string_to_int(components[1]) else 0;
                    n = ifx components.count > 2 then string_to_int(components[2]) else 0;
                    array_add(*object_vertices, .{ p, n, t });  // V3 V3 V2
                }
            }
            case; print("Unknown command encountered: %", words[0]);
        }        
    }

    // Process last object - when we reached the end of the file
    ProcessObjectVertices(objects[objects.count - 1], object_vertices, all_positions, all_normals, all_tex_coords);

    data.objects = objects;
    data.material_files = material_files;
    return true, data;
}

PrintObjData :: (data : *ObjData) {
    for object : data.objects {
        print("{%, %,\n", object.name, object.material_name);
        for vertex_index : 0..4 {
            print("\t");
            for float_index : 0..7 print("% ", object.floats[vertex_index * 8 + float_index]);
            print("\n");
        }
        print("...\n%\n\n", object.attributes);
    }
}

#scope_file;

ProcessObjectVertices :: (current_object : *Object, object_vertices : [] VertexEntries, positions : [] Vector3, normals : [] Vector3, texcoords : [] Vector2) {
    // current_object := objects[objects.count - 1];
    // allocate a massive array of floats for this object's vertex data. awooooga
    new_floats : [..] float;
    array_resize(*new_floats, object_vertices.count * 8, false); // no init

    // feed the float data into the array
    for vertex : object_vertices {
        //if it_index < 3 print("Processing: %\n", vertex);
        base_index := it_index * 8;
        // vertex data
        new_floats[base_index + 0] = positions[vertex.position_index].x;
        new_floats[base_index + 1] = positions[vertex.position_index].y;
        new_floats[base_index + 2] = positions[vertex.position_index].z;

        // normal data - optional, default is 0.0
        new_floats[base_index + 3] = ifx vertex.normal_index != 0 then normals[vertex.normal_index].x else 0.0;
        new_floats[base_index + 4] = ifx vertex.normal_index != 0 then normals[vertex.normal_index].y else 0.0;
        new_floats[base_index + 5] = ifx vertex.normal_index != 0 then normals[vertex.normal_index].z else 0.0;

        // texcoord data - optional, default is 0.0
        new_floats[base_index + 6] = ifx vertex.texcoord_index != 0 then texcoords[vertex.texcoord_index].x else 0.0;
        new_floats[base_index + 7] = ifx vertex.texcoord_index != 0 then 1.0 - texcoords[vertex.texcoord_index].y else 0.0; // V IS FLIPPED??? THAT WOULDVE BEEN GOOD TO KNOW
        /*
        if it_index < 3 {
            print("Added floats: ");
            base := it_index * 8;
            for 0..8 print("% ", new_floats[base + it]);
            print("\n");
        }
        */
    }
    current_object.floats = new_floats;
}



AddToObjCommandDictionary :: (using dictionary : OBJ_Command_Dictionary, keyToAdd : string) {
    isAlreadyInDictionary := false;
    for *current : entries if current.key == keyToAdd {
        current.value += 1;
        isAlreadyInDictionary = true;
        break;
    }

    if !isAlreadyInDictionary array_add(*entries, .{keyToAdd, 1});
}
