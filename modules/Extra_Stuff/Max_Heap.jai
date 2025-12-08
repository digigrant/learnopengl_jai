#import "Basic";
#import "Math";

/*
    1. create an unsorted array of the elements you want to Heapify
    2. call Heapify on the array using a compare function
    3. call HeapPop to remove max element
*/

Heapify :: (array : [] $T, fp_Compare : (a : *T, b : *T) -> int) -> heap_view : [] T {
    // bubble down starting from first parent
    last_parent := GetParentIndex(array.count - 1);
    for < 0..last_parent BubbleDown(array, fp_Compare, it);
    return array;
}

HeapPop :: (heap_view : *[] $T, fp_Compare : (a : *T, b : *T) -> int) -> max_element : *T {
    if (heap_view.count < 1) return null;

    swap(*(heap_view.*[0]), *(heap_view.*[heap_view.count-1])); // swap first and last elements
    max_element := *(heap_view.*[heap_view.count - 1]);
    heap_view.count -= 1;
    BubbleDown(heap_view.*, fp_Compare, 0);

    return max_element;
}

HeapAdd :: (heap_view : *[] $T, fp_Compare : (a : *T, b : *T) -> int, value : *T) {
    // right now we're trusting that whoever is calling this function has already checked that
    // there is enough allocated space for us to add what we want
    // if that's not true, we're about to overwrite OOB memory. ~~~YIKES!~~~

    heap_view.count += 1;
    memcpy(*(heap_view.*[heap_view.count-1]), value, size_of(T));
    BubbleUp(heap_view.*, fp_Compare, heap_view.count-1);
}

PrintHeap :: (array : [] $T, fp_PrintElement : (element : *T)) {
    print("Printing heap:\n");
    PrintHeapElement(array, fp_PrintElement, 0);
}

#scope_file;

GetParentIndex :: (i : int) -> int      { return (i - 1) / 2; }
GetLeftChildIndex :: (i : int) -> int   { return (i * 2) + 1; }

BubbleDown :: (array : [] $T, fp_Compare : (a : *T, b : *T) -> int, i : int) {
    max_index := i;
    left_child := GetLeftChildIndex(i);

    // compare to left and right children to get max
    for 0..1 {
        if (left_child + it < array.count) && fp_Compare(*(array[max_index]), *(array[left_child + it])) < 0
            max_index = left_child + it;
    }

    // if i is not the max, swap i and max
    // continue bubbling i down from new position
    if max_index != i {
        swap(*(array[i]), *(array[max_index]));
        BubbleDown(array, fp_Compare, max_index);
    }
}

BubbleUp :: (array : [] $T, fp_Compare : (a : *T, b : *T) -> int, i : int) {
    if i == 0 || fp_Compare(*(array[i]), *(array[GetParentIndex(i)])) <= 0 return;
    parent_index := GetParentIndex(i);
    swap(*(array[i]), *(array[parent_index]));
    BubbleUp(array, fp_Compare, parent_index);
}

PrintHeapElement :: (array : [] $T, fp_PrintElement : (element : *T), i : int) {
    if i >= array.count return;

    depth := floor(Log2(i + 1)).(int);
    for 0..depth print("\t");
    fp_PrintElement(*(array[i]));

    PrintHeapElement(array, fp_PrintElement, GetLeftChildIndex(i));
    PrintHeapElement(array, fp_PrintElement, GetLeftChildIndex(i)+1);
}
