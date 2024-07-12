return function()
    return {
        camera = {
            pos = {0, 0, 0},
            yaw = 0,
            pitch = 0,
            fov = 70
        },
        rendering = {
            quality = {
                marches = 1000,
                bounces = 10
            },
            fog = {
                start = 100,
                ["end"] = 400,
                enabled = true
            },
            gooch = {
                enabled = true,
                coolAmount = 0.25,
                lightDirection = {-1, -1, -1}
            },
            ambient = {
                enabled = true,
                amount = 1
            }
        },
        debug = false,
        sdfs = {[[
sdfInfo sdf(vec3 point) {
    sdfInfo info;
    info.dist = sdfSphere(point, vec3(0.0), 1.0);
    info.material.color = vec3(1.0);
    return info;
}
        ]]},
        sdf = 1,
        sky = [[
vec3 sky(vec3 direction) {
    vec3 horizonColor = vec3(1.0, 0.8, 0.5); // Orange for the horizon
    vec3 midSkyColor1 = vec3(0.7, 0.7, 0.7); // Light blue for the mid sky
    vec3 midSkyColor2 = vec3(0.2, 0.6, 1.0); // Light blue for the mid sky
    vec3 topSkyColor = vec3(0.1, 0.1, 0.7); // Dark blue for the top sky
    vec3 sunColor = vec3(1.0, 0.9, 0.7); // Yellowish color for the sun

    // Convert sun angles to a direction vector
    vec3 sunDirection = normalize(lightDirection);

    float t = clamp((-direction.y + 1.0) / 2.0, 0.0, 1.0);
    vec3 skyColor;

    if (t < 0.47) {
        // Blend from horizon to mid sky with a smoother transition
        skyColor = mix(horizonColor, midSkyColor1, smoothstep(0.0, 0.47, t));
    } else if (t < 0.53) {
        // Blend from mid sky1 to mid sky2 for a smoother middle transition
        skyColor = mix(midSkyColor1, midSkyColor2, smoothstep(0.47, 0.53, t));
    } else {
        // Blend from mid sky2 to top sky with a smoother transition
        skyColor = mix(midSkyColor2, topSkyColor, smoothstep(0.53, 1.0, t));
    }
    
    // Calculate sun influence based on dot product
    float sunInfluence = exp(-pow(acos(dot(direction, sunDirection)) * 12.5, 8.0));
    skyColor = mix(skyColor, sunColor, sunInfluence);

    return skyColor;
}
        ]],
        shader = nil,
        compileShaders = function(self)
            local shaderCode = love.filesystem.read("shader.glsl")
            local globalsCode = love.filesystem.read("globals.glsl")
            local structsCode = love.filesystem.read("structs.glsl")
            local sdf = self.sdfs[self.sdf]
            local sky = self.sky
            local fullCode = globalsCode .. structsCode .. sky .. sdf .. shaderCode
            self.shader = love.graphics.newShader(fullCode)
        end,
        startRender = function(self)
            if self.shader then
                local function rotationMatrix()
                    local cosPitch = math.cos(self.camera.pitch)
                    local sinPitch = math.sin(self.camera.pitch)
                    local cosYaw = math.cos(self.camera.yaw)
                    local sinYaw = math.sin(self.camera.yaw)

                    return {{cosYaw, 0.0, -sinYaw}, {sinYaw * sinPitch, cosPitch, cosYaw * sinPitch},
                            {sinYaw * cosPitch, -sinPitch, cosPitch * cosYaw}}
                end

                return {
                    sendSdf = function(...)
                        return self.shader:send(...)
                    end,
                    render = function()
                        self.shader:send("screenResolution", {love.graphics.getWidth(), love.graphics.getHeight()})
                        self.shader:send("numMarches", math.floor(self.rendering.quality.marches))
                        self.shader:send("fogInfo", {math.floor(self.rendering.fog.start), math.floor(self.rendering.fog["end"])})
                        self.shader:send("enableFog", self.rendering.fog.enabled)
                        self.shader:send("enableCelShading", self.rendering.ambient.enabled)
                        self.shader:send("enableGoochShading", self.rendering.gooch.enabled)
                        self.shader:send("goochCoolAmount", self.rendering.gooch.coolAmount)
                        self.shader:send("shading", self.rendering.ambient.amount)
                        self.shader:send("reflectionLimit", math.floor(self.rendering.quality.bounces))
                        self.shader:send("lightDirection", self.rendering.gooch.lightDirection)
                        self.shader:send("cameraPosition", self.camera.pos)
                        self.shader:send("time", love.timer.getTime())
                        self.shader:send("rotationMatrix", "column", rotationMatrix())
                        self.shader:send("debug", self.debug)
                        self.shader:send("fov", math.floor(self.camera.fov))
                        love.graphics.setShader(self.shader)
                        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
                        love.graphics.setShader()
                    end
                }
            else
                return nil
            end
        end
    }
end
