#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962
#define E 2.71828

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_gb3;
uniform vec3 u_CamPos;
uniform vec3 u_CamTarget;

float stdev2(float rad) { // Calculates the squared standard deviation for (1D) gaussian kernel of width rad
    float sum = 0.0;
    float ave = rad / 2.0;
    for(float x = -rad; x <= rad; x++) {
        sum += pow(abs(x) - ave, 2.0);
    }
    return sum / (2.0 * rad + 1.0);
}

// Gaussian depth of field blur
void main() {
    ivec2 texDim = textureSize(u_frame, 0);
    vec2 offset = vec2(1.0 / float(texDim.x), 1.0 / float(texDim.y));
    float ismesh = texture(u_gb3, fs_UV).x;
    float depth = abs(texture(u_gb3, fs_UV).w); // Depth from initial gbuffer pass
    float targetDist = length(u_CamPos - u_CamTarget); // Add epsilon so w
	vec3 color = texture(u_frame, fs_UV).xyz;

    //if(ismesh != 1.0) { // Got rid of this because bluring the sky/grass looks awful
    //    depth == 1000.0;
    //}

    if (ismesh == 1.0) {
        float diff = floor(abs(depth - targetDist) * 2.0) + 1.0;
        color = vec3(0.0);
        float stDev = stdev2(diff);
        float sum = 0.0;
        for(float x = -diff; x <= diff + EPS; x++) {
            float k = (1.0 / sqrt(2.0 * PI * stDev));
            k *= exp(-(pow(x, 2.0) / (2.0 * stDev)));
            sum += k;
        }
        for(float x = -diff; x <= diff + EPS; x++) {
            float k = (1.0 / sqrt(2.0 * PI * stDev));
            k *= exp(-(pow(x, 2.0) / (2.0 * stDev)));
            k /= sum; // Normalize the kernel
            color += k * texture(u_frame, vec2(fs_UV.x + (x * offset.x), fs_UV.y)).xyz;
        }
        for(float y = -diff; y <= diff + EPS; y++) {
            float k = (1.0 / sqrt(2.0 * PI * stDev));
            k *= exp(-(pow(y, 2.0) / (2.0 * stDev)));
            k /= sum; // Normalize the kernel
            color += k * texture(u_frame, vec2(fs_UV.x, fs_UV.y + (y * offset.y))).xyz;
        }
    }
    

	out_Col = vec4(color, 1.0);
}
