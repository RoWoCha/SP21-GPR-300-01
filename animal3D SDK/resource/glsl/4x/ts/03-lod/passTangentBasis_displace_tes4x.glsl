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
	
	passTangentBasis_displace_tes4x.glsl
	Pass interpolated and displaced tangent basis.
*/

// Info sources:
// 1) https://stackoverflow.com/questions/24166446/glsl-tessellation-displacement-mapping

#version 450

// ****TO-DO: 
//	-> declare inbound and outbound varyings to pass along vertex data
//		(hint: inbound matches TCS naming and is still an array)
//		(hint: outbound matches GS/FS naming and is singular)
//	-> copy varying data from input to output
//	-> displace surface along normal using height map, project result
//		(hint: start by testing a "pass-thru" shader that only copies 
//		gl_Position from the previous stage to get the hang of it)

layout (triangles, equal_spacing) in;

in vbVertexData_tess {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vVertexData_tess[];

out vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
};

uniform sampler2D uTex_hm;

void main()
{
	// gl_TessCoord -> barycentric (3 elements)
	//  gl_InvocationID
	// gl_Position = ?

	// Based on https://stackoverflow.com/questions/24166446/glsl-tessellation-displacement-mapping

	vec4 p0 = gl_TessCoord.x * gl_in[0].gl_Position;
    vec4 p1 = gl_TessCoord.y * gl_in[1].gl_Position;
    vec4 p2 = gl_TessCoord.z * gl_in[2].gl_Position;
    vec4 pos = p0 + p1 + p2;

    vec4 n0 = gl_TessCoord.x * vVertexData_tess[0].vTangentBasis_view[2];
    vec4 n1 = gl_TessCoord.y * vVertexData_tess[1].vTangentBasis_view[2];
    vec4 n2 = gl_TessCoord.z * vVertexData_tess[2].vTangentBasis_view[2];
    vec4 normal = normalize(n0 + n1 + n2);

    vec4 tc0 = gl_TessCoord.x * vVertexData_tess[0].vTexcoord_atlas;
    vec4 tc1 = gl_TessCoord.y * vVertexData_tess[1].vTexcoord_atlas;
    vec4 tc2 = gl_TessCoord.z * vVertexData_tess[2].vTexcoord_atlas;  
    vec4 tessTexcoord = tc0 + tc1 + tc2;

	vec4 t0 = gl_TessCoord.x * vVertexData_tess[0].vTangentBasis_view[0];
    vec4 t1 = gl_TessCoord.y * vVertexData_tess[1].vTangentBasis_view[0];
    vec4 t2 = gl_TessCoord.z * vVertexData_tess[2].vTangentBasis_view[0];
    vec4 tangent = normalize(t0 + t1 + n2);

	vec4 b0 = gl_TessCoord.x * vVertexData_tess[0].vTangentBasis_view[1];
    vec4 b1 = gl_TessCoord.y * vVertexData_tess[1].vTangentBasis_view[1];
    vec4 b2 = gl_TessCoord.z * vVertexData_tess[2].vTangentBasis_view[1];
    vec4 bitangent = normalize(b0 + b1 + b2);

	vec4 v0 = gl_TessCoord.x * vVertexData_tess[0].vTangentBasis_view[3];
    vec4 v1 = gl_TessCoord.y * vVertexData_tess[1].vTangentBasis_view[3];
    vec4 v2 = gl_TessCoord.z * vVertexData_tess[2].vTangentBasis_view[3];
    vec4 view = normalize(v0 + v1 + v2);

    float height = texture(uTex_hm, tessTexcoord.xy).r;
    pos += normal * (height * 0.4f);

	vTangentBasis_view = mat4(tangent, bitangent, normal, view);
	vTexcoord_atlas = tessTexcoord;

	//output
	gl_Position = pos; 
}
