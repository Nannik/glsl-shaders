#version 300 es

 

precision mediump float;


// INPUT FROM UNIFORMS SET WITHIN THE MAIN APPLICATION

// Transforms points and vectors from Model Space to World Space (modelToWorld)
uniform mat4 modelMatrix;
// Special version of the modelMatrix to use with normal vectors
uniform mat4 normalMatrix;
// Transforms points and vectors from World Space to View Space (a.k.a. Eye Space) (worldToView) 
uniform mat4 viewMatrix;
// Transforms points and vectors from View Space to Normalized Device Coordinates (viewToNDC)
uniform mat4 projectionMatrix;

// Distance to "move" the vertices in View Space to create the outline
uniform float outlineThickness;


// INPUT FROM THE MESH WE ARE RENDERING WITH THIS SHADER

// per-vertex data, points and vectors are defined in Model Space
in vec3 positionModel;
in vec3 normalModel;
in vec4 color;
in vec2 texCoords;


// OUTPUT
// This shader only needs to calculate gl_Position and does not need to
// pass any other output variables to the rasterizer and ragment shader.


void main() 
{
    vec3 positionWorld = (modelMatrix * vec4(positionModel, 1.0)).xyz;
    vec3 normalWorld = normalize((normalMatrix * vec4(normalModel, 0.0)).xyz);
    vec3 positionView = (viewMatrix * vec4(positionWorld, 1.0)).xyz;
    vec3 normalView = normalize((viewMatrix * vec4(normalWorld, 0.0)).xyz);
    vec3 displacedPositionView = positionView + normalView * outlineThickness;

    gl_Position = projectionMatrix * vec4(displacedPositionView, 1.0);
}
