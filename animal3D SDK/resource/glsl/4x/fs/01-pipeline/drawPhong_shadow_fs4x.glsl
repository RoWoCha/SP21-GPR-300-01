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
	
	drawPhong_shadow_fs4x.glsl
	Output Phong shading with shadow mapping.
*/

#version 450

// ****TO-DO:
// 1) Phong shading
//	-> identical to outcome of last project
// 2) shadow mapping
//	-> declare shadow map texture
//	-> declare shadow coordinate varying
//	-> perform manual "perspective divide" on shadow coordinate
//	-> perform "shadow test" (explained in class)

// Info sources: Blue Book ("Casting Shadows" pp.648-654)
// Phong shader taken from https://github.com/RoWoCha/SP21-GPR-300-01/blob/project1_egor/animal3D%20SDK/resource/glsl/4x/fs/00-common/drawPhong_fs4x.glsl

layout (location = 0) out vec4 rtFragColor;
layout (binding = 0) uniform sampler2D uTex_shadow;

in vec4 vPosition;
in vec4 vNormal;
in vec2 vTexcoord;
in vec4 vShadowCoord;

uniform int uCount;

uniform vec4 uColor;
uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;

// simple point light
struct sPointLightData
{
	vec4 position;					// position in rendering target space
	vec4 worldPos;					// original position in world space
	vec4 color;						// RGB color with padding
	float radius;					// radius (distance of effect from center)
	float radiusSq;					// radius squared (if needed)
	float radiusInv;				// radius inverse (attenuation factor)
	float radiusInvSq;				// radius inverse squared (attenuation factor)
};

uniform ubLight
{
	sPointLightData uPointLightData[4];
};

vec4 phongShadingCalc(int lightNum);

void main()
{
	vec4 color;

	//Iterating through light sources
	for(int i = 0; i < uCount; i++)
	{
		color += vec4(vec3(phongShadingCalc(i)), 0.0);
	}

	rtFragColor = textureProj(uTex_shadow, vShadowCoord) * color;	
}

//Function for calculation of Phong shading from one light source
vec4 phongShadingCalc(int lightNum)
{
	float distance = length(uPointLightData[lightNum].position - vPosition);
	vec4 lightVec = normalize(uPointLightData[lightNum].position - vPosition);
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
	vec4 resCoeff = (diffuse_color + specular_color) * (2.0 / (uPointLightData[lightNum].radiusInv * distance * distance + 1.0));
	vec4 result = resCoeff * uPointLightData[lightNum].color * uColor;

	return result;
}
