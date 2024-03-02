#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
out vec4 fragColor;

void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    // Shader toy uses [fragCoord] but for flutter it's 
    vec2 uv = FlutterFragCoord().xy/iResolution.xy;

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

    // Output to screen
    fragColor = vec4(col,1.0);
}