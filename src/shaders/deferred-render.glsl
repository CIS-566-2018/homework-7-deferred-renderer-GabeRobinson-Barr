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
uniform vec3 u_CamPos;   


void main() { 
	// Read from Gbuffers
	vec4 gb0 = texture(u_gb0, fs_UV);

	// Background
	float ismesh = texture(u_gb1, fs_UV).x;
	ismesh = 1.0 - ismesh; // Set to 1 if there is no mesh here

	mat3 invtView = transpose(inverse(mat3(u_View)));
	vec3 look = invtView * vec3(0,0,1);
	vec3 right = invtView * vec3(1,0,0);
	vec3 up = invtView * vec3(0,1,0);
	vec2 ndc = (2.0 * fs_UV) - 1.0;
	vec3 raydir = normalize(gb0.w * right * tan(ndc.x/gb0.w) + gb0.w * up * tan(ndc.y/gb0.w) + gb0.w * look);

	float t = clamp(mod(u_Time / 5.0, 2.0), 0.0, 1.0);
	t = pow(4.0 * t * (1.0 - t), 4.0) + 0.01;

	// Moon/Sun
	float moont = clamp(fract(u_Time / 5.0), 0.1, 0.9);
	vec2 moonpos = vec2((moont - 0.5) * 2.0, 1.5 * ((4.0 * moont * (1.0 - moont)) - 0.36) - 0.2);
	float dist = length(moonpos - raydir.xy);

	vec3 backbase = step(-0.1, raydir.y) * vec3(0.16, 0.16, 0.7) * t + step(raydir.y, -0.1) * vec3(0.3, 0.5, 0.12) * (t + 0.2);
	if(dist <= 0.1 && raydir.y > -0.1 && raydir.z >= 0.0) {
		float daynight = mod(u_Time / 5.0, 2.0);
		backbase = step(1.0, daynight) * vec3(0.9,0.9,0.9) + step(daynight, 1.0) * vec3(0.99, 0.70, 0.08);
	}
	vec3 backcol = ismesh * backbase;


	// Blinn-Phong Shading

	vec3 lightDir = normalize(mat3(u_View) * vec3(moonpos, -1)); // Light should come from the moon/sun
	float ambient = 0.05;
	float lambert = clamp(dot(lightDir, normalize(gb0.xyz)), 0.0, 1.0) + ambient; // Get the lambertian term

	vec3 modelpos = vec3(u_CamPos) + gb0.w * vec3(1,0,0) * tan(ndc.x/gb0.w) + gb0.w * vec3(0,1,0) * tan(ndc.y/gb0.w) + gb0.w * vec3(0,0,1);
	look = normalize(mat3(u_View) * (modelpos - vec3(u_CamPos)));

	vec3 H = normalize(lightDir + look);
	float specular = pow(max(dot(normalize(gb0.xyz), H), 0.0), 30.0) *  pow(4.0 * moont * (1.0 - moont), 8.0); // Scale specular down by how high the light is

	// Base Color
	vec4 gb2 = texture(u_gb2, fs_UV);

	vec3 col = gb2.xyz;
	col = gb2.xyz;

	

	vec3 meshcol = col * lambert;

#define BLINN_PHONG
#ifdef BLINN_PHONG
	meshcol += specular;
#endif

	meshcol = meshcol * (1.0 - ismesh);

	out_Col = vec4(meshcol + backcol, 1.0);

}