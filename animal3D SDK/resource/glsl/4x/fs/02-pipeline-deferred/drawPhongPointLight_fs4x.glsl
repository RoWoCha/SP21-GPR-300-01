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
	
	drawPhongPointLight_fs4x.glsl
	Output Phong shading components while drawing point light volume.
*/

#version 450

#define MAX_LIGHTS 1024

// ****?DONE?:
//	-> declare biased clip coordinate varying from vertex shader +
//	-> declare point light data structure and uniform block +
//	-> declare pertinent samplers with geometry data ("g-buffers") +
//	-> calculate screen-space coordinate from biased clip coord +
//		(hint: perspective divide)
//	-> use screen-space coord to sample g-buffers +
//	-> calculate view-space fragment position using depth sample +
//		(hint: same as deferred shading)
//	-> calculate final diffuse and specular shading for current light only

flat in int vInstanceID;

in vec4 vPositionBiasedClip;

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
	sPointLightData uPointLightData[MAX_LIGHTS];
};

uniform sampler2D uImage00; // diffuse atlas
uniform sampler2D uImage01; // specular atlas

uniform sampler2D uImage04; // scene texcoord
uniform sampler2D uImage05; // scene normal
//uniform sampler2D uImage06; // scene position
uniform sampler2D uImage07; // scene depth

uniform mat4 uPB_inv;		// Inverse bias-projection

//layout (location = 0) out vec4 rtFragColor;
layout (location = 0) out vec4 rtDiffuseLight;
layout (location = 1) out vec4 rtSpecularLight;

// declaration of Phong shading model
//	(implementation in "utilCommon_fs4x.glsl")
//		param diffuseColor: resulting diffuse color (function writes value)
//		param specularColor: resulting specular color (function writes value)
//		param eyeVec: unit direction from surface to eye
//		param fragPos: location of fragment in target space
//		param fragNrm: unit normal vector at fragment in target space
//		param fragColor: solid surface color at fragment or of object
//		param lightPos: location of light in target space
//		param lightRadiusInfo: description of light size from struct
//		param lightColor: solid light color
void calcPhongPoint(
	out vec4 diffuseColor, out vec4 specularColor,
	in vec4 eyeVec, in vec4 fragPos, in vec4 fragNrm, in vec4 fragColor,
	in vec4 lightPos, in vec4 lightRadiusInfo, in vec4 lightColor
);

void main()
{
	// screen-space coordinate from biased clip coord
	vec4 sceneTexcoord =  vPositionBiasedClip / vPositionBiasedClip.w;

	// sampling g-buffers
	vec4 diffuseSample = texture(uImage00, sceneTexcoord.xy);
	vec4 specularSample = texture(uImage01, sceneTexcoord.xy);

	vec4 position_screen = sceneTexcoord;
	position_screen.z = texture(uImage07, sceneTexcoord.xy).r;
	
	// view-space fragment position
	vec4 position_view = uPB_inv * position_screen;
	position_view /= position_view.w;

	vec4 normal_view = texture(uImage05, sceneTexcoord.xy);
	normal_view = normal_view * 2.0 - 1.0;

	vec4 diffuseColor = vec4(0.0);
	vec4 specularColor = vec4(0.0);

	// light radius data
	vec4 lightRadiusInfo =
		vec4(uPointLightData[vInstanceID].radius, uPointLightData[vInstanceID].radiusSq,
			uPointLightData[vInstanceID].radiusInv, uPointLightData[vInstanceID].radiusInvSq);

	// getting diffuse and specular
	calcPhongPoint(diffuseColor, specularColor,
		normalize(uPointLightData[vInstanceID].position - position_view), position_view, normal_view, diffuseSample,
		uPointLightData[vInstanceID].position, lightRadiusInfo, uPointLightData[vInstanceID].color);

	rtDiffuseLight = vec4(2.0 * vec3(diffuseColor), 1.0);
	rtSpecularLight = vec4(2.0 * vec3(specularColor), 1.0);

	//rtDiffuseLight = vec4(0.3, 0.3, 0.3, 1.0);
	//rtSpecularLight = vec4(0.3, 0.3, 0.3, 1.0);

	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	//rtFragColor = vec4(1.0, 0.0, 1.0, 1.0);
}
