//
//  ViewController.m
//  LearnOpenGLES
//
//  Created by Mac OS X on 2018/2/6.
//  Copyright © 2018年 Mac OS X. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化EAGLContext
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [GLKBaseEffect new];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0, 0.0, 0.0, 1.0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    /*
     “prepareToDraw”方法，是让“效果Effect”针对当前“Context”的状态进行一些配置，
     它始终把“GL_TEXTURE_PROGRAM”状态定位到“Effect”对象的着色器上。
     */
    [self.baseEffect prepareToDraw];
    
    // 清除缓存
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1.0, 1.0, 1.0, 1.0);
    
    static GLfloat vertices[] = {
        0.0,   0.5f,  0,  1,  0,  0,
       -0.5f, -0.5f,  0,  0,  1,  0,
        0.5f, -0.5f,  0,  0,  0,  1,
    };
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_TRUE, 6 * sizeof(GLfloat), (char *)vertices);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_TRUE, 6 * sizeof(GLfloat), (char *)vertices + 3 * sizeof(GLfloat));
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
