//
//  NSObject+HWAdd.h
//  HWPopController
//
//  Created by heath wang on 2019/5/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (HWAdd)

+ (BOOL)hw_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;

+ (BOOL)hw_swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

/// 设置weak类型的关联对象，在对象销毁时，指针自动置空
/// @param object 被关联对象
/// @param key 唯一标识
/// @param value 关联对象
void objc_setAssociatedObject_weak(id _Nonnull object, const void * _Nonnull key, id _Nullable value);

@end

NS_ASSUME_NONNULL_END
