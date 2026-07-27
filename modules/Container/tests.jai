#import "Compiler";
#import "Basic";
#import "Tests";

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

IceCream :: struct {
    customer_name : string;
    scoops : int;
    chocolate_sauce : bool;
    walnuts : bool;
};

test_create_struct_container_success :: () {
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

test_add_to_int_container_success :: () {
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

test_add_to_struct_container_success :: () {
    my_container := CreateContainer(IceCream, 3);
    ice_creams : [4] IceCream : .[
        .{
            customer_name = "Alice",
            scoops = 2,
            chocolate_sauce = false,
            walnuts = true
        },
        .{
            customer_name = "Bob",
            scoops = 3,
            chocolate_sauce = true,
            walnuts = true
        },
        .{
            customer_name = "Carl",
            scoops = 1,
            chocolate_sauce = true,
            walnuts = false
        },
        .{
            customer_name = "Ploob",
            scoops = 10,
            chocolate_sauce = false,
            walnuts = false
        }
    ];

    result_status : Status;

    for 0..2 {
        result_status = AddToContainer(my_container, *(ice_creams[it]));
        PrintContainer(my_container);
        assert(result_status == STATUS_SUCCESS);
        assert(my_container.*.count == it+1);
    }

    result_status = AddToContainer(my_container, *(ice_creams[3]));
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

test_container_for_expansion :: () {
    my_container := CreateContainer(int, 8);
    my_int : int = ---;
    
    CalcValue :: (i : int) -> int { return 10 * (i+1); }

    for 0..7 {
        my_int = CalcValue(it);
        AddToContainer(my_container, *my_int);
    }

    PrintContainer(my_container);
    assert(my_container.*.count == 8);
    
    my_index := 0;
    for my_container.* {
        assert(type_of(it) == int);
        //assert(it == CalcValue(my_index));
        //assert(it_index == my_index);
        my_index += 1;
    }

    my_index = 0;
    for * my_container.* {
        assert(type_of(it) == *int);
        //assert(it.* == CalcValue(my_index));
        //assert(it_index == my_index);
        my_index += 1;
    }

    my_index = 7;
    for < my_container.* {
        assert(type_of(it) == int);
        //assert(it == CalcValue(my_index));
        //assert(it_index == my_index);
        my_index -= 1;
    }

    my_index = 7;
    for <* my_container.* {
        assert(type_of(it) == *int);
        //assert(it.* == CalcValue(my_index));
        //assert(it_index == my_index);
        my_index -= 1;
    }
}

test_find_int :: () {
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

    result : *int = null;
    result_status : Status;

    Equals :: (item : *int, args : *void) -> bool { return item.* == (cast(*int) args).*; }
    find_value := 30;

    result, result_status = FindInContainer(my_container, Equals, *find_value);
    assert(result != null);
    assert(result.* == find_value);
    assert(result_status == STATUS_SUCCESS);

    find_value = 67;
    result, result_status = FindInContainer(my_container, Equals, *find_value);
    assert(result == null);
    assert(result_status == STATUS_SUCCESS);
}

#run {
    set_build_options_dc(.{do_output=false});

    RUN_TEST(test_create_int_container_success);
    RUN_TEST(test_create_struct_container_success);
    RUN_TEST(test_add_to_int_container_success);
    RUN_TEST(test_add_to_struct_container_success);
    RUN_TEST(test_reset_container);
    RUN_TEST(test_find_int);
    RUN_TEST(test_container_for_expansion);
}
