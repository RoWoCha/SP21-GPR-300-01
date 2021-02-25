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
	
	postBlend_fs4x.glsl
	Blending layers, composition.
*/

// Modified by Egor Fesenko

#version 450

// ****DONE:
//	-> declare texture coordinate varying and set of input textures
//	-> implement some sort of blending algorithm that highlights bright areas
//		(hint: research some Photoshop blend modes)

layout (location = 0) out vec4 rtFragColor;

uniform sampler2D uImage00, uImage01, uImage02, uImage03;

in vec2 vTexcoord;

void main()
{
	vec3 res0 = texture(uImage00, vTexcoord).rgb;
	vec3 res1 = texture(uImage01, vTexcoord).rgb;
	vec3 res2 = texture(uImage02, vTexcoord).rgb;
	vec3 res3 = texture(uImage03, vTexcoord).rgb;

	vec3 color = res0 + res1 + res2 + res3;

	rtFragColor = vec4(color, 1.0);
}
