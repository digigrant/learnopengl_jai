Status :: u8;

STATUS_SUCCESS : Status : 0;
STATUS_FAILED : Status : 1;

LOCAL_STATUS_PREFIX : Status : 0h80;

IS_SUCCESSFUL :: (status : Status) -> bool { return status == STATUS_SUCCESS; }
