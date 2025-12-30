#import "Basic";

PrintStructInfo :: ($struct_type : Type) {
    assert(type_info(struct_type).type == .STRUCT);

    ti := cast(*Type_Info_Struct) type_info(struct_type);
    print("% ---\n", ti.name);
    print("runtime_size: %\n", ti.runtime_size);
    for member : ti.members {
        print("\t% % %\n", member.name, member.offset_in_bytes, member.type.runtime_size);
    }
    print("\n");
}
