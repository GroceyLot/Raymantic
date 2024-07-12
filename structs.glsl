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

uniform float time;
uniform vec2 screenResolution;
uniform bool debug;
uniform vec3 lightDirection;

const float PI = 3.14159265359;
