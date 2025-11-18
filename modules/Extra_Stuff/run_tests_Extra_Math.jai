#import "Compiler";
#import "Basic";

#import,file "module.jai";

#run {
    set_build_options_dc(.{do_output=false});

    Log2();
}

Log2 :: () {
    array : [10] int : .[
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    ];
    expected_results : [10] float : .[
        0.0,
        1.0, 
        1.584962,
        2.0,
        2.321928,
        2.584962,
        2.807355,
        3.0,
        3.169925,
        3.321928
    ];

    for array {
        print("Log2(%) = %\n", it, Log2(it));
        assert(Log2(it) - expected_results[it_index] < 0.0001);
    }
}
