#import "Basic";
#import "File";
#import "Status";
#import "Container";
#import "Asset_Importer";

MAX_COUNT_MESH_LIBRARY :: 100;
MESH_ASSET_DIRECTORY :: "assets//meshes//";
mesh_library : *Container(Mesh);

InitMeshLibrary :: () -> Status {
    status : Status;
    mesh_library, status = CreateContainer(Mesh, MAX_COUNT_MESH_LIBRARY);

    if !IS_SUCCESSFUL(status) {
        print("Failed to create mesh library: %\n", status);
        return STATUS_FAILURE;
    }

    base_file := tprint("%//_base", MESH_ASSET_DIRECTORY);
    // base file contains a list of obj files to import
    file, ok := read_entire_file(base_file);
    // if !ok...

    cursor := 0;
    count := ReadValue(file, *cursor, int);
    base_filenames : [..] string;
    for 0..count-1 array_add(*base_filenames, ReadValue(file, *cursor, string));

    for base_filenames ImportFileToMeshLibrary(it);

    return STATUS_SUCCESS;
}

ImportFileToMeshLibrary :: (path : string) -> Status {
    file, ok := read_entire_file(path);
    if !ok return STATUS_FAILURE_COULDNT_READ_FILE;

    cursor := 0;
    count := ReadValue(file, *cursor, int);
    temp : Mesh;
    
    
