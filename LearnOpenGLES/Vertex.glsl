attribute vec4 position;
attribute vec4 color;

varying vec4 fColor;

uniform mat4 transform;

void main(void) {
    fColor = color;
    gl_Position = transform * position;
}
