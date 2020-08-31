# Pascal - Raytracing In One Weekend

This is a fairly straightforward implementation of [Peter Shirley's "Ray Tracing in One Weekend"](https://raytracing.github.io/books/RayTracingInOneWeekend.html) book in Object Pascal Delphi and FPC/Lazarus.

![](render_capa.jpg)

Book cover rendered with 3000 x 2000 pixels, 1000 samples per pixel and 500 of max ray depth. Took approximately 41 hours to render on Delphi-Windows build.

**Technical TODOs:**
- [x] JSON scene loader in Windows
- [x] JSON scene loader in Linux
- [x] PPM image exporter in Windows
- [x] PPM image exporter in Linux
- [x] BMP image exporter in Windows
- [x] BMP image exporter in Linux
- [ ] Clean the code

**Business TODOs:**
- [x] The vec3 Class
- [x] Rays, a Simple Camera, and Background
- [x] Adding a Sphere
- [x] Surface Normals and Multiple Objects
- [x] Antialiasing
- [x] Diffuse Materials
- [x] Metal
- [x] Dielectrics
- [x] Positionable Camera
- [x] Defocus Blur
- [ ] Where Next?

**Experimental TODOS:**
- [ ] Deterministic ray scattering. Expected: Less rays do the diffusion looks like more the reflection, but without noise. Four rays per pixel to antialiasing effect. Each ray is divided in N sample rays in a grid way scattering. How will the light result behaviour be like?

**Project TODOs:**
- [ ] Nothing more to do, project concluded.
