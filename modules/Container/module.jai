#import "Basic";    // align_forward()
#import "Status";

Container :: struct ($T : Type) {
    #as using header : ContainerHeader;
};

ContainerHeader :: struct {
    count : u32;
    max_count : u32;
    item_size : u32;
    head : *u8;
}

ALIGNMENT :: 8;
CreateContainer :: ($T : Type, max_count : u32, alignment : u32 = 8, is_packed : bool = false) -> *Container(T) {
    padding := ALIGNMENT - (size_of(ContainerHeader) % ALIGNMENT);
    container := cast(*Container(T)) alloc(size_of(ContainerHeader) + padding + (size_of(T) * max_count));

    container.*.max_count = max_count;
    container.*.item_size = ifx is_packed size_of(T) else cast(u32) align_forward(size_of(T), alignment);
    container.*.head = cast(*u8) container + size_of(ContainerHeader);

    ResetContainer(container);

    return container;
}

ResetContainer :: (container : *Container) -> Status {
    if container == null return STATUS_FAILURE_NO_CONTAINER_GIVEN;
    using container.*;
    count = 0;
    memset(head, 0, size_of(T) * max_count);
    
    return STATUS_SUCCESS;
}

operator *[] :: (container : *Container($T), index : int) -> *T {
    assert(index < container.*.count);
    return cast(*T) container.*.head + (size_of(T) * index);
}

for_expansion :: (container : Container, body : Code, flags : For_Flags) #expand {
    if container.count > 0 {
        for index : 0..container.count-1 {
        `it_index := index;
        `it := (cast (*container.T) (container.head + (index * container.item_size))).*;

        #insert body;
        }
    }
}

PrintContainer :: (container : *Container) {
    print("Type: %\n", type_of(container.*));
    print("Item Size: %\n", container.*.item_size);
    print("Max Count: %\n", container.*.max_count);
    print("Count: %\n", container.*.count);
    if container.count > 0 {
        print("Elements:\n");
        for container.* print("\t%\n", it);
    }
}

STATUS_FAILURE_NO_CONTAINER_GIVEN ::    LOCAL_STATUS_PREFIX | 1;
STATUS_FAILURE_NO_ITEM_GIVEN ::         LOCAL_STATUS_PREFIX | 2;
STATUS_FAILURE_NO_PREDICATE_GIVEN ::    LOCAL_STATUS_PREFIX | 3;
STATUS_FAILURE_CONTAINER_FULL ::        LOCAL_STATUS_PREFIX | 4;

/*
InitContainer :: (container : *Container($T, $N)) -> Status {
    if !container return STATUS_FAILURE_NO_CONTAINER_GIVEN;

    using container.*;
    memset(*array, 0, size_of(T));
    count = 0;
    return STATUS_SUCCESS;
}
*/

AddToContainer :: (container : *Container($T), item : *T) -> Status {
    if !container return STATUS_FAILURE_NO_CONTAINER_GIVEN;
    if !item return STATUS_FAILURE_NO_ITEM_GIVEN;

    using container.*;
    if count >= max_count return STATUS_FAILURE_CONTAINER_FULL;

    memcpy(head + (count * item_size), item, size_of(T));
    count += 1;

    return STATUS_SUCCESS;
}

/*
FindInContainer :: (container : *Container($T, $N), predicate : *(item : *T) -> bool) -> *T {
    if !container return STATUS_FAILURE_NO_CONTAINER_GIVEN;
    if !predicate return STATUS_FAILURE_NO_PREDICATE_GIVEN;

    using container.*;
    for * array if predicate(it) return it;
    return null;
}
*/
