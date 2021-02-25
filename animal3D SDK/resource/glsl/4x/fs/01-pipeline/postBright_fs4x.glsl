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
	
	postBright_fs4x.glsl
	Bright pass filter.
*/

// Modified by Egor Fesenko
// Info sources: Blue Book ("Making Your Scene Bloom" pp.483-490)

#version 450

// ****DONE:
//	-> declare texture coordinate varying and input texture
//	-> implement relative luminance function
//	-> implement simple "tone mapping" such that the brightest areas of the 
//		image are emphasized, and the darker areas get darker

layout (location = 0) out vec4 rtFragColor;

in vec2 vTexcoord;

uniform sampler2D uTex_dm;

uniform float bloom_thresh_min = 0.65;
uniform float bloom_thresh_max = 1.0;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE ORANGE
	vec3 color = vec3(texture(uTex_dm, vTexcoord));

	// Calculate luminance
	float Y = dot(color, vec3(0.25, 0.41, 0.095));
	
	color *= 1.3 * smoothstep(bloom_thresh_min, bloom_thresh_max, Y);

	rtFragColor = vec4(color, 1.0);

	//float Y = dot(vec3(color), vec3(0.299, 0.587, 0.144));
	//color *= 4.0 * smoothstep(bloom_thresh_min, bloom_thresh_max, Y);
	//rtFragColor = color;

//	if(luminance > 1.0)
//        rtFragColor = vec4(color0.rgb, 1.0);
//    else
//        rtFragColor = vec4(0.0, 0.0, 0.0, 1.0);

    //rtFragColor = vec4(1.0, 0.5, 0.0, 1.0);
}
