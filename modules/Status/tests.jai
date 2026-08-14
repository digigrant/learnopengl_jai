#import "Basic";
#import "Status";

#run RegisterStatus(#code TEST_STATUS);

#run {
    print("We just printing shit\n");
}

function_that_returns_test_status :: () -> Status {
    return TEST_STATUS;
}

main :: () {
    status := function_that_returns_test_status();
    print("%\n", status);
}

