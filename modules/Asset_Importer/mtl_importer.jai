MtlData :: struct {
    name : string;

    ambient_color : Vector3;
    diffuse_color : Vector3;
    specular_color : Vector3;
    shininess : float;

    transparency : float;   // [0,1]; could also be 'dissolve', which is inverted 
    transmission_filter_color : Vector3;
    refraction_index : float;   // [0.001, 10.0]; values below 1.0 behave oddly

    illumination_model : IlluminationModel;

    diffuse_texture_path : string;
    normal_texture_path : string;
    specular_texture_path : string;

    // PBR
    emissive_color : Vector3;

    // there can be other things too but I dont really care about those for now
};

IlluminationModel :: enum u8 {
    COLOR_ON_AMBIENT_OFF                                        :: 0;
    COLOR_ON_AMBIENT_ON                                         :: 1;
    HIGHLIGHT_ON                                                :: 2;
    REFLECTION_ON_RAY_TRACE_ON                                  :: 3;
    TRANSPARENCY_GLASS_ON_REFLECTION_RAY_TRACE_ON               :: 4;
    REFLECTION_FRESNEL_RAY_TRACE_ON                             :: 5;
    TRANSPARENCY_REFRACTION_ON_REFLECTION_RAY_TRACE_ON          :: 6;
    TRANSPARENCY_REFRACTION_ON_REFLECTION_FRESNEL_RAY_TRACE_ON  :: 7;
    REFLECTION_ON_RAY_TRACE_OFF                                 :: 8;
    TRANSPARENCY_GLASS_ON_REFLECTION_RAY_TRACE_OFF              :: 9;
    CAST_SHADOWS_ON_INVISIBLE_SURFACES                          :: 10;
};

ImportDataFromMtl :: (path : string) -> ok : bool, data : [] *MtlData {
    asset, ok := read_entire_file(path);
    if !ok {
        print("Unable to import asset: %\n", path);
        return false, .{};
    }

    data : [..] *MtlData;
    current_material : *MtlData;
    directory : string = slice(path, 0, find_index_from_right(path, "/") + 1);

    cursor := 0;
    words : [] string;

    while cursor < asset.count {
        words = ParseLineForWords(asset, *cursor);
        if words.count < 1 continue;

        if words[0] == {
            case "newmtl"; {
                assert(words.count == 2);
                array_add(*data, New(MtlData));
                current_material = data[data.count-1];
                current_material.name = words[1];
            }
            case "Ka"; {
                assert(words.count == 4);
                current_material.ambient_color = .{ 
                    string_to_float(words[1]),
                    string_to_float(words[2]),
                    string_to_float(words[3])
                };
            }
            case "Kd"; {
                assert(words.count == 4);
                current_material.diffuse_color = .{ 
                    string_to_float(words[1]),
                    string_to_float(words[2]),
                    string_to_float(words[3])
                };
            }
            case "Ks"; {
                assert(words.count == 4);
                current_material.specular_color = .{ 
                    string_to_float(words[1]),
                    string_to_float(words[2]),
                    string_to_float(words[3])
                };
            }
            case "Ke"; {
                assert(words.count == 4);
                current_material.emissive_color = .{ 
                    string_to_float(words[1]),
                    string_to_float(words[2]),
                    string_to_float(words[3])
                };
            }
            case "Ns"; {
                assert(words.count == 2);
                current_material.shininess = string_to_float(words[1]);
            }
            case "Ni"; {
                assert(words.count == 2);
                current_material.refraction_index = string_to_float(words[1]);
            }
            case "Tr"; {
                assert(words.count == 2);
                current_material.transparency = string_to_float(words[1]);
            }
            case "d"; {
                assert(words.count == 2);
                current_material.transparency = 1 - string_to_float(words[1]);
            }
            case "illum"; {
                print("%\n", words);
                assert(words.count == 2);
                current_material.illumination_model = string_to_int(words[1]).(IlluminationModel);
            }
            case "map_Kd"; {
                assert(words.count == 2);
                current_material.diffuse_texture_path = join(directory, words[1]);
            }
            case "map_Ks"; {
                assert(words.count == 2);
                current_material.specular_texture_path = join(directory, words[1]);
            }
            case "map_Bump"; {
                assert(words.count == 2);
                current_material.normal_texture_path = join(directory, words[1]);
            }
        }
    }

    return true, data;
}
