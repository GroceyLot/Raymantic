# Starting guide

- Create a love2d project, and put LICENSE, raymantic.lua, globals.glsl, shader.glsl, and structs.glsl into its folder. You might want this file as well, but you can just view it on github.
- **License is legally required**
- In ```love.load()``` create a scene using the following line: ```scene = require("raymantic")()```
- Set up an sdf using this:
```
scene.sdfs[1] = [[
sdfInfo sdf(vec3 point) {
    sdfInfo info;
    vec3 p = point;
    vec3 spherePos = vec3(0.0, 0.0, 0.0);

    // Calculate the position modulo the repeating pattern size
    vec3 modPos = mod(p, vec3(5.0));
    float sphereDist = sdfSphere(modPos - vec3(2.5), spherePos, 1.0);

    // Determine the "unmodded" center of the sphere
    vec3 sphereCenter = floor(p / 5.0) * 5.0 + vec3(2.5);

    // Set the sdfInfo
    info.dist = sphereDist;
    info.material.color = vec3(1.0);

    // Determine if the indices for x, y, and z axes are even or odd
    bool isEvenX = mod(floor(p.x / 5.0), 2.0) < 1.0;
    bool isEvenY = mod(floor(p.y / 5.0), 2.0) < 1.0;
    bool isEvenZ = mod(floor(p.z / 5.0), 2.0) < 1.0;

    // Make the sphere reflective if all indices are even or all are odd
    info.material.reflective = (isEvenX == isEvenY) && (isEvenY == isEvenZ);

    return info;
}]]
```
- This is just an example (an infinite grid of sphere, of which some are reflective)
- Make sure to compile the shader: ```scene:compileShaders()```
- Then in ```love.draw()``` we can render it:
```
local render = scene:startRender()
render.render()
```

# GLSL

## Values + Functions

```float sdfSphere(vec3 p, vec3 center, float radius)``` - Computes the signed distance from point p to a sphere with specified center and radius.

```float sdfBox(vec3 p, vec3 center, vec3 size)``` - Computes the signed distance from point p to an axis-aligned box with specified center and size.

```float sdfTorus(vec3 p, vec3 center, vec2 t)``` - Computes the signed distance from point p to a torus with specified center, major radius t.x, and minor radius t.y.

```float sdfPlane(vec3 p, vec3 normal, float offset)``` - Computes the signed distance from point p to a plane defined by its normal vector and offset from the origin.

```float sdfCylinder(vec3 p, vec3 start, vec3 end, float radius)``` - Computes the signed distance from point p to a finite cylinder defined by its start and end points and radius.

```float sdfCone(vec3 p, vec3 apex, vec3 axis, float angle)``` - Computes the signed distance from point p to a cone with specified apex, axis, and half-angle.

```float sdfCapsule(vec3 p, vec3 a, vec3 b, float radius)``` - Computes the signed distance from point p to a capsule defined by its endpoints a and b and radius.

```float sdfRoundedBox(vec3 p, vec3 center, vec3 size, float radius)``` - Computes the signed distance from point p to a rounded box with specified center, size, and corner radius.

```float sdfEllipsoid(vec3 p, vec3 center, vec3 radii)```- Computes the signed distance from point p to an ellipsoid with specified center and radii along each axis.

```float sdfHexagonalPrism(vec3 p, vec3 center, vec2 h)``` - Computes the signed distance from point p to a hexagonal prism with specified center and height h.

```float sdfBoxFrame(vec3 p, vec3 center, vec3 size, float thickness)``` - Computes the signed distance from point p to a box frame with specified center, size, and thickness.

```float udfTriangle(vec3 p, vec3 v0, vec3 v1, vec3 v2)``` - Computes the unsigned distance from point p to a triangle defined by vertices v0, v1, and v2.

```float opSmoothUnion(float d1, float d2, float k)``` - Performs a smooth union operation between two distances d1 and d2 with smoothing factor k.

```float opSmoothSubtraction(float d1, float d2, float k)``` - Performs a smooth subtraction operation between two distances d1 and d2 with smoothing factor k.

```float opSmoothIntersection(float d1, float d2, float k)``` - Performs a smooth intersection operation between two distances d1 and d2 with smoothing factor k.

```float time``` - The time in seconds that the program has been running.

```float PI``` - Self explanatory.

```vec2 screenResolution``` - Screen in pixels.

```bool debug``` - scene.debug from lua.

## Structs

```
struct basicMaterial {
    vec3 color;
    bool reflective;
};

struct sdfInfo {
    float dist;
    basicMaterial material;
};

struct hitInfo {
    float fullDist;
    float minDist;
    float avgDist;
    bool hit;
    int numIterations;
    basicMaterial material;
};
```

# Lua

```
scene - object
    .camera - object
        .pos - array //[x, y, z]
        .yaw - float //Degrees
        .pitch - float //Also degrees
        .fov - int //More degrees
    .rendering - object
        .quality - object
            .marches - int
            .bounces - int
        .fog - object
            .start - int
            .end - int
            .enabled - bool
        .gooch - object
            .enabled - bool
            .coolAmount - float //CoolColor = SurfaceColor * CoolAmount
            .lightDirection - array //[x, y, z]
        .ambient - object
            .enabled - bool
            .amount - float
    .debug - bool //Passed to the sdf
    .sdfs - array<string> //Look in main.lua for an example
    .sdf - int //Which sdf to use
    .sky - string //Only change if you want to have day and night, look in raymantic.lua for an example
    .shader - void | shader //The love shader object created on compileShaders() or nil
    :compileShaders() - void //Compiles the shader, run at the start, and when changing sdfs
    :startRender() - object
        .sendSdf(uniform - string, value - ...) - ? //Returns whatever shader:send() returns
        .render() - void //Finishes and renders to the screen
```
