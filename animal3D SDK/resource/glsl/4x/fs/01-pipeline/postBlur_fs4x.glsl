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
	
	postBlur_fs4x.glsl
	Gaussian blur.
*/

// Modified by Egor Fesenko
// Info sources: Blue Book ("Making Your Scene Bloom" pp.483-490)

#version 450

// ****DONE:
//	-> declare texture coordinate varying and input texture
//	-> declare sampling axis uniform (see render code for clue)
//	-> declare Gaussian blur function that samples along one axis
//		(hint: the efficiency of this is described in class)

layout (location = 0) out vec4 rtFragColor;

uniform sampler2D uTex_dm;
uniform sampler2D uSampler;
uniform vec2 uAxis;

in vec2 vTexcoord;

// Separable Gaussian filter taps
const float weights[] = float[](0.0024499299678342,
                                0.0043538453346397,
                                0.0073599963704157,
                                0.0118349786570722,
                                0.0181026699707781,
                                0.0263392293891488,
                                0.0364543006660986,
                                0.0479932050577658,
                                0.0601029809166942,
                                0.0715974486241365,
                                0.0811305381519717,
                                0.0874493212267511,
                                0.0896631113333857,
                                0.0874493212267511,
                                0.0811305381519717,
                                0.0715974486241365,
                                0.0601029809166942,
                                0.0479932050577658,
                                0.0364543006660986,
                                0.0263392293891488,
                                0.0181026699707781,
                                0.0118349786570722,
                                0.0073599963704157,
                                0.0043538453346397,
                                0.0024499299678342);

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE AQUA
	//rtFragColor = vec4(0.0, 1.0, 0.5, 1.0);

	//rtFragColor = texture(uTex_dm, vTexcoord);

    vec4 color = vec4(0.0);

    //Summing color for points nearby
    for (int i = 0; i < weights.length(); i++)
    {
        color += texture2D(uTex_dm, vTexcoord + i / 5.0f * uAxis) * weights[i];
        color += texture2D(uTex_dm, vTexcoord - i / 5.0f * uAxis) * weights[i];
    }
    rtFragColor = color;
}
