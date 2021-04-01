# animal3D-SDK-202101SP
animal3D SDK and related course frameworks for spring 2021.

Repo for GPR-300-01: Intermediate Graphics and Animation class
Uses animal3D SDK by Daniel Buckstein Projects are done by Egor Fesenko

--- Project 4: Intro to Interpolation, Tessellation & Geometry Shaders ---

Shaders Implemented:

--VS--
empty_vs4x

--TS--
tessIso_tcs4x
passColor_interp_tes4x
tessTriTangentBasis_tcs4x
passTangentBasis_displace_tes4x

--GS--
drawTangentBases_gs4x

--FS--
drawPhongPOM_fs4x

Run instruction:
Open "LAUNCH_VS.bat" to open Visual Studio Project
Build and run
Go to "File" -> "DEBUG" -> "Quick build and load"
You can optionally change teapot's position interpolation technique
by uncommenting the one you want in a3_DemoMode3_Curves-idle-update.c,
and commenting others (LERP, Catmull-Rom, Cubic Hermite)