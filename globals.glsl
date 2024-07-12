// Sphere SDF
float sdfSphere(vec3 p, vec3 center, float radius) {
    return length(p - center) - radius;
}

// Box SDF
float sdfBox(vec3 p, vec3 center, vec3 size) {
    vec3 d = abs(p - center) - size;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

// Torus SDF
float sdfTorus(vec3 p, vec3 center, vec2 t) {
    vec3 q = p - center;
    vec2 r = vec2(length(vec2(q.x, q.z)) - t.x, q.y);
    return length(r) - t.y;
}

// Plane SDF
float sdfPlane(vec3 p, vec3 normal, float offset) {
    return dot(p, normal) + offset;
}

// Cylinder SDF
float sdfCylinder(vec3 p, vec3 start, vec3 end, float radius) {
    vec3 pa = p - start;
    vec3 ba = end - start;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - radius;
}

// Cone SDF
float sdfCone(vec3 p, vec3 apex, vec3 axis, float angle) {
    vec3 pa = p - apex;
    float cosTheta = cos(angle);
    float sinTheta = sin(angle);
    float q = dot(pa, axis);
    vec3 d = pa - axis * q;
    float r = length(d) * cosTheta - q * sinTheta;
    return length(d) * sinTheta + q * cosTheta - r;
}

// Capsule SDF
float sdfCapsule(vec3 p, vec3 a, vec3 b, float radius) {
    vec3 pa = p - a;
    vec3 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - radius;
}

// Rounded Box SDF
float sdfRoundedBox(vec3 p, vec3 center, vec3 size, float radius) {
    vec3 d = abs(p - center) - size;
    return length(max(d, 0.0)) - radius;
}

// Ellipsoid SDF
float sdfEllipsoid(vec3 p, vec3 center, vec3 radii) {
    vec3 n = (p - center) / radii;
    return length(n) - 1.0;
}

// Hexagonal Prism SDF
float sdfHexagonalPrism(vec3 p, vec3 center, vec2 h) {
    vec3 q = abs(p - center);
    return max(q.z - h.y, max(q.x * 0.866025 + q.y * 0.5, q.y) - h.x);
}

float sdfBoxFrame(vec3 p, vec3 center, vec3 size, float thickness) {
    vec3 d = abs(p - center) - size;
    vec3 q = abs(d + thickness) - thickness;
    return min(max(q.x, max(q.y, q.z)), 0.0) + length(max(q, 0.0));
}

float udfTriangle(vec3 p, vec3 v0, vec3 v1, vec3 v2) {
    vec3 e0 = v1 - v0;
    vec3 e1 = v2 - v0;
    vec3 v2p = p - v0;

    float d00 = dot(e0, e0);
    float d01 = dot(e0, e1);
    float d11 = dot(e1, e1);
    float d20 = dot(v2p, e0);
    float d21 = dot(v2p, e1);

    float denom = d00 * d11 - d01 * d01;
    float v = (d11 * d20 - d01 * d21) / denom;
    float w = (d00 * d21 - d01 * d20) / denom;
    float u = 1.0 - v - w;

    vec3 nearestPoint;
    if (u >= 0.0 && v >= 0.0 && w >= 0.0) {
        nearestPoint = v0 * u + v1 * v + v2 * w;
    } else {
        vec3 c0 = clamp(v2p / d00, 0.0, 1.0) * e0 + v0;
        vec3 c1 = clamp((p - v1) / d11, 0.0, 1.0) * e1 + v1;
        vec3 c2 = clamp((p - v2) / d11, 0.0, 1.0) * e1 + v2;
        nearestPoint = c0;
        float dist = length(p - c0);
        float dist1 = length(p - c1);
        float dist2 = length(p - c2);
        if (dist1 < dist) {
            nearestPoint = c1;
            dist = dist1;
        }
        if (dist2 < dist) {
            nearestPoint = c2;
        }
    }

    return length(p - nearestPoint);
}

float opSmoothUnion( float d1, float d2, float k )
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}

float opSmoothSubtraction( float d1, float d2, float k )
{
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h);
}

float opSmoothIntersection( float d1, float d2, float k )
{
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) + k*h*(1.0-h);
}
