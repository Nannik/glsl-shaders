#version 300 es

precision mediump int;
precision mediump float;

const int MAX_LIGHTS = 8;

uniform mat4 modelMatrix;
uniform mat4 normalMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

uniform vec3 eyePositionWorld;
uniform int numLights;
uniform vec3 lightPositionsWorld[MAX_LIGHTS];

in vec3 positionModel;
in vec3 normalModel;
in vec3 tangentModel;
in vec4 color;
in vec2 texCoords;

out vec4 interpColor;
out vec2 interpTexCoords;
out vec3 interpPositionTangent;
out vec3 eyePositionTangent;
out vec3 lightPositionsTangent[MAX_LIGHTS];

void main() 
{
    interpColor = color;
    interpTexCoords = texCoords.xy;

    // Compute the world position
    vec3 positionWorld = (modelMatrix * vec4(positionModel, 1)).xyz;

    // Compute the normal in World Space
    vec3 normalWorld = normalize((normalMatrix * vec4(normalModel, 0)).xyz);

    // Compute the tangent in World Space
    vec3 tangentWorld = normalize((normalMatrix * vec4(tangentModel, 0)).xyz);
	tangentWorld = normalize(tangentWorld - dot(tangentWorld, normalWorld) * normalWorld);

    // Compute the bitangent in World Space
    vec3 bitangentWorld = cross(normalWorld, tangentWorld);

    // TBN matrix (World Space -> Tangent Space)
    mat3 TBN = transpose(mat3(tangentWorld, bitangentWorld, normalWorld));

	// Transform positions to Tangent Space
    interpPositionTangent = TBN * positionWorld;
    eyePositionTangent = TBN * eyePositionWorld;

    for (int i = 0; i < numLights; i++) {
        lightPositionsTangent[i] = TBN * lightPositionsWorld[i];
    }

    gl_Position = projectionMatrix * viewMatrix * vec4(positionWorld, 1);
}
