shader_type canvas_item;

uniform vec4 team_color : source_color = vec4(1.0);
uniform sampler2D team_mask : filter_linear, repeat_disable;
uniform bool use_team_mask = false;

void fragment() {
    vec4 base = texture(TEXTURE, UV) * COLOR;
    float luminance = dot(base.rgb, vec3(0.299, 0.587, 0.114));
    vec3 tinted = luminance * team_color.rgb;
    if (!use_team_mask) {
        COLOR = vec4(tinted, base.a);
        return;
    }
    float mask = texture(team_mask, UV).r;
    COLOR = vec4(mix(base.rgb, tinted, mask), base.a);
}
