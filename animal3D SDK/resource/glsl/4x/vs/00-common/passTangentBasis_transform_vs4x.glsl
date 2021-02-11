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
	
	passTangentBasis_transform_vs4x.glsl
	Calculate and pass tangent basis.
*/

// Contributions: Egor Fesenko

#version 450

// ****DONE: 
//	-> declare matrices
//		(hint: not MVP this time, made up of multiple; see render code)
//	-> transform input position correctly, assign to output
//		(hint: this may be done in one or more steps)
//	-> declare attributes for lighting and shading
//		(hint: normal and texture coordinate locations are 2 and 8)
//	-> declare additional matrix for transforming normal
//	-> declare varyings for lighting and shading
//	-> calculate final normal and assign to varying
//	-> assign texture coordinate to varying

// !!!PER-FRAGMENT!!! //
layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec3 aNormal;
layout (location = 8) in vec2 aTexcoord;

flat out int vVertexID;
flat out int vInstanceID;

uniform mat4 uMV, uP, uMV_nrm;

out vec4 vPosition;
out vec4 vNormal;
out vec2 vTexcoord;

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	//gl_Position = aPosition;

	//vPosition = aPosition;  // object space
	//vNormal = aNormal;  // object space
	vPosition = uMV * aPosition;  // camera space
	vNormal = uMV_nrm * vec4(aNormal, 1.0);  // camera space

	vTexcoord = aTexcoord;

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;

	gl_Position = uP * vPosition;  // clip space
}


// !!!PER-VERTEX!!! //
/*const int NUM_LIGHTS = 4;

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec3 aNormal;
layout (location = 8) in vec2 aTexcoord;

flat out int vVertexID;
flat out int vInstanceID;

uniform mat4 uMV, uP, uMV_nrm;

uniform vec4 uLightPos[NUM_LIGHTS];
uniform vec4 uLightColor[NUM_LIGHTS];
uniform float uLightRadii[NUM_LIGHTS];

uniform vec4 uColor;
uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;

out vec4 vColor;

vec4 phongShadingCalc(int lightNum, vec4 position, vec4 normal);

void main()
{
	vec4 position = uMV * aPosition;  // camera space
	vec4 normal = uMV_nrm * vec4(aNormal, 1.0);  // camera space

	vec4 positionClip = uP * position;  // clip space

	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);

	//Iterating through all light sources
	for(int i = 0; i < NUM_LIGHTS; i++)
	{
		color += vec4(vec3(phongShadingCalc(i, position, normal)), 0.0);
	}

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
	gl_Position = positionClip;
	vColor = color;
}

//Function for calculating color after Phong shading for one light source
vec4 phongShadingCalc(int lightNum, vec4 position, vec4 normalCS)
{
	float distance = length(uLightPos[lightNum] - position);
	vec4 lightVec = normalize(uLightPos[lightNum] - position);
	vec4 normal = normalize(normalCS);

	vec4 viewVec = normalize(-position);
	vec4 reflectionVec = reflect(-lightVec, normal);	

	//diffuse (Lambert) coefficient:
	float diffCoeff = max(0.1, dot(normal, lightVec));
	vec4 diffuse_color = diffCoeff * texture(uTex_dm, aTexcoord);

	//specular (Phong) coefficient
	float specCoeff = max(0.1, dot(viewVec, reflectionVec));
	specCoeff *= specCoeff;
	vec4 specular_color = specCoeff * texture(uTex_sm, aTexcoord);

	//adding attenuation
	vec4 resCoeff = (diffuse_color + specular_color) * (1.0 / (uLightRadii[lightNum] * distance * distance + 1.0));
	vec4 result = resCoeff * uLightColor[lightNum] * uColor;

	return result;
}*/