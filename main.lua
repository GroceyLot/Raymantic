function love.load()
    targetPitch = 0
    targetYaw = 0
    scene = require("raymantic")()
    scene.sdfs[1] = [[
sdfInfo sdf(vec3 point) {
    sdfInfo info;

    vec3 modPos = mod(point, vec3(5.0));
    float sphereDist = sdfSphere(modPos - vec3(2.5), vec3(0.0), 1.0);

    // Set the sdfInfo
    info.dist = sphereDist;
    info.material.color = vec3(1.0);

    // Determine if the indices for x, y, and z axes are even or odd
    bool isEvenX = mod(floor(point.x / 5.0), 2.0) < 1.0;
    bool isEvenY = mod(floor(point.y / 5.0), 2.0) < 1.0;
    bool isEvenZ = mod(floor(point.z / 5.0), 2.0) < 1.0;

    // Make the sphere reflective if all indices are even or all are odd
    info.material.reflective = (isEvenX == isEvenY) && (isEvenY == isEvenZ);

    return info;
}]]
    scene:compileShaders()
    wspeed = 5
end

-- Linear interpolation
function lerp(a, b, t)
    return a + (b - a) * t
end

function love.wheelmoved(x, y)
    if y > 0 then
        wspeed = wspeed * 1.25
    elseif y < 0 then
        wspeed = wspeed * 0.8
    end
end

-- Normalize a vector
function normalize(v)
    local length = math.sqrt(v[1] ^ 2 + v[2] ^ 2 + v[3] ^ 2)
    return {v[1] / length, v[2] / length, v[3] / length}
end

-- Vector subtraction
function vectorSubtract(a, b)
    return {a[1] - b[1], a[2] - b[2], a[3] - b[3]}
end

function love.update(dt)
    local speed = wspeed * dt
    if love.keyboard.isDown("lshift") then
        speed = speed * 10
    end
    if love.keyboard.isDown("rshift") then
        speed = speed / 10
    end

    -- Update camera direction vectors
    local cosPitch = math.cos(scene.camera.pitch)
    local sinPitch = math.sin(scene.camera.pitch)
    local cosYaw = math.cos(scene.camera.yaw)
    local sinYaw = math.sin(scene.camera.yaw)

    local forward = normalize({cosPitch * sinYaw, -sinPitch, cosPitch * cosYaw})
    local right = normalize({cosYaw, 0, -sinYaw})
    local up = normalize({0, -1, 0})

    if love.keyboard.isDown("w") then
        scene.camera.pos = vectorSubtract(scene.camera.pos, {forward[1] * speed, forward[2] * speed, forward[3] * speed})
    end
    if love.keyboard.isDown("s") then
        scene.camera.pos = vectorSubtract(scene.camera.pos, {-forward[1] * speed, -forward[2] * speed, -forward[3] * speed})
    end
    if love.keyboard.isDown("a") then
        scene.camera.pos = vectorSubtract(scene.camera.pos, {right[1] * speed, right[2] * speed, right[3] * speed})
    end
    if love.keyboard.isDown("d") then
        scene.camera.pos = vectorSubtract(scene.camera.pos, {-right[1] * speed, -right[2] * speed, -right[3] * speed})
    end
    if love.keyboard.isDown("q") then
        scene.camera.pos = vectorSubtract(scene.camera.pos, {up[1] * speed, up[2] * speed, up[3] * speed})
    end
    if love.keyboard.isDown("e") then
        scene.camera.pos = vectorSubtract(scene.camera.pos, {-up[1] * speed, -up[2] * speed, -up[3] * speed})
    end
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if love.keyboard.isDown("r") and love.timer.getTime() - lastChange > 1 then
        debug = not debug
        lastChange = love.timer.getTime()
    end

    -- Mouse movement for camera rotation
    local mouseSensitivity = 0.002
    local mouseX, mouseY = love.mouse.getPosition()

    -- Recalculate the center of the screen in case the window size changed
    centerX = love.graphics.getWidth() / 2
    centerY = love.graphics.getHeight() / 2

    local epsilon = 2 -- Tolerance in pixels

    -- Only calculate deltas if the mouse is not already near the center
    if math.abs(mouseX - centerX) > epsilon or math.abs(mouseY - centerY) > epsilon then
        local deltaX = mouseX - centerX
        local deltaY = mouseY - centerY

        targetYaw = targetYaw - deltaX * mouseSensitivity
        targetPitch = targetPitch + deltaY * mouseSensitivity

        -- Clamp pitch to avoid flipping upside down
        targetPitch = math.max(-math.pi / 2 + 0.01, math.min(math.pi / 2 - 0.01, targetPitch))

        -- Reset mouse to the center of the window
        love.mouse.setPosition(centerX, centerY)
    end

    love.mouse.setVisible(false)

    -- Smooth the yaw and pitch transitions
    local smoothFactor = 8 * dt
    scene.camera.yaw = lerp(scene.camera.yaw, targetYaw, smoothFactor)
    scene.camera.pitch = lerp(scene.camera.pitch, targetPitch, smoothFactor)

    frameTime = dt * 1000
    fps = math.floor(1 / dt)
end

function love.draw()
    local render = scene:startRender()
    render.render()
end
