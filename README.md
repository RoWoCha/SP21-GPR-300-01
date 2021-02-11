# animal3D-SDK-202101SP
animal3D SDK and related course frameworks for spring 2021.

Repo for GPR-300-01: Intermediate Graphics and Animation class
Uses animal3D SDK by Daniel Buckstein
Projects are done by Egor Fesenko

1) Shaders implemented:
- Solid Color
- Texturing
- Lamber Shading
- Phong Shading (per-fragment and per-vertex)

2) In order to activate per-vertex Phong Shading, comment all uncommented code in
"fs/00-common/drawPhong_fs4x.glsl" and "vs/00-common/passTangentBasis_transform_vs4x.glsl",
(it has header "!!! Per-Fragment !!!"), and uncomment code with "!!! Per-Vertex !!!" headers
in both these shaders.