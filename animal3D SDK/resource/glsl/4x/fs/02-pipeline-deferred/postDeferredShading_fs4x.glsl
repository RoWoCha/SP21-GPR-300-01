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
	
	postDeferredShading_fs4x.glsl
	Calculate full-screen deferred Phong shading.
*/

// Edited by Egor Fesenko

#version 450

#define MAX_LIGHTS 1024

// ****DONE:
//	-> this one is pretty similar to the forward shading algorithm (Phong NM) 
//		except it happens on a plane, given images of the scene's geometric 
//		data (the "g-buffers"); all of the information about the scene comes 
//		from screen-sized textures, so use the texcoord varying as the UV
//	-> declare point light data structure and uniform block
//	-> declare pertinent samplers with geometry data ("g-buffers")
//	-> use screen-space coord (the inbound UV) to sample g-buffers
//	-> calculate view-space fragment position using depth sample
//		(hint: modify screen-space coord, use appropriate matrix to get it 
//		back to view-space, perspective divide)
//	-> calculate and accumulate final diffuse and specular shading

in vec4 vTexcoord_atlas;

uniform int uCount;

uniform sampler2D uImage00; // diffuse atlas
uniform sampler2D uImage01; // specular atlas

uniform sampler2D uImage04; // scene texcoord
uniform sampler2D uImage05; // scene normal
//uniform sampler2D uImage06; // scene position
uniform sampler2D uImage07; // scene depth

uniform mat4 uPB_inv;		// Inverse bias-projection

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

//testing
//uniform sampler2D uImage02; // normals
//uniform sampler2D uImage03; // height map

layout (location = 0) out vec4 rtFragColor;

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
	// DUMMY OUTPUT: all fragments are OPAQUE ORANGE
	//rtFragColor = vec4(1.0, 0.5, 0.0, 1.0);

	// Phong:
	// ambient
	// + diffuse color * diffuse light
	// + specualr color * specular light

	// have:
	// -> difuse & specular COLOR -> atlases
	// have not: 
	// -> light data -> uniform
	// -> model/scene data -> "attributes"
	//		-> some framebuffer ???
	//			-> texcoords normals positions
	//			   stored in textures called
	//             "g-buffers"


	// draw objects with diffuse color applied
	//	-> use screan-space coordinate to sample
	//		uImage04 (scene texcoord)
	//	-> sample atlas using sceneTexcoord
	vec4 sceneTexcoord = texture(uImage04, vTexcoord_atlas.xy);
	vec4 diffuseSample = texture(uImage00, sceneTexcoord.xy);
	vec4 specularSample = texture(uImage01, sceneTexcoord.xy);
	
	vec4 position_screen = vTexcoord_atlas;
	position_screen.z = texture(uImage07, vTexcoord_atlas.xy).r;
	
	// view-space fragment position
	vec4 position_view = uPB_inv * position_screen;
	position_view /= position_view.w;

	vec4 normal_view = texture(uImage05, vTexcoord_atlas.xy);
	normal_view = normal_view * 2.0 - 1.0;

	vec4 diffuseColor = vec4(0.0);
	vec4 specularColor = vec4(0.0);
	vec4 diffuseSum = vec4(0.0);
	vec4 specularSum = vec4(0.0);
	vec4 lightRadiusInfo = vec4(0.0);

	// for each light
	for(int i = 0; i < uCount; i++)
	{
		// light radius data
		lightRadiusInfo = vec4(uPointLightData[i].radius, uPointLightData[i].radiusSq,
						uPointLightData[i].radiusInv, uPointLightData[i].radiusInvSq);

		// getting diffuse and specular
		calcPhongPoint(diffuseColor, specularColor,
		-normalize(position_view), position_view, normal_view, diffuseSample,
		uPointLightData[i].position, lightRadiusInfo, uPointLightData[i].color);

		diffuseSum += diffuseColor;
		specularSum += specularColor;
	}

	rtFragColor = vec4(diffuseSum.xyz + specularSum.xyz, 1.0);

	//DEBUGGING
	//rtFragColor = vTexcoord_atlas;
	//rtFragColor = texture(uImage00, vTexcoord_atlas.xy);
	//rtFragColor = texture(uImage07, vTexcoord_atlas.xy);
	//rtFragColor = texture(uImage06, vTexcoord_atlas.xy);
	//rtFragColor = diffuseSample;
	//rtFragColor = position_screen;
	//rtFragColor = normal_view;
	
	//transparency
	rtFragColor.a = diffuseSample.a;
}
