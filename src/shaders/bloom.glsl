#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_bloom; // Holds the colors that are greater than intensity 1. Black otherwise
uniform float u_Time;

#define PI 3.1415962


float stdev2(float rad) { // Calculates the squared standard deviation for (1D) gaussian kernel of width rad
    float sum = 0.0;
    float ave = rad / 2.0;
    for(float x = -rad; x <= rad; x++) {
        sum += pow(abs(x) - ave, 2.0);
    }
    return sum / (2.0 * rad + 1.0);
}

void main() {
	vec3 color = vec3(0.0);

    ivec2 texDim = textureSize(u_bloom, 0);
    vec2 offset = vec2(1.0 / float(texDim.x), 1.0 / float(texDim.y)); // Get the UV offset of each pixel

    float rad = 100.0;
    float stDev = stdev2(100.0); // Gaussian blur of radius 100
    float sum = 0.0;
    for(float x = -rad; x <= rad; x++) { // Get the sum of the kernel so we can normalize
        for(float y = -rad; y <= rad; y++) {
            float k = (1.0 / sqrt(2.0 * PI * stDev));
            k *= exp(-(pow(x, 2.0) / (2.0 * stDev)));
            sum += k;
        }
    }
    for(float x = -rad; x <= rad; x++) {
        float k = (1.0 / sqrt(2.0 * PI * stDev));
        k *= exp(-(pow(x, 2.0) / (2.0 * stDev)));
        k /= sum; // Normalize the kernel
        color += k * texture(u_bloom, vec2(fs_UV.x + (x * offset.x), fs_UV.y)).xyz;
    }
    for(float y = -rad; y <= rad; y++) {
        float k = (1.0 / sqrt(2.0 * PI * stDev));
        k *= exp(-(pow(y, 2.0) / (2.0 * stDev)));
        k /= sum; // Normalize the kernel
        color += k * texture(u_bloom, vec2(fs_UV.x, fs_UV.y + (y * offset.y))).xyz;
    }

    color *= 5.0; // Scale up the brightness of the bloom

    color += texture(u_frame, fs_UV).xyz * 0.5;
    
	
	out_Col = vec4(color, 1.0);
}