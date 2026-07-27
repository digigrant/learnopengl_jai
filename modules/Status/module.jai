Status :: u8;

STATUS_SUCCESS : Status : 0;
STATUS_FAILURE : Status : 1;

LOCAL_STATUS_PREFIX : Status : 0x80;

IS_SUCCESSFUL :: (status : Status) -> bool { return status == STATUS_SUCCESS; }
