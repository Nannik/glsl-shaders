#version 300 es

 

precision mediump float;


// INPUT FROM UNIFORMS SET IN THE MAIN APPLICATION
uniform int useTexture;
uniform sampler2D surfaceTexture;


// INPUT FROM THE VERTEX SHADER AFTER INTERPOLATION ACROSS TRIANGLES BY THE RASTERIZER
in vec4 interpColor;
in vec2 interpTexCoords;


// OUTPUT
out vec4 fragColor;


void main() {
    // PART 2.0: In class example
	vec4 texColor = useTexture == 1 ? texture(surfaceTexture, interpTexCoords) : vec4(1.0);
    fragColor = interpColor * texColor;
}
