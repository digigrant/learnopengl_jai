#import "Basic";
#import "File";
#import "String";

Scene :: struct {

}

ImportAsset :: (path : string) -> ok : bool {
    asset, ok := read_entire_file(path);
    if !ok {
        print("Unable to import asset: %\n", path);
        return false;
    }

    // parse whole file
    cursor : int = 0;
    next_newline_index, last_index : int;
    line : string;
    words : [..] string;
    word_start : int = 0;

    while cursor < 2000 {

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

        print("%\n", words);


        // go to next line
        cursor = next_newline_index + 1;
    }

    return true;
}
