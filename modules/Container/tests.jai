#import "Compiler";

#load "module.jai";

test_init_success :: () {
    my_container : Container(int, 5);
    result_status := InitContainer(*my_container);

    assert(result_status == STATUS_SUCCESS);
    assert(my_container.array.count == 5);
    assert(my_container.array.data != null);
    assert(my_container.T == int);
    assert(my_container.N == 5);
    for my_container.array assert(it == 0);
    assert(my_container.count == 0);
}

test_init_null_container :: () {
    p_null_container : *Container(int,5) = null;
    result_status := InitContainer(p_null_container);
    assert(result_status == STATUS_FAILURE_NO_CONTAINER_GIVEN);
}

test_add_to_container_null_container :: () {
    p_null_container : *Container(int,5) = null;
    item : int = 4;
    result_status := AddToContainer(p_null_container, *item);
    assert(result_status == STATUS_FAILURE_NO_CONTAINER_GIVEN);
}

test_add_to_container_success :: () {
    my_container : Container(int,5);
    my_int : int = 4;

    InitContainer(*my_container);

    result_status := AddToContainer(*my_container, *my_int);
    
    assert(result_status == STATUS_SUCCESS);
    assert(my_container.count == 1);
    assert(my_container[0] == my_int);
    for my_container.array if it_index > 0 assert(it == 0);

}

#run {
    set_build_options_dc(.{do_output=false});

    test_init_success();
    test_init_null_container();
    test_add_to_container_success();
    test_add_to_container_null_container();
}
