#import "Basic";
#import "Status";

Container :: struct ($T : Type, $N : u64) {
    array : [N] T;
    count : u64; 
};

operator *[] :: (container : *Container($T, $N), index : int) -> *T {
    return *(container.array[index]);
}

STATUS_FAILURE_NO_CONTAINER_GIVEN ::    LOCAL_STATUS_PREFIX | 1;
STATUS_FAILURE_NO_ITEM_GIVEN ::         LOCAL_STATUS_PREFIX | 2;
STATUS_FAILURE_NO_PREDICATE_GIVEN ::    LOCAL_STATUS_PREFIX | 3;
STATUS_FAILURE_CONTAINER_FULL ::        LOCAL_STATUS_PREFIX | 4;

InitContainer :: (container : *Container($T, $N)) -> Status {
    if !container return STATUS_FAILURE_NO_CONTAINER_GIVEN;

    using container.*;
    memset(*array, 0, size_of(T));
    count = 0;
    return STATUS_SUCCESS;
}

AddToContainer :: (container : *Container($T, $N), item : *T) -> Status {
    if !container return STATUS_FAILURE_NO_CONTAINER_GIVEN;
    if !item return STATUS_FAILURE_NO_ITEM_GIVEN;

    using container.*;
    if count >= N return STATUS_FAILURE_CONTAINER_FULL;

    memcpy(*(array[count]), item, size_of(T));
    count += 1;

    return STATUS_SUCCESS;
}


FindInContainer :: (container : *Container($T, $N), predicate : *(item : *T) -> bool) -> *T {
    if !container return STATUS_FAILURE_NO_CONTAINER_GIVEN;
    if !predicate return STATUS_FAILURE_NO_PREDICATE_GIVEN;

    using container.*;
    for * array if predicate(it) return it;
    return null;
}
