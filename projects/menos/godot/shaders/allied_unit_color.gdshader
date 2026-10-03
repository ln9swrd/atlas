shader_type canvas_item;

uniform vec4 team_color : source_color = vec4(1.0);

void fragment() {
    vec4 base = texture(TEXTURE, UV) * COLOR;
    float luminance = dot(base.rgb, vec3(0.299, 0.587, 0.114));
    vec3 colored = luminance * normalize(max(team_color.rgb, vec3(0.001)));
    float saturation = clamp(max(team_color.rgb) - min(team_color.rgb), 0.0, 1.0);
    COLOR = vec4(mix(base.rgb, colored, saturation), base.a);
}
