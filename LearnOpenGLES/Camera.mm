/*
 在讲摄像机之前先介绍一下3D渲染中的MVP：分别是模型矩阵（model）、观察矩阵（view）、投影矩阵（Projection）。其中模型矩阵操作的是单个3D模型，可以进行平移、缩放、旋转或者组合变换。观察矩阵可以理解为3D世界中的摄像机，当摄像机的位置发生改变，拍摄的角度不一样，呈现在屏幕上的效果自然会有变化。这一操作会改变物体的顶点位置。投影矩阵在上一篇讲过，分为正射投影和透视投影，透视投影有远小近大的效果，更为真实。这里大概了解一下MVP，接下来修改代码正式步入3D世界；
 
 这里引入了三个矩阵，所以顶点着色器中需要添加接受属性：
 uniform mat4 mMatrix;
 uniform mat4 vMatrix;
 uniform mat4 pMatrix;
 
 mMatrix、vMatrix、pMatrix分别是模型矩阵、观察矩阵、投影矩阵。这里将mvp直接相乘，结果再与position相乘。注意相乘的顺序先进行模型矩阵变换，再是观察矩阵，最后是投影矩阵变换。
 
 相应的工程中添加三个属性：
 GLKMatrix4 projectionMatrix; // 投影矩阵
 
 GLKMatrix4 modelMatrix; // 模型矩阵
 
 GLKMatrix4 cameraMatrix; // 观察矩阵
 
 在viewDidLoad中进行初始化：
 // projectionMatrix 投影矩阵
 float aspect = self.view.frame.size.width / self.view.frame.size.height;
 float fovyRadians =GLKMathDegreesToRadians(90);
 projectionMatrix = GLKMatrix4MakePerspective(fovyRadians, aspect, 0.1, 100.0);
 呈现更为真实的3D效果这里设置投影矩阵为透视投影。
 
 // modelMatrix 模型矩阵
 modelMatrix = GLKMatrix4Identity;
 初始化模型矩阵为单位矩阵
 
 // cameraMatrix 观察矩阵
 cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 0, 0, 0, -2, 0, 1, 0);
 GLKit提供了创建观察矩阵的函数：GLKMatrix4MakeLookAt(float eyeX, float eyeY, float eyeZ, float centerX, float centerY, float centerZ, float upX, float upY, float upZ)
参数float eyeX, float eyeY, float eyeZ定义摄像机的位置。float centerX, float centerY, float centerZ摄像机看向的点。光是这样还不行，相机还可以自转360.所以还需要float upX, float upY, float upZ三个参数确定相机向上的朝向。我们可以设置这9个参数以控制摄像机从不同的角度观察物体。
 
 目前创建的观察矩阵是固定的不动的，我们把projectionMatrix、modelMatrix和cameraMatrix赋值到Vertex Shader:
 
 
 */
