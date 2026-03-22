# Keycap Playground — CadQuery

A fast, parametric keycap and keyboard generator built with
[CadQuery](https://github.com/CadQuery/cadquery), designed with **ISO keyboards**
and FDM printing in mind.

This project started as a reimplementation of the ideas behind
[riskable Keycap Playground](https://github.com/riskable/keycap_playground), but replaces
the OpenSCAD-based generation pipeline with CadQuery and multiprocessing.

The result is a complete pipeline from a keyboard template to 3MF PrusaSlicer ready files.

## Features

- **ISO keyboard support**
  - Parametric ISO Enter
  - Designed for layouts beyond ANSI-only workflows
- **Fast generation**
  - CadQuery-based geometry generation
  - Multiprocessing for independent keycaps
  - A complete layout can be generated in roughly **15 seconds** depending on
    the layout and hardware.
- **Completely obliterates OpenSCAD performance.**
- **Proper CAD geometry**
  - CadQuery operations make it possible to create geometry
    that was difficult or impractical to express in OpenSCAD, like **fillets**.
- **Custom keyboard templates**
  - Define an entire keyboard/layout rather than generating individual keys
  - Custom key sizes and positioning
- **Parametric keycap profiles**
  - Different keycap shapes and profiles
  - Per-key parameters
- **Legends**
  - Full legend support for flat keycaps
  - Experimental/limited support for sculpted keycaps
- **PrusaSlicer preprocessing**
  - Automatically add support blockers
  - Compute adaptive layer-height information
  - Assign extruders to parts for multicolor printing
- **Docker-based workflow**
  - Reproducible environment
  - No need to manually configure the CAD toolchain
- **Browser-based 3D viewer**
  - Preview generated CadQuery models in a Three.js-based viewer
- **3MF output**
  - Generate printable keycap geometry

## Why another keycap generator?

There are already several excellent keycap generators.

This project exists because they didn't quite fit the workflow I needed.

The original Keycap Playground was based on OpenSCAD. While powerful, generating
and iterating over complete keyboard layouts was **very, very slow**.

OpenSCAD also became a significant limitation when working on the actual keycap
geometry. In particular, the lack of native fillet operations was a major pain
when trying to create rounded, printable geometry.

At some point, I decided that repeatedly fighting OpenSCAD was less productive
than changing the CAD engine.

So I moved the geometry generation to **CadQuery**.

That brought proper CAD operations such as fillets, much faster generation through
multiprocessing, and a Python-based environment that is much easier to extend
with custom keyboard layouts and printing automation.

And while I was at it, I finally gave ISO keyboards some love.

I wanted something that could do this:

```text
Keyboard template
       ↓
Fast keycap generation
       ↓
ISO support + CAD operations
       ↓
Display results
       ↓
Export if satisfied
       ↓
PrusaSlicer preprocessing
       ↓
Ready for FDM printing
```

## Limitations / Known Issues

This project is still a work in progress. Some parts of the original OpenSCAD implementation have not been fully ported.

- **Keycap profiles**
  - The porting of the profiles from the original OpenSCAD implementation is
    currently limited. At the moment, the CadQuery implementation includes a custom profile with a
    flat surface.
  - More complex sculpted/dished profiles have not been fully ported.
  - The sculpted keycap code is currently incomplete and may be broken.
  - I deliberately did not prioritize implementing the more complex profiles because the results from my FDM printing tests were not good enough to justify spending more time on them.

- **Web UI**
  - The web UI is currently a prototype and was largely vibecoded.
  - There are several optimizations still needed, particularly around loading
    and displaying generated objects.
  - Large layouts can therefore take longer to load and display than they
    ideally should.

- **Performance / optimization**
  - There are still various areas that could be optimized.
  - Most of the currently identified optimization work is tracked in the
    project's TODOs.

## Contributing

This project is still evolving, and there is plenty left to improve.

If you want to help with profiles, geometry, performance, the web UI, PrusaSlicer integration, or anything else, **any help is appreciated!**

Issues, improvements, ideas, and pull requests are all welcome.


## License
This project is licensed under the [MIT License](LICENSE).