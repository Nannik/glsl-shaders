#version 300 es

precision mediump int;
precision mediump float;

#define POINT_LIGHT 0
#define DIRECTIONAL_LIGHT 1
const int MAX_LIGHTS = 8;

uniform int numLights;
uniform int lightTypes[MAX_LIGHTS];
uniform vec3 lightAmbientIntensities[MAX_LIGHTS];
uniform vec3 lightDiffuseIntensities[MAX_LIGHTS];
uniform vec3 lightSpecularIntensities[MAX_LIGHTS];

uniform vec3 kAmbient;
uniform vec3 kDiffuse;
uniform vec3 kSpecular;
uniform float shininess;

uniform int useTexture;
uniform sampler2D surfaceTexture;

uniform int useNormalMap;
uniform sampler2D normalMap;

in vec4 interpColor;
in vec2 interpTexCoords;
in vec3 interpPositionTangent;
in vec3 eyePositionTangent;
in vec3 lightPositionsTangent[MAX_LIGHTS];

out vec4 fragColor;

void main() 
{
	vec3 nTangent = vec3(0, 0, 1);
    if (useNormalMap == 1) {
        // Fetch the normal from the normal map
        vec3 normalSample = texture(normalMap, interpTexCoords).rgb;
        // Transform from [0,1] to [-1,1]
        nTangent = normalize(normalSample * 2.0 - 1.0);
    }

    vec3 vTangent = normalize(eyePositionTangent - interpPositionTangent);
    vec3 colorOutput = vec3(0.0);

    for (int i = 0; i < numLights; i++) {
        vec3 lTangent;

        if (lightTypes[i] == POINT_LIGHT) {
            lTangent = normalize(lightPositionsTangent[i] - interpPositionTangent);
        } else if (lightTypes[i] == DIRECTIONAL_LIGHT) {
            lTangent = normalize(-lightPositionsTangent[i]);
        }

		vec3 ambient = lightAmbientIntensities[i] * kAmbient;

        // Diffuse component
        float lambertian = max(dot(nTangent, lTangent), 0.0);
        vec3 diffuse = lambertian * lightDiffuseIntensities[i] * kDiffuse;

        // Specular component
        vec3 reflection = reflect(-lTangent, nTangent);
        float spec = pow(max(dot(vTangent, reflection), 0.0), shininess);
        vec3 specular = spec * lightSpecularIntensities[i] * kSpecular;

        colorOutput += diffuse + specular + ambient;
    }

    if (useTexture == 1) {
        colorOutput *= texture(surfaceTexture, interpTexCoords).rgb;
    }

    fragColor = vec4(colorOutput, interpColor.a);
}
