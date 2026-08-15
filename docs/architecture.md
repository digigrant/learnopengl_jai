# Architecture

learnopengl_jai is a Jai + OpenGL project working through the LearnOpenGL.com tutorials, with a
small custom engine layered underneath. There is no single growing `main` — each tutorial "scene"
is an independent executable with its own entry file and its own `build_*.jai` (see
[build-and-run.md](build-and-run.md)). The engine layer is the part meant to persist and grow
across scenes; the scene files themselves are closer to disposable exercises.

## Module map

- **`modules/Engine`** (`Entity.jai`, `EntityLibrary.jai`, `Scene.jai`, `Transform.jai`) — the
  engine skeleton (a CS230-style design — see root `README.md` for the fuller notes on intended
  Engine/Scene/Entity responsibilities and what's still unimplemented).

- **`modules/Graphics`** — rendering primitives: `Camera`, `Shader`, `Mesh`, `Model`,
  `Material`/`MaterialLibrary`, `Texture`/`TextureLibrary`, `Cubemap`, `FrameBuffer`,
  `UniformBufferRegistry`, `VertexObjects`. All `#load`ed flat into one namespace via
  `module.jai` — there's no sub-namespacing within Graphics. Also owns SDL/GL context setup
  (`Init`/`Shutdown`) and window/time queries.

- **`modules/Asset_Importer`** — `.obj`/`.mtl` importers, shared parsing helpers (`parsing.jai`),
  and a shader source reader.

- **`modules/Status`** — a project-wide `Status` error-code type (`#type u8`), plus
  `RegisterStatus`, a compile-time mechanism that lets *any* file dynamically declare a new
  globally-unique `Status` constant with one line (`#run RegisterStatus(#code NAME);`). This has
  real cross-module scoping subtlety — before touching `RegisterStatus.jai` itself, or writing a
  similar dynamic cross-module code-registration pattern elsewhere, see the routing table in
  `.claude/CLAUDE.md` for the project notes that cover what was tried and why.

- **`modules/Container`** — a generic fixed-capacity container, `Container($T)`, with a custom
  `for_expansion` (supports `for`, `for *`, `for <`, `for <*`).

- **Top-level scene files** — `main.jai`, `lighting_scene.jai`, `adv_lighting_scene.jai`,
  `space.jai`, `geometry_shader_exercise.jai` — each is an independent tutorial exercise, each
  paired with its own `build_*.jai`.
