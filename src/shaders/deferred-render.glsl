#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0;
uniform sampler2D u_gb1;
uniform sampler2D u_gb2;

uniform float u_Time;

uniform mat4 u_View;
uniform vec4 u_CamPos;   


void main() { 
	// read from GBuffers

	// Blinn-Phong Shading
	vec4 gb0 = texture(u_gb0, fs_UV);

	vec3 lightDir = normalize(vec3(-1, -1, 1));
	float ambient = 0.1;
	float lambert = clamp(dot(lightDir, gb0.xyz), 0.0, 1.0) + ambient; // Get the lambertian term

	vec2 ndc = (2.0 * fs_UV) - 1.0;
	vec3 modelpos = vec3(u_CamPos) + gb0.w * vec3(1,0,0) * tan(ndc.x/gb0.w) + gb0.w * vec3(0,1,0) * tan(ndc.y/gb0.w) + gb0.w * vec3(0,0,1);
	vec3 look = normalize(modelpos - vec3(u_CamPos));

	vec3 H = normalize(lightDir + look);
	float specular = pow(abs(dot(H, gb0.xyz)), 16.0);

	// Base Color
	vec4 gb2 = texture(u_gb2, fs_UV);

	vec3 col = gb2.xyz;
	col = gb2.xyz;

	// Background
	float ismesh = texture(u_gb1, fs_UV).x;
	ismesh = 1.0 - ismesh; // Set to 1 if there is no mesh here

	mat3 invtView = transpose(inverse(mat3(u_View)));
	look = invtView * vec3(0,0,1);
	vec3 right = invtView * vec3(1,0,0);
	vec3 up = invtView * vec3(0,1,0);
	vec3 raydir = normalize(gb0.w * right * tan(ndc.x/gb0.w) + gb0.w * up * tan(ndc.y/gb0.w) + gb0.w * look);

	float t = clamp(mod(u_Time / 5.0, 2.0), 0.0, 1.0);
	t = pow(4.0 * t * (1.0 - t), 4.0) + 0.01;

	vec3 backbase = step(-0.1, raydir.y) * vec3(0.2, 0.2, 0.8) * t + step(raydir.y, -0.1) * vec3(0.36, 0.6, 0.18) * (t + 0.2);	
	vec3 backcol = ismesh * backbase;

	out_Col = vec4(lambert * col + specular + backcol, 1.0);
	//out_Col = vec4(col, 1.0);
}