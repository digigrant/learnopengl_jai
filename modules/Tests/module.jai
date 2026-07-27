#import "Compiler";
#import "Basic";
#import "Program_Print"; // print_expression

// Simple macro that takes a test function as argument and runs it
RUN_TEST :: (test : (), call := #caller_code) #expand {
    nodes := compiler_get_nodes(call);
    nodes_proc_call := cast(*Code_Procedure_Call) nodes;
    node_args := nodes_proc_call.*.arguments_unsorted;
    node_arg_name := (cast(*Code_Ident) node_args[0].expression).*.name;

    print("=== % ===\n", node_arg_name);
    test();
    print("\n");
}
