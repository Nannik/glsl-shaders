#version 300 es

precision mediump float;

#define POINT_LIGHT 0
#define DIRECTIONAL_LIGHT 1
const int MAX_LIGHTS = 8;

uniform vec3 eyePositionWorld;

uniform int numLights;
uniform int lightTypes[MAX_LIGHTS];
uniform vec3 lightPositionsWorld[MAX_LIGHTS];
uniform vec3 lightAmbientIntensities[MAX_LIGHTS];
uniform vec3 lightDiffuseIntensities[MAX_LIGHTS];
uniform vec3 lightSpecularIntensities[MAX_LIGHTS];

uniform vec3 kAmbient;
uniform vec3 kDiffuse;
uniform vec3 kSpecular;
uniform float shininess;

uniform sampler2D diffuseRamp; // Texture ramp for diffuse lighting
uniform sampler2D specularRamp; // Texture ramp for specular lighting

uniform int useTexture;
uniform sampler2D surfaceTexture;

in vec3 interpPositionWorld;
in vec3 interpNormalWorld;
in vec4 interpColor;
in vec2 interpTexCoords;

out vec4 fragColor;

void main() {
    // Normalize the interpolated normal
    vec3 normal = normalize(interpNormalWorld);

    // Compute view direction
    vec3 viewDir = normalize(eyePositionWorld - interpPositionWorld);

    // Initialize lighting components
    vec3 ambient = vec3(0.0);
    vec3 diffuse = vec3(0.0);
    vec3 specular = vec3(0.0);

    for (int i = 0; i < numLights; i++) {
        vec3 lightDir;

        // Determine light direction based on type
        if (lightTypes[i] == POINT_LIGHT) {
            lightDir = normalize(lightPositionsWorld[i] - interpPositionWorld);
        } else if (lightTypes[i] == DIRECTIONAL_LIGHT) {
            lightDir = normalize(lightPositionsWorld[i]);
        }

        // Ambient contribution
        ambient += lightAmbientIntensities[i] * kAmbient;

        // Diffuse contribution with ramp quantization
        float diffIntensity = max(dot(normal, lightDir), 0.0);
        vec3 diffColor = lightDiffuseIntensities[i] * kDiffuse;
        float rampedDiffuse = texture(diffuseRamp, vec2(diffIntensity, 0.0)).r; // Use ramp texture
        diffuse += rampedDiffuse * diffColor;

        // Specular contribution with ramp quantization
        if (diffIntensity > 0.0) {
            vec3 reflectDir = reflect(-lightDir, normal);
            float specIntensity = pow(max(dot(viewDir, reflectDir), 0.0), shininess);
            float rampedSpecular = texture(specularRamp, vec2(specIntensity, 0.0)).r; // Use ramp texture
            vec3 specColor = lightSpecularIntensities[i] * kSpecular;
            specular += rampedSpecular * specColor;
        }
    }

    // Combine lighting components
    vec3 finalColor = ambient + diffuse + specular;

    // If texture is used, modulate with texture color
    vec4 texColor = useTexture == 1 ? texture(surfaceTexture, interpTexCoords) : vec4(1.0);

    // Final fragment color
    fragColor = vec4(finalColor, 1.0) * texColor * interpColor;
}
