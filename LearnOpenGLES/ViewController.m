//
//  ViewController.m
//  LearnOpenGLES
//
//  Created by Mac OS X on 2018/2/6.
//  Copyright © 2018年 Mac OS X. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/glext.h>

@interface ViewController () {
    GLuint program;
    GLuint vbo;
    
    GLuint vao;
    
    GLfloat changeValue;
    
    GLKMatrix4 projectionMatrix; // 投影矩阵
    
    GLKMatrix4 modelMatrix; // 模型矩阵
    
    GLKMatrix4 cameraMatrix; // 观察矩阵
}

@end

@implementation ViewController

static GLfloat vertices[] = {
   -0.5f,    0.5f,  0,   1,  0,  0, // x, y, z, r, g, b,每一行存储一个点的信息，位置和颜色
   -0.5f,   -0.5f,  0,   0,  1,  0,
    0.5f,   -0.5f,  0,   0,  0,  1,
    0.5f,   -0.5f,  0,   0,  0,  1,
    0.5f,    0.5f,  0,   0,  1,  0,
   -0.5f,    0.5f,  0,   1,  0,  0,
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupEAGLContext];
    
    [self setupShader];
    
    [self genVBO];
    
    [self genVAO];
    
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    float fovyRadians =GLKMathDegreesToRadians(90);
    projectionMatrix = GLKMatrix4MakePerspective(fovyRadians, aspect, 0.0, 10.0);
    
    modelMatrix = GLKMatrix4Identity;
    
    cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 1, 0, 0, 0, 0, 1, 0);
}

- (void)genVBO {
    
    // 使用glGenBuffers函数和一个缓冲ID生成一个VBO对象
    glGenBuffers(1, &vbo);
    
    // 使用glBindBuffer函数把新创建的缓冲绑定到GL_ARRAY_BUFFER目标上
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    // 调用glBufferData函数，它会把之前定义的顶点数据复制到缓冲的内存中
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
}

- (void)genVAO {
    
    glGenVertexArraysOES(1, &vao);
    
    // 绑定vao
    glBindVertexArrayOES(vao);
    
    // 把顶点数组复制到缓冲中供OpenGL ES使用
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    // 激活顶点属性
    GLuint positionAttribLocation = glGetAttribLocation(program, "position");
    glEnableVertexAttribArray(positionAttribLocation);
    
    GLuint colorAttribLocation = glGetAttribLocation(program, "color");
    glEnableVertexAttribArray(colorAttribLocation);
    
    glVertexAttribPointer(positionAttribLocation, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), NULL);
    glVertexAttribPointer(colorAttribLocation, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), NULL + 3 * sizeof(GLfloat));
    
    glBindVertexArrayOES(0);
}

// 在update中修改数据
- (void)update {
    
    NSTimeInterval deltaTime = self.timeSinceLastUpdate;
    
    changeValue += deltaTime;
    
    float change = changeValue;
    
    float var = (sin(change) + 1) / 2.0; // 0 ~ 1
    
    cameraMatrix = GLKMatrix4MakeLookAt(0, sin(change), 3, 0, 0, 0, 1, 0, 0);
    
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(var * M_PI * 2, 0, 1, 0);
    
   // modelMatrix = rotateMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    // 清除缓存
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1.0, 1.0, 1.0, 1.0);
    
    // 启用这个着色器程序
    glUseProgram(program);

    glBindVertexArrayOES(vao);
    
    GLuint modeUniformLocation = glGetUniformLocation(program, "modelMatrix");
    glUniformMatrix4fv(modeUniformLocation, 1, 0, modelMatrix.m);
    
    GLuint projectionUniformLocation = glGetUniformLocation(program, "projectionMatrix");
    glUniformMatrix4fv(projectionUniformLocation, 1, 0, projectionMatrix.m);
    
    GLuint cameraUniformLocation = glGetUniformLocation(program, "cameraMatrix");
    glUniformMatrix4fv(cameraUniformLocation, 1, 0, cameraMatrix.m);
    
    // 绘制
    glDrawArrays(GL_TRIANGLES, 0,12);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupEAGLContext {
    // 初始化EAGLContext
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // 设置帧率为60fps
    self.preferredFramesPerSecond = 60;
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    [EAGLContext setCurrentContext:view.context];
}

// 编译着色器源码生成着色器程序
- (void)setupShader {
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"Vertex" ofType:@"glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"Fragment" ofType:@"glsl"];
    
    NSString *vertexContext = [NSString stringWithContentsOfFile:vertexShaderPath encoding:NSUTF8StringEncoding error:nil];
    NSString *fragmentContext = [NSString stringWithContentsOfFile:fragmentShaderPath encoding:NSUTF8StringEncoding error:nil];
    
    createProgram(vertexContext.UTF8String, fragmentContext.UTF8String, &program);
}

#pragma mark - Prepare Shaders
bool createProgram(const char *vertexShader, const char *fragmentShader, GLuint *pProgram) {
    GLuint program, vertShader, fragShader;
    // Create shader program.
    program = glCreateProgram();
    
    const GLchar *vssource = (GLchar *)vertexShader;
    const GLchar *fssource = (GLchar *)fragmentShader;
    
    if (!compileShader(&vertShader,GL_VERTEX_SHADER, vssource)) {
        printf("Failed to compile vertex shader");
        return false;
    }
    
    if (!compileShader(&fragShader,GL_FRAGMENT_SHADER, fssource)) {
        printf("Failed to compile fragment shader");
        return false;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Link program.
    if (!linkProgram(program)) {
        printf("Failed to link program: %d", program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        return false;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }
    
    *pProgram = program;
    printf("Effect build success => %d \n", program);
    return true;
}


bool compileShader(GLuint *shader, GLenum type, const GLchar *source) {
    GLint status;
    
    if (!source) {
        printf("Failed to load vertex shader");
        return false;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    
#if Debug
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        printf("Shader compile log:\n%s", log);
        printf("Shader: \n %s\n", source);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return false;
    }
    
    return true;
}

bool linkProgram(GLuint prog) {
    GLint status;
    glLinkProgram(prog);
    
#if Debug
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        printf("Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return false;
    }
    
    return true;
}

bool validateProgram(GLuint prog) {
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        printf("Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return false;
    }
    
    return true;
}


@end
