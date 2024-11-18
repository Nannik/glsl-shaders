#version 300 es

 

precision mediump float;


// INPUT FROM UNIFORMS SET WITHIN THE MAIN APPLICATION
uniform vec4 outlineColor;


// OUTPUT
out vec4 fragColor;


// This shader colors each fragment using a constant outline color passed in from 
// the main application.  You do not need to modify it.
void main() {
    fragColor = outlineColor;
}
