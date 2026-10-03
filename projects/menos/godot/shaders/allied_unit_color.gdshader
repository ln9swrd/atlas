shader_type canvas_item;

uniform vec4 team_color : source_color = vec4(1.0);

void fragment() {
    vec4 base = texture(TEXTURE, UV) * COLOR;
    float luminance = dot(base.rgb, vec3(0.299, 0.587, 0.114));
    vec3 colored = luminance * team_color.rgb;
    COLOR = vec4(mix(base.rgb, colored, team_color.a), base.a);
}
