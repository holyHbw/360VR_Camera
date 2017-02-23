//
//  ViewController.h
//  360Camera_testbed
//
//  Created by 黄博闻 on 17/2/23.
//  Copyright © 2017年 黄博闻. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "sphere.h"

@interface ViewController : GLKViewController//<GLKViewDelegate>

@property(nonatomic)GLKView *glkView;
@property(nonatomic)EAGLContext *glContext;
@property(nonatomic)UITapGestureRecognizer *singleTap;
@property(nonatomic)UITapGestureRecognizer *doubleTaps;
@property(nonatomic)UIPinchGestureRecognizer *pinch;
@property(nonatomic)UIPanGestureRecognizer *pan;

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;//法线
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@end

