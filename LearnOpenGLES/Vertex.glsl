attribute vec4 position;
attribute vec4 color;

varying vec4 fColor;

void main(void) {
    fColor = color;
    gl_Position = position;
}
