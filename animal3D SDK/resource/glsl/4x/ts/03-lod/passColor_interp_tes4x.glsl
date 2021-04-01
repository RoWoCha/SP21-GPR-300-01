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
	
	passColor_interp_tes4x.glsl
	Pass color, outputting result of interpolation.
*/

#version 450

// ****DONE: 
//	-> declare uniform block for spline waypoint and handle data
//	-> implement spline interpolation algorithm based on scene object's path
//	-> interpolate along curve using correct inputs and project result

layout (isolines, equal_spacing) in;

uniform ubCurve
{
	vec4 uCurveWaypoint[32];
	vec4 uCurveTangent[32];
};
uniform int uCount;

uniform mat4 uP;

out vec4 vColor;

mat4 hermiteKernel = mat4(  1, 0, -3, 2,
							0, 1, -2, 1,
							0, 0, 3, -2,
							0, 0, -1, 1  );

mat4 catmullRomKernel = mat4(   0, -1, 2, -1,
								2, 0, -5, 3,
								0, 1, 4, -3,
								0, 0, -1, 1   );

void main()
{
	// gl_TessCoord for isolines:
	//  [0] = how far along line [0, 1]
	//  [1] = which line [0, 1)
	// in this example
	// gl_TessCoord[0] = interpolation parameter
	// gl_TessCoord[1] = 0

	int p0 = gl_PrimitiveID;
	int p1 = (p0 + 1) % uCount;
	//int p2 = (p0 + 2) % uCount;
	//int pNeg1 = (p0 - 1) % uCount;
	float t = gl_TessCoord.x;
	float tsq = t * t;
	float tcu = t * t * t;
	//vec4 polynTerms = vec4(1, t, t*t, t*t*t);

	vec4 m0 = uCurveTangent[p0] - uCurveWaypoint[p0];
	vec4 m1 = uCurveTangent[p1] - uCurveWaypoint[p1];

	mat4 inflMat = mat4(uCurveWaypoint[p0], m0, uCurveWaypoint[p1], m1); 
	//mat4 inflMat = mat4(uCurveWaypoint[pNeg1], uCurveWaypoint[p0], uCurveWaypoint[p1], uCurveWaypoint[p2]); 

	
	//vec4 p = vec4(gl_TessCoord[0], 0.0, -1.0, 1.0);
	//vec4 p = mix(uCurveWaypoint[p0], uCurveWaypoint[p1], t);
	//vec4 p = 1/2 * inflMat * catmullRomKernel * polynTerms;

	//vec4 p = 1/2 * vec4( (-t + 2 * tsq - tcu) * uCurveWaypoint[pNeg1] +
	//					 (2 - 5 * tsq + 3 * tcu) * uCurveWaypoint[p0] +
	//					 (t + 4* tsq - 3 * tcu) * uCurveWaypoint[p1] +
	//					 (-tsq + tcu) * uCurveWaypoint[p2]);
	//vec4 polynCatmullRom = vec4( (-t + 2 * tsq - tcu),
	//						 (2 - 5 * tsq + 3 * tcu),
	//					     (t + 4* tsq - 3 * tcu),
	//					     (-tsq + tcu) );
	vec4 polynHermite = vec4( (1 - 3 * tsq + 2 * tcu),
							 (t - 2 * tsq + tcu),
						     (3 * tsq - 2 * tcu),
						     (-tsq + tcu) );

	//gl_Position = uP * 1/2 * inflMat * polynCatmullRom;
	gl_Position = uP * inflMat * polynHermite;

	vColor = vec4(0.0, 0.5, t, 1.0);
	
}
