shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
// Output:0

}

void fragment() {
// Input:3
	vec3 n_out3p0 = vec3(SCREEN_UV, 0.0);

// Scalar:4
	float n_out4p0 = 2.000000;

// Texture:2
	vec3 n_out2p0;
	float n_out2p1;
	{
		vec4 _tex_read = textureLod(SCREEN_TEXTURE, n_out3p0.xy, n_out4p0);
		n_out2p0 = _tex_read.rgb;
		n_out2p1 = _tex_read.a;
	}

// VectorMix:5
	vec3 n_in5p0 = vec3(0.00000, 0.00000, 0.00000);
	vec3 n_in5p2 = vec3(0.20000, 0.20000, 0.20000);
	vec3 n_out5p0 = mix(n_in5p0, n_out2p0, n_in5p2);

// Output:0
	COLOR.rgb = n_out5p0;

}

void light() {
// Output:0

}
