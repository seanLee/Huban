//
//  ObjcRuntime.h
//  Huban
//
//  Created by sean on 15/7/24.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

//获取一个类的所有属性名字:类型名字,具有@property的,父类的获取不了
NSDictionary *GetPropertyListOfObject(NSObject *object);
NSDictionary *GetPropertyListOfClass(Class cls);

void Swizzle(Class c, SEL origSEL, SEL newSEL);