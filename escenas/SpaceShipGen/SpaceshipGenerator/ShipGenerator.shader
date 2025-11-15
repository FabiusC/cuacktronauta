shader_type canvas_item;
render_mode blend_mix;

uniform bool mirrorX = true;
uniform bool mirrorY = false;

uniform float seed : hint_range(1.0, 10.0);
uniform float complexity : hint_range(1.8, 6.0) = 3.0;
uniform float width : hint_range(0.0, 1.0) = 0.5;
uniform float height : hint_range(0.0, 1.0) = 0.5;

uniform float border_width : hint_range(0.0, 1.0) = 0.08;
uniform float alpha_width : hint_range(0.0, 1.0) = 0.04;
uniform float alpha_cutoff : hint_range(0.5, 1.0) = 0.7;

uniform vec4 color1 : hint_color;
uniform vec4 color2 : hint_color;
uniform vec4 border_color : hint_color;

vec2 hash2(vec2 p) {
	return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453*seed);
}

// at the core of this shader is a voronoi shader. I use one made by iq on shadertoy: 
// https://www.shadertoy.com/view/ldl3W8
// also here is license for that shader:
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
vec3 voronoi( in vec2 uv)
{
    vec2 n = floor(uv);
    vec2 f = fract(uv);

    //----------------------------------
    // first pass: regular voronoi
    //----------------------------------
	vec2 mg, mr;

    float md = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec2 g = vec2(float(i),float(j));
		vec2 o = hash2( n + g );

        vec2 r = g + o - f;
		
        float d = dot(r,r);

		
        if( d <md)
        {
            md = d;
            mr = r;
            mg = g;
        }

    }

    //----------------------------------
    // second pass: distance to borders
    //----------------------------------
    md = 8.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        vec2 g = mg + vec2(float(i),float(j));
		vec2 o = hash2( n + g );

        vec2 r = g + o - f;

        if( dot(mr-r,mr-r)>0.00001 )
        md = min( md, dot( 0.5*(mr+r), normalize(r-mr)));

		// this is some added code
		// it basically cuts out circles from the texture, with circle radius depending on distance from center
		float y_ratio = width/height;
		float x_ratio = height/width;
		float dist = distance(vec2(0.0), uv*vec2(x_ratio, y_ratio));
		md *= step(dist, length(r*complexity)*alpha_cutoff);
    }

    return vec3( md, mr );
}

void fragment() {
	vec2 uv = UV-0.5;
	if (mirrorX) {
		uv.x = abs(UV.x - 0.5);
	}
	if (mirrorY) {
		uv.y = abs(UV.y - 0.5);
	}
	
    vec3 c = voronoi(uv * complexity*2.0);
	
	// we can assign some colors based on voronoi data
	vec3 col = vec3(0.0);
	col.rgb += step(c.x, c.y*1.5) * color1.rgb;
	col.rgb += step(c.y*1.5, c.x) * color2.rgb;
	if (c.x < border_width) {
		col.rgb = border_color.rgb;
	}
	
	float alpha = step(alpha_width, c.x);
	COLOR = vec4(col, alpha);
}
