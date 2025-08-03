# cmake profiles

A template for C and C++ projects (or really anything that works with CMake) with an
opinionated structure revolving around keeping the project platform-independent and using
CMake presets effectively for sharing configuration.

## Usage

```bash
make # build current preset with the current profile
make show # show current preset and current profile
make list-presets # show available presets
make list-profiles # show available profiles
make re # re(configure) and build the current preset with the current profile
make test # test current preset with the current profile
make lint # lint the current preset with the current profile (by default using clang-tidy)
make format # format source files (by default C/C++ files with clang-format)

make target:'target' # build only target 'target' with the current preset and the current profile
make 'preset' # switch to preset 'preset', then configure, and build it with the current profile
make 'preset'.c # switch to preset 'preset', and configure it with the current profile
make 'preset'.b # switch to preset 'preset', and build it with the current profile
make 'preset'.t # switch to preset 'preset', and test it with the current profile
make all      # build all presets with the current profile
make test_all # test all presets with the current profile
make switch:'profile' # switch to profile 'profile'

```

## Philsophy

The central philsophy is that within CMake I want to, as far as possible, not set any
flags that are in any way compiler-, or platform-dependent. Ideally cmake only serves to
modularize my source files via targets and keep track of their dependencies. This begs the
question of how to store flags or other configuration options that are commonly used (e.g.
because releases for relevant platforms are built with them or they are useful during
development)

CMake has a mechanism for this, namely
[CMake Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html).
