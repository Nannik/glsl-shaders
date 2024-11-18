#version 300 es



precision mediump float;

// constants used to indicate the type of each light
#define POINT_LIGHT 0
#define DIRECTIONAL_LIGHT 1

// max number of simultaneous lights handled by this shader
const int MAX_LIGHTS = 8;


// INPUT FROM UNIFORMS SET WITHIN THE MAIN APPLICATION

// Transforms points and vectors from Model Space to World Space (modelToWorld)
uniform mat4 modelMatrix;
// Special version of the modelMatrix to use with normal vectors
uniform mat4 normalMatrix;
// Transforms points and vectors from World Space to View Space (a.k.a. Eye Space) (worldToView) 
uniform mat4 viewMatrix;
// Transforms points and vectors from View Space to Normalized Device Coordinates (viewToNDC)
uniform mat4 projectionMatrix;

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


// INPUT FROM THE MESH WE ARE RENDERING WITH THIS SHADER

// per-vertex data, points and vectors are defined in Model Space
in vec3 positionModel;
in vec3 normalModel;
in vec4 color;
in vec2 texCoords;


// OUTPUT TO RASTERIZER TO INTERPOLATE ACROSS TRIANGLES AND SEND TO FRAGMENT SHADERS

out vec4 interpColor;
out vec2 interpTexCoords;


void main()  {
    vec3 positionWorld = (modelMatrix * vec4(positionModel, 1.0)).xyz;
    vec3 normalWorld = normalize((normalMatrix * vec4(normalModel, 0.0)).xyz);
    
    vec3 viewDir = normalize(eyePositionWorld - positionWorld);

    vec3 ambient = vec3(0.0);
    vec3 diffuse = vec3(0.0);
    vec3 specular = vec3(0.0);

    for (int i = 0; i < numLights; i++) {
        vec3 lightDir;

        if (lightTypes[i] == POINT_LIGHT) {
            lightDir = normalize(lightPositionsWorld[i] - positionWorld);
        } else if (lightTypes[i] == DIRECTIONAL_LIGHT) {
            lightDir = normalize(-lightPositionsWorld[i]); // Directional lights use direction vector
        }

        ambient += lightAmbientIntensities[i] * kAmbient;

        float diffIntensity = max(dot(normalWorld, lightDir), 0.0);
        diffuse += diffIntensity * lightDiffuseIntensities[i] * kDiffuse;

        if (diffIntensity > 0.0) {
            vec3 reflectDir = reflect(-lightDir, normalWorld);
            float specIntensity = pow(max(dot(viewDir, reflectDir), 0.0), shininess);
            specular += specIntensity * lightSpecularIntensities[i] * kSpecular;
        }
    }

    vec3 finalColor = ambient + diffuse + specular;
    interpColor = vec4(finalColor, 1.0);

    interpTexCoords = texCoords;

    gl_Position = projectionMatrix * viewMatrix * vec4(positionWorld, 1.0);
}
