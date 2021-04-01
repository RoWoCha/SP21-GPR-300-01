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
	
	drawTangentBases_gs4x.glsl
	Draw tangent bases of vertices and/or faces, and/or wireframe shapes, 
		determined by flag passed to program.
*/

#version 450

// ****TO-DO: 
//	-> declare varying data to read from vertex shader
//		(hint: it's an array this time, one per vertex in primitive)
//	-> use vertex data to generate lines that highlight the input triangle
//		-> wireframe: one at each corner, then one more at the first corner to close the loop
//		-> vertex tangents: for each corner, new vertex at corner and another extending away 
//			from it in the direction of each basis (tangent, bitangent, normal)
//		-> face tangents: ditto but at the center of the face; need to calculate new bases
//	-> call "EmitVertex" whenever you're done with a vertex
//		(hint: every vertex needs gl_Position set)
//	-> call "EndPrimitive" to finish a new line and restart
//	-> experiment with different geometry effects

// (2 verts/axis * 3 axes/basis * (3 vertex bases + 1 face basis) + 4 to 8 wireframe verts = 28 to 32 verts)
#define MAX_VERTICES 32

layout (triangles) in;

layout (line_strip, max_vertices = MAX_VERTICES) out;

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vVertexData[];

uniform mat4 uP;

out vec4 vColor;

const float size = 0.1;

void drawWireframe()
{
	//gl_in[].gl_Position

	vColor = vec4(1.0, 0.0, 0.0, 1.0);
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[1].gl_Position;
	EmitVertex();
	EndPrimitive();

	vColor = vec4(0.0, 1.0, 0.0, 1.0);
	gl_Position = gl_in[1].gl_Position;
	EmitVertex();
	gl_Position = gl_in[2].gl_Position;
	EmitVertex();
	EndPrimitive();

	vColor = vec4(0.0, 0.0, 1.0, 1.0);
	gl_Position = gl_in[2].gl_Position;
	EmitVertex();
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	EndPrimitive();
}

void drawVertexTangent()
{
	vec4 t = uP * normalize(vVertexData[0].vTangentBasis_view[0]) * size;
	vec4 b = uP * normalize(vVertexData[0].vTangentBasis_view[1]) * size;
	vec4 n = uP * normalize(vVertexData[0].vTangentBasis_view[2]) * size;

	vColor = vec4(0.7, 0.7, 0.0, 1.0);
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[0].gl_Position + t;
	EmitVertex();
	EndPrimitive();
	
	vColor = vec4(0.0, 0.7, 0.7, 1.0);
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[0].gl_Position + b;
	EmitVertex();
	EndPrimitive();
	
	vColor = vec4(0.7, 0.0, 0.7, 1.0);
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[0].gl_Position + n;
	EmitVertex();
	EndPrimitive();
}

void drawFaceTangent()
{
	vec4 faceCenterCoord = (gl_in[0].gl_Position + gl_in[1].gl_Position + gl_in[2].gl_Position) / 3;
	vec4 faceCenterT = uP * normalize((vVertexData[0].vTangentBasis_view[0] + vVertexData[1].vTangentBasis_view[0] + vVertexData[2].vTangentBasis_view[0]) / 3) * size;
	vec4 faceCenterB = uP * normalize((vVertexData[0].vTangentBasis_view[1] + vVertexData[1].vTangentBasis_view[1] + vVertexData[2].vTangentBasis_view[1]) / 3) * size;
	vec4 faceCenterN = uP * normalize((vVertexData[0].vTangentBasis_view[2] + vVertexData[1].vTangentBasis_view[2] + vVertexData[2].vTangentBasis_view[2]) / 3) * size;

	vColor = vec4(0.7, 0.7, 0.0, 1.0);
	gl_Position = faceCenterCoord;
	EmitVertex();
	gl_Position = faceCenterCoord + faceCenterT;
	EmitVertex();
	EndPrimitive();
	
	vColor = vec4(0.0, 0.7, 0.7, 1.0);
	gl_Position = faceCenterCoord;
	EmitVertex();
	gl_Position = faceCenterCoord + faceCenterB;
	EmitVertex();
	EndPrimitive();
	
	vColor = vec4(0.7, 0.0, 0.7, 1.0);
	gl_Position = faceCenterCoord;
	EmitVertex();
	gl_Position = faceCenterCoord + faceCenterN;
	EmitVertex();
	EndPrimitive();
}

void main()
{
	drawWireframe();
	drawVertexTangent();
	drawFaceTangent();
}
