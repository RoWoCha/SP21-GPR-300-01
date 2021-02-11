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
	
	drawPhong_fs4x.glsl
	Output Phong shading.
*/

#version 450

// ****DONE: 
//	-> start with list from "drawLambert_fs4x"
//		(hint: can put common stuff in "utilCommon_fs4x" to avoid redundancy)
//	-> calculate view vector, reflection vector and Phong coefficient
//	-> calculate Phong shading model for multiple lights

// Resources used:
// Blue Book, p.668


// !!!PER-FRAGMENT!!! //
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
uniform sampler2D uTex_sm;

vec4 phongShadingCalc(int lightNum);

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE LIME
	//rtFragColor = vec4(0.5, 1.0, 0.0, 1.0);

	vec4 color;

	for(int i = 0; i < NUM_LIGHTS; i++)
	{
		color += vec4(vec3(phongShadingCalc(i)), 0.0);
	}

	rtFragColor = color;
	
	// DEBUGGING
	//rtFragColor = vec4(kd, kd, kd, 1.0);
}

//Function for calculation of Phong shading from one light source
vec4 phongShadingCalc(int lightNum)
{
	float distance = length(uLightPos[lightNum] - vPosition);
	vec4 lightVec = normalize(uLightPos[lightNum] - vPosition);
	vec4 normal = normalize(vNormal);

	vec4 viewVec = normalize(-vPosition);
	vec4 reflectionVec = reflect(-lightVec, normal);	

	//diffuse (Lambert) coefficient:
	float diffCoeff = max(0.0, dot(normal, lightVec));
	vec4 diffuse_color = diffCoeff * texture(uTex_dm, vTexcoord);

	//specular (Phong) coefficient
	float specCoeff = max(0.0, dot(viewVec, reflectionVec));
	specCoeff *= specCoeff;
	vec4 specular_color = specCoeff * texture(uTex_sm, vTexcoord);

	//adding attenuation
	vec4 resCoeff = (diffuse_color + specular_color) * (1.0 / (uLightRadii[lightNum] * distance * distance + 1.0));
	vec4 result = resCoeff * uLightColor[lightNum] * uColor;

	return result;
}


// !!!PER-VERTEX!!! //
/*layout (location = 0) out vec4 rtFragColor;

in vec4 vColor;

void main()
{
	rtFragColor = vColor;
}*/