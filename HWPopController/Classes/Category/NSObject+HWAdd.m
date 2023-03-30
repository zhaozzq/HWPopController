//
//  NSObject+HWAdd.m
//  HWPopController
//
//  Created by heath wang on 2019/5/21.
//

#import "NSObject+HWAdd.h"
#import <objc/runtime.h>

@implementation NSObject (HWAdd)

+ (BOOL)hw_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
	Method originalMethod = class_getInstanceMethod(self, originalSel);
	Method newMethod = class_getInstanceMethod(self, newSel);
	if (!originalMethod || !newMethod) return NO;

	class_addMethod(self,
			originalSel,
			class_getMethodImplementation(self, originalSel),
			method_getTypeEncoding(originalMethod));
	class_addMethod(self,
			newSel,
			class_getMethodImplementation(self, newSel),
			method_getTypeEncoding(newMethod));

	method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
			class_getInstanceMethod(self, newSel));
	return YES;
}

+ (BOOL)hw_swizzleClassMethod:(SEL)originalSel with:(SEL)newSel {
	Class class = object_getClass(self);
	Method originalMethod = class_getInstanceMethod(class, originalSel);
	Method newMethod = class_getInstanceMethod(class, newSel);
	if (!originalMethod || !newMethod) return NO;
	method_exchangeImplementations(originalMethod, newMethod);
	return YES;
}

void objc_setAssociatedObject_weak(id _Nonnull object, const void * _Nonnull key, id _Nullable value) {
    
    //子类的名字
    NSString *name = [NSString stringWithFormat:@"AssociationWeak_%@", NSStringFromClass([value class])];
    Class class = objc_getClass(name.UTF8String);
    
    //如果子类不存在，动态创建子类
    if (!class) {
        class = objc_allocateClassPair([value class], name.UTF8String, 0);
        objc_registerClassPair(class);
    }
    
    SEL deallocSEL = NSSelectorFromString(@"dealloc");
    Method deallocMethod = class_getInstanceMethod([value class], deallocSEL);
    const char *types = method_getTypeEncoding(deallocMethod);
    
    //在子类dealloc方法中将object的指针置为nil
    IMP imp = imp_implementationWithBlock(^(id _s, int k) {
        
#ifdef DEBUG
        NSLog(@"-dealloc-\nvalue = %@", _s);
#endif
        objc_setAssociatedObject(object, key, nil, OBJC_ASSOCIATION_ASSIGN);
    });
    
    //添加子类的dealloc方法
    class_addMethod(class, deallocSEL, imp, types);
    
    //将value的isa指向动态创建的子类
    object_setClass(value, class);
    
    objc_setAssociatedObject(object, key, value, OBJC_ASSOCIATION_ASSIGN);
}

@end
