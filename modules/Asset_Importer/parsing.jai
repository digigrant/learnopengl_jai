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
