#import "Compiler";
#import "Basic";

#import,file "module.jai";

#run {
    set_build_options_dc(.{do_output=false});

    MaxHeapInts();
}

MaxHeapInts :: () {
    array : [10] int = .[
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    ];

    print("%\n", array);

    CompareInts :: (a : *int, b : *int) -> int { return clamp(a.* - b.*, -1, 1); }
    PrintInt :: (a : *int) { print("%\n", a.*); }

    heap_view := Heapify(array, CompareInts);
    PrintHeap(heap_view, PrintInt);
    
    curr_max, prev_max : int = -1;
    value : *int;

    for 0..9 {
        value = HeapPop(*heap_view, CompareInts);
        curr_max = value.*;
        print("array: %\nheap_view: %\n", array, heap_view);
        if prev_max > -1 assert(curr_max < prev_max);
        prev_max = curr_max;
    }
}
