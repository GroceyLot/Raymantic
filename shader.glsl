uniform ivec2 fogInfo;
uniform bool enableFog;
uniform bool enableCelShading;
uniform bool enableGoochShading;
uniform float goochCoolAmount;
uniform float shading;
uniform vec3 cameraPosition;
uniform int numMarches;
uniform mat3 rotationMatrix;
uniform int reflectionLimit;
uniform int fov;

const float EPSILON = 0.0001;

float sdfd(vec3 point) {
    return sdf(point).dist;
}

vec3 calculateNormal(vec3 p) {
    vec3 xOffset = vec3(EPSILON, 0.0, 0.0);
    vec3 yOffset = vec3(0.0, EPSILON, 0.0);
    vec3 zOffset = vec3(0.0, 0.0, EPSILON);
    
    float dx = sdfd(p + xOffset) - sdfd(p - xOffset);
    float dy = sdfd(p + yOffset) - sdfd(p - yOffset);
    float dz = sdfd(p + zOffset) - sdfd(p - zOffset);
    
    vec3 normal = normalize(vec3(dx, dy, dz));
    
    return normal;
}

hitInfo rayMarching(vec3 rayOrigin, vec3 rayDirection) {
    float distTraveled = 0.0;
    hitInfo info;
    info.minDist = 1e10;
    info.hit = false;
    info.avgDist = 0.0;

    for (int i = 0; i < numMarches; i++) {
        vec3 currentPoint = rayOrigin + rayDirection * distTraveled;
        sdfInfo sdfInfoCurrent = sdf(currentPoint);
        float dist = sdfInfoCurrent.dist;

        info.minDist = min(dist, info.minDist);
        info.numIterations = i;

        if (dist < EPSILON) {
            info.material = sdfInfoCurrent.material;
            info.hit = true;
            break;
        }

        distTraveled += dist * (1.0 + EPSILON);

        info.avgDist += dist;
        info.avgDist *= 0.5;

        if (distTraveled > fogInfo.y) {
            break;
        }
    }

    info.fullDist = distTraveled;
    return info;
}

float easeInSine(float x, float factor) {
    return 1.0 - cos((x * PI) / 2.0) * factor;
}

float easeOutSine(float x) {
    return sin((x * PI) / 2.0);
}

vec3 applyFog(vec3 color, vec3 skyColor, float fullDist, float fogStart, float fogEnd) {
    float fogFactor = clamp((fullDist - fogStart) / (fogEnd - fogStart), 0.0, 1.0);
    fogFactor = easeOutSine(fogFactor);
    return mix(color, skyColor, fogFactor);
}

float goochShading(vec3 normal, vec3 surfaceColor) {
    float NdotL = dot(normal, normalize(lightDirection));
    float goochAmount = mix(goochCoolAmount, 1.0, (NdotL + 1.0) * 0.5);

    return goochAmount;
}

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screenCoords) {
    float rfov = radians(float(fov));
    float aspectRatio = screenResolution.x / screenResolution.y;
    float scale = tan(rfov * 0.5);

    vec2 normalizedCoords = ((screenCoords / screenResolution) * 2.0 - 1.0) * vec2(aspectRatio, 1.0) * scale;
    vec3 rayOrigin = cameraPosition;
    vec3 rayDirection = normalize(vec3(normalizedCoords, -1.0));
    rayDirection = normalize(rotationMatrix * rayDirection);

    vec3 skyColor = sky(rayDirection);

    vec3 finalColor = vec3(0.0);
    vec3 currentColor = vec3(1.0);
    vec3 currentRayOrigin = rayOrigin;
    vec3 currentRayDirection = rayDirection;

    for (int reflectionCount = 0; reflectionCount <= reflectionLimit; reflectionCount++) {
        hitInfo info = rayMarching(currentRayOrigin, currentRayDirection); 

        if (!info.hit) {
            finalColor += currentColor * sky(currentRayDirection);
            break;
        }

        vec3 shadedColor = finalColor + currentColor * info.material.color;

        if (enableGoochShading) {
            vec3 intersectionPoint = currentRayOrigin + currentRayDirection * info.fullDist;
            vec3 normal = calculateNormal(intersectionPoint);
            shadedColor *= goochShading(normal, shadedColor);
        }
            
        if (enableCelShading) {
            float factor = float(numMarches) * 0.01 * shading;
            float celShading = easeInSine(clamp(1.0 - (float(info.numIterations) / numMarches), 0.0, 1.0), factor);
            shadedColor *= vec3(celShading);
        }

        if (enableFog) {
            shadedColor = applyFog(shadedColor, skyColor, info.fullDist, float(fogInfo.x), float(fogInfo.y));
        }
        
        if (info.material.reflective) {
            vec3 intersectionPoint = currentRayOrigin + currentRayDirection * info.fullDist;
            vec3 normal = calculateNormal(intersectionPoint);
            vec3 reflectDirection = reflect(currentRayDirection, normal);
            currentRayOrigin = intersectionPoint + normal * 0.01;
            currentRayDirection = reflectDirection;
            currentColor *= info.material.color;
        } else {
            finalColor = shadedColor;
            break;
        }

        finalColor = clamp(finalColor, 0.0, 1.0);
    }
    
    return vec4(finalColor.rgb, debug ? clamp(time, 1.0, 1.0) : 1.0);
}
