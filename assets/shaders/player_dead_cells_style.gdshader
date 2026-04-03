shader_type canvas_item;
render_mode blend_mix, unshaded;

/* Estilo próximo a Dead Cells: contorno escuro, contraste alto, leve frio nas sombras. */

uniform vec4 outline_color : source_color = vec4(0.06, 0.07, 0.1, 1.0);
uniform float outline_width : hint_range(0.7, 2.0) = 1.0;
uniform float contrast : hint_range(0.85, 1.35) = 1.12;
uniform float shadow_cool : hint_range(0.0, 0.35) = 0.12;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE * outline_width;
	float n = 0.0;
	n += texture(TEXTURE, UV + vec2(px.x, 0.0)).a;
	n += texture(TEXTURE, UV - vec2(px.x, 0.0)).a;
	n += texture(TEXTURE, UV + vec2(0.0, px.y)).a;
	n += texture(TEXTURE, UV - vec2(0.0, px.y)).a;
	n += texture(TEXTURE, UV + px).a;
	n += texture(TEXTURE, UV - px).a;
	n += texture(TEXTURE, UV + vec2(px.x, -px.y)).a;
	n += texture(TEXTURE, UV + vec2(-px.x, px.y)).a;

	if (tex.a < 0.5 && n > 0.001) {
		COLOR = outline_color;
	} else {
		vec3 rgb = tex.rgb;
		rgb = ((rgb - 0.5) * contrast) + 0.5;
		float luma = dot(rgb, vec3(0.299, 0.587, 0.114));
		vec3 cool_shadow = rgb * vec3(0.92, 0.96, 1.08);
		rgb = mix(rgb, cool_shadow, shadow_cool * (1.0 - smoothstep(0.15, 0.55, luma)));
		COLOR = vec4(rgb, tex.a);
	}
}
