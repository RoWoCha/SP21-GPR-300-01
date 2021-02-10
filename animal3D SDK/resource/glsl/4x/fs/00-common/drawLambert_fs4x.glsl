/*
	Copyright 2011-2021 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawLambert_fs4x.glsl
	Output Lambertian shading.
*/

#version 450

// ****DONE: 
//	-> declare varyings to receive lighting and shading variables
//	-> declare lighting uniforms
//		(hint: in the render routine, consolidate lighting data 
//		into arrays; read them here as arrays)
//	-> calculate Lambertian coefficient
//	-> implement Lambertian shading model and assign to output
//		(hint: coefficient * attenuation * light color * surface color)
//	-> implement for multiple lights
//		(hint: there is another uniform for light count)

// Resources used:
// 1) Blue Book, p.668
// 2) Lambertian reflectance article - https://www.learnopengles.com/tag/lambertian-reflectance/

const int NUM_LIGHTS = 4;

layout (location = 0) out vec4 rtFragColor;

in vec4 vPosition;
in vec4 vNormal;
in vec2 vTexcoord;

uniform vec4 uLightPos[NUM_LIGHTS];
uniform vec4 uLightColor[NUM_LIGHTS];
uniform float uLightRadii[NUM_LIGHTS];

uniform vec4 uColor;
uniform sampler2D uTex_dm;

vec4 lambertShadingCalc(int lightNum);

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE LIME
	//rtFragColor = vec4(0.5, 1.0, 0.0, 1.0);

	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);

	for(int i = 0; i < NUM_LIGHTS; i++)
	{
		color += vec4(vec3(lambertShadingCalc(i)), 0.0);
	}

	rtFragColor = color;
	
	// DEBUGGING
	//rtFragColor = vec4(kd, kd, kd, 1.0);
}

//Function for calculation of lambert shading from one light source
vec4 lambertShadingCalc(int lightNum)
{
	float distance = length(uLightPos[lightNum] - vPosition);
	vec4 lightVec = normalize(uLightPos[lightNum] - vPosition);
	vec4 normal = normalize(vNormal);

	//diffuse coefficient:
	float diffCoeff = max(0.0, dot(normal, lightVec));
	vec4 diffuse_color = diffCoeff * texture(uTex_dm, vTexcoord);
	
	//adding attenuation
	diffuse_color *= (1.0 / (uLightRadii[lightNum] * distance * distance + 1.0));
	vec4 result = diffuse_color * uLightColor[lightNum] * uColor;

	return result;
}