#import "Basic";
#import "SDL";

SCREEN_WIDTH    :: 800;
SCREEN_HEIGHT   :: 600;

main :: () {
    SDL_Init(SDL_INIT_VIDEO);

    window := SDL_CreateWindow("LearnOpenGL_Jai", SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT,
        SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
    
    if window == null {
        print("Could not create window: %\n", to_string(SDL_GetError()));
        return;
    }

    exit := false;
    while !exit {
        event : SDL_Event;
        while SDL_PollEvent(*event) {
            if event.type == {
                case SDL_QUIT; exit = true;
                case SDL_KEYUP;
                    if event.key.keysym.sym == SDLK_ESCAPE exit = true;
            }
        }

        SDL_Delay(1);
    }

    SDL_DestroyWindow(window);

    SDL_Quit();
}
