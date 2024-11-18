#version 300 es



// Normal mapping based on the approach described in
// https://learnopengl.com/Advanced-Lighting/Normal-Mapping

precision mediump int;
precision mediump float;

// max number of simultaneous lights handled by this shader
const int MAX_LIGHTS = 8;


// INPUT FROM UNIFORMS SET IN THE MAIN APPLICATION

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
uniform vec3 lightPositionsWorld[MAX_LIGHTS];


// INPUT FROM THE MESH WE ARE RENDERING WITH THIS SHADER

// per-vertex data, points and vectors are defined in Model Space
in vec3 positionModel;
in vec3 normalModel;
in vec3 tangentModel;
in vec4 color;
in vec2 texCoords;


// OUTPUT TO RASTERIZER TO INTERPOLATE ACROSS TRIANGLES AND SEND TO FRAGMENT SHADERS

out vec4 interpColor;
out vec2 interpTexCoords;
out vec3 interpPositionTangent;
out vec3 eyePositionTangent;
out vec3 lightPositionsTangent[MAX_LIGHTS];

void main() 
{
    interpColor = color;
    interpTexCoords = texCoords.xy;

    vec3 positionWorld = (modelMatrix * vec4(positionModel, 1)).xyz;

    vec3 N = normalize((normalMatrix * vec4(normalModel, 0)).xyz);
    vec3 T = normalize((normalMatrix * vec4(tangentModel, 0)).xyz);
	T = normalize(T - dot(T, N) * N);
    vec3 B = cross(N, T);

    mat3 TBN = transpose(mat3(T, B, N));

    interpPositionTangent = TBN * positionWorld;
    eyePositionTangent = TBN * eyePositionWorld;

    for (int i = 0; i < numLights; i++) {
        lightPositionsTangent[i] = TBN * lightPositionsWorld[i];
    }

    gl_Position = projectionMatrix * viewMatrix * vec4(positionWorld, 1);
}
