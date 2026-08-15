#import "Basic";
#import "Engine";
#import "Container";
#import "Status";

main :: () {
    if !IS_SUCCESSFUL(InitEntityRecipeLibrary()) {
        print("Entity recipe library failed to initialize. Shutting down.\n");
        return;
    }

    PrintEntityRecipeLibrary();
}
