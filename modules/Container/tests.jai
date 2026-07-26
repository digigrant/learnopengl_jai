#import "Compiler";

#load "module.jai";

test_create_int_container_success :: () {
    my_container := CreateContainer(int, 5);

    assert(my_container != null);

    PrintContainer(my_container);

    using my_container.*;
    assert(count == 0);
    assert(max_count == 5);
    assert(head != null);
    assert(T == int);
    assert(item_size == size_of(int));
    for my_container assert(it == 0);
}

test_create_struct_container_success :: () {
    IceCream :: struct {
        customer_name : string;
        scoops : int;
        chocolate_sauce : bool;
        walnuts : bool;
    };

    print("size of struct: %\n", size_of(IceCream));

    my_container := CreateContainer(IceCream, 10);

    assert(my_container != null);

    PrintContainer(my_container);

    using my_container.*;
    assert(count == 0);
    assert(max_count == 10);
    assert(head != null);
    assert(T == IceCream);
}

test_add_to_container_success :: () {
    max_count := 5;
    my_container := CreateContainer(int, xx max_count);
    my_int : int = ---;

    PrintContainer(my_container);

    result_status : Status;
    
    CalcValue :: (i : int) -> int { return 10 * (i+1); }

    for 0..max_count-1 {
        my_int = CalcValue(it);
        result_status = AddToContainer(my_container, *my_int);
        PrintContainer(my_container);
        
        assert(result_status == STATUS_SUCCESS);
        assert(my_container.*.count == it+1);
        for my_container.* if it_index < my_container.count assert(it == CalcValue(it_index));
        for my_container.* if it_index >= my_container.count assert(it == 0);

    }

    my_int = CalcValue(max_count);
    result_status = AddToContainer(my_container, *my_int);
    assert(result_status == STATUS_FAILURE_CONTAINER_FULL);
}

test_reset_container :: () {
    my_container := CreateContainer(int, 8);
    my_int : int = ---;
    
    CalcValue :: (i : int) -> int { return 10 * (i+1); }

    for 0..7 {
        my_int = CalcValue(it);
        AddToContainer(my_container, *my_int);
    }
    PrintContainer(my_container);
    assert(my_container.*.count == 8);
    for my_container.* assert(it == CalcValue(it_index));

    result_status := ResetContainer(my_container);
    assert(result_status == STATUS_SUCCESS);
    assert(my_container.*.count == 0);
    for my_container.* assert(it == 0);
}

/*

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
*/

#run {
    set_build_options_dc(.{do_output=false});

    test_create_int_container_success();
    test_create_struct_container_success();
    test_add_to_container_success();
    test_reset_container();
}
