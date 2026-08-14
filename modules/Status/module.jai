#load "RegisterStatus.jai";

Status :: #type u8;

STATUS_SUCCESS : Status : 0;
STATUS_FAILURE : Status : 1;

/*
#no_reset current_status_index := 2;

LOCAL_STATUS_PREFIX : Status : 0x80;
*/

IS_SUCCESSFUL :: (status : Status) -> bool { return status == STATUS_SUCCESS; }

// @TODO : "RegisterStatus" compile-time function which automatically creates a unique local status code and assigns a unique value to it
// e.g. #run RegisterStatus(STATUS_FAILURE_NAME_ALREADY_EXISTS)

// @TODO : Make IS_SUCCESSFUL more elegant as an expandable macro which evaluates the expression passed in and creates an external identifier "status" for the result
// e.g. if !IS_SUCCESSFUL(DoSomeWork()) print("Work failed: %\n", status);


