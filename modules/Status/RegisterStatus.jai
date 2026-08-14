#import "Compiler";
#import "Basic";
#import "Sort";

MARKER_PREFIX :: "__status_marker_";

CUSTOM_STATUS_START_INDEX :: 2;

RegisterStatus :: (arg : Code) {
    node := compiler_get_nodes(arg);
    ident := cast(*Code_Ident) node;
    builder : String_Builder;
    print_to_builder(*builder, "#placeholder %;\n", ident.name);
    // This reveals a dummy function declaration to the compiler with a note (@StatusRegistration), 
    // which is the only way the status identifier can be communicated to the compiler during typechecking
    print_to_builder(*builder, "%1%2 :: () {} @StatusRegistration\n", MARKER_PREFIX, ident.name);
    // add as build string to current workspace
    add_build_string(builder_to_string(*builder), w = -1);
}

has_note :: (header : *Code_Procedure_Header, note : string) -> bool {
    for header.notes if it.text == note return true;
    return false;
}

names : [..] string;
generated := false;

HandleMessage :: (message : *Message) {
    if message.kind == {
        case .TYPECHECKED;
            // scan for REGISTER_STATUS call sites / placeholders
            // array_add_if_unique(*names, ident.name) for each
            typechecked := cast(*Message_Typechecked) message;
            for tc : typechecked.procedure_headers {
                header := tc.expression;
                if has_note(header, "StatusRegistration") {
                    array_add_if_unique(*names, advance(header.name, MARKER_PREFIX.count));
                }
            }
        case .PHASE;
            phase := cast(*Message_Phase) message;
            if !generated && phase.phase == .TYPECHECKED_ALL_WE_CAN {
                quick_sort(names, compare_strings);

                builder : String_Builder;
                // append(*builder, "Status :: #type u8;\n");
                // append(*builder, "STATUS_SUCCESS : Status : 0;\n");
                for names print_to_builder(*builder, "% : Status : %;\n", it, it_index + CUSTOM_STATUS_START_INDEX);

                add_build_string(builder_to_string(*builder), message.workspace);
                generated = true;
            }
    }
}

get_plugin :: () -> *Metaprogram_Plugin {
    plugin := New(Metaprogram_Plugin);
    plugin.message = (plugin : *Metaprogram_Plugin, message : *Message) {
        HandleMessage(message);
    };
    return plugin;
}
                                                
