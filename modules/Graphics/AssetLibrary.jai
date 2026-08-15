#import "Status";
#import "Container";

AssetLibrary :: struct ($asset_type : Type) {
    container : *Container(asset_type);
    asset_directory : string;
    load_file_func : (string) -> *void, Status;
    requested_asset_name_queue : [..] string;
    file_to_load_queue : [..] string;
    loaded_files : [..] string;
};

#run RegisterStatus(#code STATUS_FAILURE_COULDNT_CREATE_LIBRARY);
#run RegisterStatus(#code STATUS_FAILURE_COULDNT_CREATE_CONTAINER);

CreateAssetLibrary :: (asset_type : Type, max_count : u32, asset_directory : string, load_file_func : (string) -> Status) -> *AssetLibrary, Status {
    asset_library = New(AssetLibrary(asset_type));
    if asset_library == null return STATUS_FAILURE_COULDNT_CREATE_LIBRARY;

    status : Status;
    asset_library.*.container, status = CreateContainer(asset_type, max_count);
    if !IS_SUCCESSFUL(status) return STATUS_FAILURE_COULDNT_CREATE_CONTAINER;

    asset_library.*.asset_directory = asset_directory;
    asset_library.*.load_file_func = load_file_func;

    return asset_library, STATUS_SUCCESS;
}

PrepareFile :: (asset_library : *AssetLibrary, filename : string) {
    using asset_library.*;
    if array_find(loaded_files, filename) return;
    if array_find(file_to_load_queue, filename) return;
    array_add(*file_to_load_queue, filename);
}

LoadAllQueuedFiles :: (asset_library : *AssetLibrary) -> Status {
    using asset_library.*;
    if file_to_load_queue.count < 1 return STATUS_SUCCESS;
    
    status : Status;

    // reverse array in-place
    temp : string;
    halfway_index := (file_to_load_queue.count+1)/2;
    for 0..halfway_index {
        temp = file_to_load_queue[it];
        file_to_load_queue[it] = file_to_load_queue[file_to_load_queue.count-it-1];
        file_to_load_queue[file_to_load_queue.count-it-1] = temp;
    }

    filename : string;
    while file_to_load_queue.count > 0 {
        filename = pop(file_to_load_queue);
        status = LoadFile(asset_library, filename);
        if !IS_SUCCESSFUL(status) print("Failed to load file: %\n", filename);
    }

    return STATUS_SUCCESS;
}

STATUS_FAILURE_FILE_DOESNT_EXIST :: LOCAL_STATUS_PREFIX | 3;
STATUS_FAILURE_COULDNT_READ_FILE :: LOCAL_STATUS_PREFIX | 4;
LoadFile :: (asset_library : *AssetLibrary, filename : string) -> Status {
    if !file_exists(filename) return STATUS_FAILURE_FILE_DOESNT_EXIST;

    // read data file and retrive formatted data, e.g. MtlData
    data, status := asset_library.*.load_file_func(filename);
    if !IS_SUCCESSFUL(status) return STATUS_FAILURE_COULDNT_READ_FILE;
    defer array_append(*loaded_files, filename);

    // we retreived the data but we don't know what we retreived
    
