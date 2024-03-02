#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
out vec4 fragColor;

vec3 palette( float t ) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263,0.416,0.557);

    return a + b*cos( 6.28318*(c*t+d) );
}

float linearColor(float val) {
if(val <= 0.04045) {
   return (val / 12.92);
} else {
    return pow((( val + 0.055)/1.055),2.4);
}
}

/* 
 vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);
    
    for (float i = 0.0; i < 4.0; i++) {
        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(uv0));

        vec3 col = palette(length(uv0) + i*.4 + iTime*.4);

        d = sin(d*8. + iTime)/8.;
        d = abs(d);

        d = pow(0.01 / d, 1.2);

        finalColor += col * d;
    }

    fragColor = vec4(finalColor, 1.0);

 */

void main()
{
    vec2 fragCoord = FlutterFragCoord();
 vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec4 finalColor = vec4(0.0, 0.0, 0.0, 0.0);
    
    for (float i = 0.0; i < 4.0; i++) {
        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(uv0));

        vec3 col = palette(length(uv0) + i*.4 + iTime*.4);

        d = sin(d*8. + iTime)/8.;
        d = abs(d);

        d = pow(0.01 / d, 1.2);

        vec3 newColor = col * d;
/* Get the luminance of a new color, And make it that colors opacity! */
float linearR = linearColor(newColor.r);
float linearG = linearColor(newColor.g);
float linearB = linearColor(newColor.b);

float l = (0.2126 * linearR + 0.7152 * linearG + 0.0722 * linearB);

if(l < 0.01) {
finalColor += vec4(newColor, l);
} else {
finalColor += vec4(newColor, 1);

}



        // float blackThreshold = 0.10;
        // if(newColor.x < blackThreshold && newColor.y < blackThreshold && newColor.z < blackThreshold) {
        //     finalColor += (vec4(newColor, 0));
        // } else {
        //     finalColor += (vec4(newColor, 1.0));
        // }
    }

    fragColor = finalColor;
}