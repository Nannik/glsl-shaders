#version 300 es

 

precision mediump float;


// INPUT FROM UNIFORMS SET IN THE MAIN APPLICATION

// Transforms points and vectors from Model Space to World Space (modelToWorld)
uniform mat4 modelMatrix;
// Special version of the modelMatrix to use with normal vectors
uniform mat4 normalMatrix;
// Transforms points and vectors from World Space to View Space (a.k.a. Eye Space) (worldToView) 
uniform mat4 viewMatrix;
// Transforms points and vectors from View Space to Normalized Device Coordinates (viewToNDC)
uniform mat4 projectionMatrix;


// INPUT FROM THE MESH THIS VERTEX SHADER IS RUNNING ON

// per-vertex data, points and vectors are defined in Model Space
in vec3 positionModel;
in vec3 normalModel;
in vec4 color;
in vec2 texCoords;


// OUTPUT TO RASTERIZER TO INTERPOLATE ACROSS TRIANGLES AND SEND TO FRAGMENT SHADERS

out vec3 interpPositionWorld;
out vec3 interpNormalWorld;
out vec4 interpColor;
out vec2 interpTexCoords;


void main() 
{
    vec3 positionWorld = (modelMatrix * vec4(positionModel, 1.0)).xyz;
    vec3 normalWorld = normalize((normalMatrix * vec4(normalModel, 0.0)).xyz);

    interpPositionWorld = positionWorld;
    interpNormalWorld = normalWorld;

    interpColor = color;
    interpTexCoords = texCoords;

    gl_Position = projectionMatrix * viewMatrix * vec4(positionWorld, 1.0);
}
