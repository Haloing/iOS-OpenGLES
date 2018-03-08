/*
 上一篇我们通过定义的顶点坐标绘制了一个三角形，通过设置颜色值，改变了三角形的渲染颜色。在实例化GLKBaseEffect对象的时候，我们说到GLKit提供GLKBaseEffect是为了在需要的时候自动地构建GPU程序，而无需我们编写着色器的代码。对于一些简单的图形，我们使用GLKit提供GLKBaseEffect完全可以达到渲染效果。如果要实现比较复杂的动画效果，比如后面会学习的矩阵变换、灯光、物理引擎和粒子效果...都会自定义着色器来实现比较方便。
 
 我们先看一下OpenGL的渲染流程：
 
 可以看出图形管线包含很多部分：先接受一组3D坐标，然后经过图元装配 -- 几何着色器 -- 光栅化 -- 片段着色器 -- 最后测试混合才转变为你屏幕上的有色2D像素输出。图形渲染管线的每个阶段将会把前一个阶段的输出作为这个阶段的输入。所有这些阶段都是高度专门化的（它们都有一个特定的函数），并且很容易并行执行。正是由于它们具有并行执行的特性，当今大多数显卡都有成千上万的小处理核心，它们在GPU上为每一个（渲染管线）阶段运行各自的小程序，从而在图形渲染管线中快速处理你的数据。这些小程序叫做着色器(Shader)。
 
 注意上图中的蓝色阶段代表我们可以注入自定义的着色器，这就允许我们用自己写的着色器来替换默认的。这样我们就可以更细致地控制图形渲染管线中的特定部分了，而且因为它们运行在GPU上，所以它们可以给我们节约宝贵的CPU时间。
 
 图形管线非常复杂，它包含很多可配置的部分。然而，对于大多数场合，我们只需要配置顶点和片段着色器就行了。几何着色器是可选的，通常使用它默认的着色器就行了。
 
 所以这里主要说的是两个可以自定义的着色器，也就是顶点着色器和片段着色器。
 
 Xcode创建着色器编写文件：Xcode顶部菜单栏 -- File -- New -- File -- iOS Other -- Empty（Save As 的文件后缀为.glsl、.vsh和.fsh都可以，主要与加载内容时候的文件名和类型一致即可），如下图:
 
 先编写一个顶点着色器：
 attribute vec4 position;
 attribute vec4 color;
 varying vec4 fColor;
 void main(void) {
 fColor = color;
 gl_Position = position;
 }
 
 简要说明：
 前面三行声明变量，前面两个为attribute关键字类型变量，后面一个是varying类型。
 
 attribute：声明的是顶点数据属性，其中position是接受位置坐标、color是接受颜色值。一般情况下应用中顶点数组传递数据到顶点着色器内都需要定义attribute关键字的属性来接受，然后在着色器内部可以对这些数据进行处理。
 
 varying：与attribute一样都是定义属性的关键字。不同的是varying关键字定义的属性是要传递给片段着色器的变量。因为片段着色器是无法直接接受CPU传递过来的数据。
 所以上面的attribute vec4 position和attribute vec4 color是定义为接受顶点数组传递过来的坐标和颜色值的。
 而varying vec4 fColor是定义为传递到片段着色器的变量。
 
 再看一下数据类型：
 vec4:其实还有vec2、vec3。分别代表二维、三维、四维向量。
 这里定义的position、color和fColor是四维向量。
 
 总结一下：
 顶点着色器中属性的定义格式为：变量类型 变量数据类型 变量名（attribute vec4 position）
 其中变量类型有三种（除了上面介绍的两种，还有两外一种）：
 attribute：接受顶点数据的变量，相当于输入变量
 varying：传递到片段着色器的变量，相当于输出变量
 uniform：相当于全局变量
 
 变量数据类型：
 vec开头的：vec2、vec3、vec4代表二维、三维、四维向量
 float：浮点数。在着色器中没有数据类型转换，所以定义的flozt必须写成浮点数格式。比如0需要写成0.0、1写成1.0
 int：整形
 mat：mat开头的有mat2、mat3、mat4分别代表二维、三维、四维矩阵。主要用来传递变换矩阵。
 
 再来看一下片段着色器：
 precision mediump float;
 varying lowp vec4 fColor;
 void main(void) {
 gl_FragColor = fColor;
 }
 
 与顶点着色器不同，在片段着色器中的变量只有varying和uniform类型的，其中varying是从顶点着色器传递过来的。看一下顶点着色器，里面定义的varying vec4 fColor就是需要传递到片段着色器的，而在这里就需要定义varying lowp vec4 fColor来接受，变量名必须相同。另外还有一点，对比一下varying vec4 fColor和varying lowp vec4 fColor就可以看出，在片段着色器中定义的接受属性多了lowp。这是修饰变量精度，在片段着色器中定义的所有变量都需要声明精度。
 
 精度包含三种：lowp、highp、mediump分别是低精度、中等精度、高精度。
 
 还有一点不同的是precision mediump float，这是统一精度声明。如果在第一行做了统一精度声明的话，后面就不需要每个变量都声明了。当然这里这是为float指定了mediump精度，如果要为其他类型指定精度的话加上就可以了，比如： precision lowp vec4。
 
 通过上面几步已经写好了顶点着色器和片段着色器，但这些知识源码，并没有应用到程序中进行数据处理的能力。所以需要动态编译生成着色器对象然后链接到着色器程序上。我们一步步来。
 
1.加载文件内容：
 NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
 NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
 
 NSString *vertexContext = [NSString stringWithContentsOfFile:vertexShaderPath encoding:NSUTF8StringEncoding error:nil];
 NSString *fragmentContext = [NSString stringWithContentsOfFile:fragmentShaderPath encoding:NSUTF8StringEncoding error:nil];

 2.创建指定类型着色器对象
 参数：
 GL_VERTEX_SHADER：顶点着色器枚举
 GL_FRAGMENT_SHADER:片段着色器枚举
 GLuint shader = glCreateShader(shaderType);
 
 3.着色器对象加载着色器源码
 // 将着色器源码加载到着色器对象上
 glShaderSource(shader, 1, &vertexContext.UTF8String, NULL);
 
 4.运行时编译shader
 glCompileShader(shader);
 
 5.检查编译状态
 GLint logLength;
 glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
 if (logLength > 0) {
 GLchar *log = (GLchar *)malloc(logLength);
 glGetShaderInfoLog(*shader, logLength, &logLength, log);
 printf("Shader compile log:\n%s", log);
 printf("Shader: \n %s\n", source);
 free(log);
 }
 
 6.创建一个着色器程序对象
 GLuint program = glCreateProgram();
 
 7.链接两个着色器对象
 glAttachShader(program, vertexShader);
 glAttachShader(program, fragmentShader);
 
 8.链接程序
 glLinkProgram(programHandle);
 
 9.删除着色器对象
 glDeleteShader(vertexShader);
 glDeleteShader(fragmentShader);
 
 最后生成的program程序对象就是具备数据处理能力的着色器程序来。可以理解为在GPU上运行的程序。
 
 缩放
 缩放是通过相对于参考坐标系的坐标轴的单位长度改变新坐标系的坐标轴的单位长度来定义一个新坐标系。缩放坐标系与参考坐标系使用同一个原点。坐标轴的方向通常不会改变。不过，通过一个负值所做的缩放就会翻转坐标轴的方向。
 
 GLKit提供了GLKMatrix4MakeScale(float x,float y,float z)函数，这个函数会通过扩大或者缩小一个单位矩阵的任意坐标轴的单位长度来返回一个定义了坐标系的矩阵。x、y和z参数指定了用来扩大或者缩小每个轴的单位长度的因素。GLKMatrix4Scale(float x,float y,float z)函数通过按指定的因数缩放作为参数传入矩阵来返回一个定义了坐标系的新矩阵。
 
 
 
 */
