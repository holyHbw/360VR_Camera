//
//  ViewController.m
//  360Camera_testbed
//
//  Created by 黄博闻 on 17/2/23.
//  Copyright © 2017年 黄博闻. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    CGFloat translateX;
    CGFloat translateY;
    CGFloat rotateRatioX;
    CGFloat rotateRatioY;
    CGFloat newScaleRatio;
    CGFloat aspectRatio;
}

@end

@implementation ViewController

-(void)gestureAction:(UIGestureRecognizer *)gesture{
    
    enum{
        NONE_GestureRecognizer = 0,
        SingleTapGestureRecognizer = 1,
        DoubleTapGestureRecognizer,
        PinchGestureRecognizer,
        PanTapGestureRecognizer
    };
    
    int gestureType = NONE_GestureRecognizer;
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
        if (((UITapGestureRecognizer *)gesture).numberOfTapsRequired == 1) {
            gestureType = SingleTapGestureRecognizer;
        }else if (((UITapGestureRecognizer *)gesture).numberOfTapsRequired == 2){
            gestureType = DoubleTapGestureRecognizer;
        }
    }else if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]){
        gestureType = PinchGestureRecognizer;
    }else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]){
        gestureType = PanTapGestureRecognizer;
    }else{
        NSLog(@"can not action to the gesture");
    }

#pragma  自定义OpenGLES操作
    switch (gestureType) {
        case SingleTapGestureRecognizer:
            NSLog(@"SingleTapGestureRecognizer: do nothing");
            break;
        case DoubleTapGestureRecognizer:
            NSLog(@"DoubleTapGestureRecognizer");
            newScaleRatio = 1;
            break;
        case PinchGestureRecognizer:
            NSLog(@"PinchGestureRecognizer");
            newScaleRatio = newScaleRatio*((UIPinchGestureRecognizer *)gesture).scale;
            NSLog(@"%f,%f",aspectRatio,newScaleRatio);
            break;
        case PanTapGestureRecognizer:
            NSLog(@"PanTapGestureRecognizer");
            translateX = translateX+[((UIPanGestureRecognizer *)gesture) translationInView:self.view].x;
            //translateY = translateY+[((UIPanGestureRecognizer *)gesture) translationInView:self.view].y;
            rotateRatioY = translateX/self.view.bounds.size.width/newScaleRatio*45;
            //rotateRatioX = translateY*aspectRatio/self.view.bounds.size.height/newScaleRatio*45;
            break;
        default:
            break;
    }
    
    //[_glkView display];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{

    NSLog(@"glkView");
    
#pragma  共同的OpenGLES操作
    [_baseEffect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    //开启了三个缓存
    [self.vertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexNormalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeScale(1.0f*newScaleRatio, aspectRatio*newScaleRatio, 1.0f*newScaleRatio);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(rotateRatioY), 0.0f, 1.0f, 0.0f);
    
    //GLKView更新绘图操作
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:sphereNumVerts];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    translateX = 0;
    translateY = 0;
    rotateRatioX = 0;
    rotateRatioY = 0;
    newScaleRatio = 1.0f;
    
    _singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
    _singleTap.numberOfTapsRequired = 1;
    _singleTap.numberOfTouchesRequired=1;
    _doubleTaps = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
    _doubleTaps.numberOfTapsRequired = 2;
    _doubleTaps.numberOfTouchesRequired=1;
    _pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
    _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
    
    _glContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    //_glkView = [[GLKView alloc]initWithFrame:self.view.bounds context:_glContext];
    //[self.view addSubview:_glkView];
    _glkView = (GLKView *)self.view;
    NSAssert([_glkView isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    [_glkView setContext:_glContext];
    [EAGLContext setCurrentContext:_glContext];
    
    [_glkView addGestureRecognizer:_singleTap];
    [_glkView addGestureRecognizer:_doubleTaps];
    [_glkView addGestureRecognizer:_pinch];
    [_glkView addGestureRecognizer:_pan];
    _glkView.delegate = self;
    [_singleTap requireGestureRecognizerToFail:_doubleTaps];//只有当(_doubleTaps失败/没有监测到_doubleTaps)之后才会启用_singleTap
    
    //开启深度缓存
    _glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    _baseEffect = [[GLKBaseEffect alloc]init];
    
    //加载纹理
    CGImageRef image = [[UIImage imageNamed:@"360_1024x512"] CGImage];
    GLKTextureInfo *imageInfo = [GLKTextureLoader textureWithCGImage:image options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:nil];
    _baseEffect.texture2d0.name = imageInfo.name;
    _baseEffect.texture2d0.target = imageInfo.target;
    
    //创建顶点缓存（区别于preperToDraw）
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                 initWithAttribStride:(3 * sizeof(GLfloat))
                                 numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat))
                                 bytes:sphereVerts
                                 usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                               initWithAttribStride:(3 * sizeof(GLfloat))
                               numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
                               bytes:sphereNormals
                               usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                     initWithAttribStride:(2 * sizeof(GLfloat))
                                     numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
                                     bytes:sphereTexCoords
                                     usage:GL_STATIC_DRAW];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);

    aspectRatio = self.view.bounds.size.width/self.view.bounds.size.height;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
