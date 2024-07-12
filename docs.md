# Values + Functions

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

# Structs

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