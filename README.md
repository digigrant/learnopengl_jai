# learnopengl_jai

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