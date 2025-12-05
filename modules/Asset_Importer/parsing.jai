ParseLineForWords :: (text : string, cursor : *int, print_debug : bool = false, print_condition : string = "") -> words : [] string {
    // get line
    next_newline_index := find_index_from_left(text, #char "\n", cursor.*);
    line := slice(text, cursor.*, next_newline_index - cursor.*);
    
    // get words
    print_debug_active := print_debug;
    word_start := 0;
    last_index := -1;
    words : [..] string;
    for char : line {
        if char == {
            case #char "#"; break;
            case #char "\r"; #through;  // creates problems on windows if we don't also parse for this
            case #char " "; {
                if it_index <= word_start continue;
                new_word := slice(line, word_start, it_index - word_start);
                if print_debug_active && words.count == 1 && print_condition != "" {
                    print("print_condition is '%'. equal? - %\n", print_condition, print_condition == new_word);
                    print_debug_active = ifx print_condition == new_word then true else false;
                }

                AddNewWord(*words, new_word, word_start, it_index, print_debug_active);
                word_start = it_index + 1;
            }
        }
        last_index = it_index;
    }
    // get whatever the last word was before we hit the end
    if last_index >= word_start AddNewWord(*words, slice(line, word_start, last_index - word_start + 1), word_start, last_index, print_debug_active);

    // prepare cursor for next line
    (cursor.*) = next_newline_index + 1;

    return words;
}

#scope_file

AddNewWord :: (words : *[..] string, new_word : string, word_start : int, word_end : int, print_debug : bool = false) {
    array_add(words, new_word);
    if print_debug print("ParseLineForWords: Finished '%' from index %, %\n", new_word, word_start, word_end);
}

#scope_export

ReadValue :: (file : string, cursor : *int, $T : Type) -> value : T {
    start := cursor.*;
    while cursor.* < file.count {
        if is_any(file[cursor.*], ifx type_info(T).type != .STRING then DEFAULT_SPACES else "\t\r\n") break;
        cursor.* += 1;
    }

    value_text := slice(file, start, (cursor.*)-start);
    MoveCursorToNextValue(file, cursor);

    PrintError :: () { print("Don't know how to read that value type: %\n", T); }

    #if type_info(T).type == {
        case .STRING;   return value_text;
        case .INTEGER;  return string_to_int(value_text);
        case .FLOAT;    return string_to_float(value_text);
        case .STRUCT; {
            type_info_struct := cast(*Type_Info_Struct) type_info(T);
            if type_info_struct.name == {
                case "Vector3"; return .{
                    string_to_float(value_text),
                    ReadValue(file, cursor, float),
                    ReadValue(file, cursor, float)
                };
                case; {
                    PrintError();
                    return .{};
                }
            }
        }
        case; {
            PrintError();
            return null;
        }
    }
}

#scope_file

MoveCursorToNextValue :: (file : string, cursor : *int) {
    while cursor.* < file.count && is_any(file[cursor.*], DEFAULT_SPACES) {
        cursor.* += 1;
    }
}
