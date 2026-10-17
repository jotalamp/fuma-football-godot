shader_type spatial;
render_mode blend_mix,depth_draw_opaque, unshaded;

uniform vec4 gridColor: source_color;
uniform vec4 checkerColor: source_color;
uniform float fadeStart = 0.0;
uniform float fadeEnd = 10000.0;
uniform float unitSize = 10.0;
uniform int subdivisions: hint_range(1, 10) = 5;
uniform float majorLineThickness = 20.0;
uniform float minorLineThickness = 1.0;
uniform float minorLineAlpha: hint_range(0.0, 1.0) = .3;
uniform vec3 centerOffset = vec3(10.0, 0.0, 0.0);

// calculate line mask, usning a bit of fwidth() magic to make line width not affected by perspective
float grid(vec2 pos, float unit, float thickness){
	vec2 threshold = fwidth(pos) * thickness * .5 / unit;
	vec2 posWrapped = pos / unit;
	vec2 line = step(fract(-posWrapped), threshold) + step(fract(posWrapped), threshold);
	return max(line.x, line.y);
}

// calculate checkerboard mask

float line_x(vec2 pos, float line_z_pos, float length_x)
{
	if (pos.y > line_z_pos-0.1 && pos.y < line_z_pos+0.1 && pos.x > -0.5*length_x)
	{
        return 1.0;
    }
	else
	{
        return 0.0;
    }
}

float checker(vec2 pos, float unit)
{
	return line_x(pos, -10.0, 10.0) + line_x(pos, 10.0, 10.0);
}

void fragment() {
	// ray from camera to fragemnt in world space
	vec3 rayWorld = normalize(mat3(INV_VIEW_MATRIX) * VIEW) ;

	// calculate fragment position in world space
	vec3 posWorld;
	float t = -(CAMERA_POSITION_WORLD.y - centerOffset.y) / (rayWorld.y );
	posWorld.y = -centerOffset.y;
	posWorld.xz = CAMERA_POSITION_WORLD.xz + t * rayWorld.xz + centerOffset.xz;

	// checkerboard
	float chec = checker(posWorld.xz, unitSize);

	// write ground plane depth into z buffer
	vec4 pp = (PROJECTION_MATRIX * (VIEW_MATRIX * vec4(posWorld, 1.0)));
	DEPTH = pp.z / pp.w;

	ALPHA = 0.3 * chec;

	// final color (premultiplied alpha blend)
	ALBEDO = vec3(1.0);

}