# Build & run

There is no `jai` on `$PATH` in this environment. Invoke the compiler by its full path,
`~/jai/bin/jai-linux`, passing one of the build files below, from the repo root:

```
~/jai/bin/jai-linux build.jai
```

Each build file is a small `#run` metaprogram that creates a workspace, sets
`output_executable_name`, and `add_build_file`s exactly one entry file. Output binaries land in
`build/`.

| Build file | Entry file | Executable |
|---|---|---|
| `build.jai` | `main.jai` | `learnopengl_jai` |
| `build_lighting_scene.jai` | `lighting_scene.jai` | `lighting_scene` |
| `build_adv_lighting_scene.jai` | `adv_lighting_scene.jai` | `adv_lighting_scene` |
| `build_geometry.jai` | `geometry_shader_exercise.jai` | `geometry_shader_exercise` |
| `build_space.jai` | `space.jai` | `space_exercise` |

Run the result directly, e.g. `./build/learnopengl_jai`.

## Tests

Both test entry points run their assertions inside `#run` blocks **at compile time** — "running
the tests" means compiling the file, there's no separate binary execution step.

- `modules/Container/tests.jai` — compile it directly:
  `~/jai/bin/jai-linux modules/Container/tests.jai`.
- `modules/Status/tests.jai` — must go through `modules/Status/build.jai` instead, which drives a
  manual `compiler_begin_intercept` + message loop (`~/jai/bin/jai-linux modules/Status/build.jai`).
  This is required because `RegisterStatus`'s compile-time registration mechanism needs to observe
  `.TYPECHECKED`/`.PHASE` compiler messages directly — compiling `tests.jai` on its own skips that
  plugin wiring.
