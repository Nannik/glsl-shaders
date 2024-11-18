#version 300 es

 

precision mediump float;

// constants used to indicate the type of each light
#define POINT_LIGHT 0
#define DIRECTIONAL_LIGHT 1

// max number of simultaneous lights handled by this shader
const int MAX_LIGHTS = 8;


// INPUT FROM UNIFORMS SET WITHIN THE MAIN APPLICATION

// position of the camera in world coordinates
uniform vec3 eyePositionWorld;

// properties of the lights in the scene
uniform int numLights;
uniform int lightTypes[MAX_LIGHTS];
uniform vec3 lightPositionsWorld[MAX_LIGHTS];
uniform vec3 lightAmbientIntensities[MAX_LIGHTS];
uniform vec3 lightDiffuseIntensities[MAX_LIGHTS];
uniform vec3 lightSpecularIntensities[MAX_LIGHTS];

// material properties (coefficents of reflection)
uniform vec3 kAmbient;
uniform vec3 kDiffuse;
uniform vec3 kSpecular;
uniform float shininess;

// texture data
uniform int useTexture;
uniform sampler2D surfaceTexture;


// INPUT FROM THE VERTEX SHADER AFTER INTERPOLATION ACROSS TRIANGLES BY THE RASTERIZER

in vec3 interpPositionWorld;
in vec3 interpNormalWorld;
in vec4 interpColor;
in vec2 interpTexCoords;


// OUTPUT

out vec4 fragColor;


void main() {
    vec3 normal = normalize(interpNormalWorld);
    vec3 viewDir = normalize(eyePositionWorld - interpPositionWorld);

    vec3 ambient = vec3(0.0);
    vec3 diffuse = vec3(0.0);
    vec3 specular = vec3(0.0);

    for (int i = 0; i < numLights; i++) {
        vec3 lightDir;

        if (lightTypes[i] == POINT_LIGHT) {
            lightDir = normalize(lightPositionsWorld[i] - interpPositionWorld);
        } else if (lightTypes[i] == DIRECTIONAL_LIGHT) {
            lightDir = normalize(-lightPositionsWorld[i]);
        }

        ambient += lightAmbientIntensities[i] * kAmbient;

        float diffIntensity = max(dot(normal, lightDir), 0.0);
        diffuse += diffIntensity * lightDiffuseIntensities[i] * kDiffuse;

        if (diffIntensity > 0.0) {
            vec3 reflectDir = reflect(-lightDir, normal);
            float specIntensity = pow(max(dot(viewDir, reflectDir), 0.0), shininess);
            specular += specIntensity * lightSpecularIntensities[i] * kSpecular;
        }
    }

    vec3 finalColor = ambient + diffuse + specular;
    vec4 texColor = useTexture == 1 ? texture(surfaceTexture, interpTexCoords) : vec4(1.0);

    fragColor = vec4(finalColor, 1.0) * texColor * interpColor;
}
