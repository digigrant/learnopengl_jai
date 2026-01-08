# learnopengl_jai

https://github.com/user-attachments/assets/606357dd-119e-4cdd-9e18-6f7f2894a58b

<img width="1920" height="1080" alt="vlcsnap-2026-01-08-01h39m36s114" src="https://github.com/user-attachments/assets/329a0a21-9f4b-4971-ad80-0ba2069a24d3" />

TODO:
- make sure disabling (aka not using) render buffer works
  - allow us to choose which buffer to render onto the screen (i.e. debug buffer)
- temp alloc audit
- memory arena audit
- create base engine (CS230 engine)
- create scene & scene manager system
- update Model import to work with MaterialLibrary
- update Model import to import specular map
- write tests
- decouple input system from gameplay
- custom logger and allocator - give it a try
- revisit parser using Text File Handler
- group sending data to GPU (shaders and such) - more uniform buffers, batch-sending lighting uniforms to shaders (per scene, per frame, per draw)
- refactor uniform buffers
  - work with enums instead of strings
  - better API
- particle systems
- animations

Engine
- engine initializes all systems and controls flow
  - Systems: Graphics, Input, Scene, Events
  - calls init, update, render, exit
  - engine shutdown
Scene system
- manages active scene and transitions between scenes
Scene
- manages entities in scene
  - one or more entity containers; group objects by functionality
  - Containers: opaque meshes, blendable meshes, lights, skybox* (only ever 1 skybox at a time), cameras* (can be multiple but only 1 is active)
  - 
- Scene Load & Init: everything before the main loop basically
  - Load: allocating memory for entities, fetching data from library or loading from file. What needs to be done once per scene no matter how many times we restart?
  - Init: setting initial values for entities and scene. what needs to be reset when scene is restarted?
- Scene Update & Render/Draw: everything in the main loop
  - (input) -> update -> draw
  - Draw (per frame):
    - first, render shadow maps for lighting
      - set up shadow viewport, frame buffer, etc
      - render to texture/cubemap
    - second, render opaque meshes using lighting
      - set up render viewport, frame buffer, etc
      - send dirty camera view and projection matrices to uniform buffer
    - third, render skybox
    - fourth, render blendable meshes
    - fifth, draw to the screen
- Scene Unload: everything after main loop
  - what needs to be manually shutdown? what can be safely tossed when the game closes?

Implementation Notes
1. implement Transform
2. implement Entity
3. implement Scene
4. implement Engine
5. implement SceneManager
