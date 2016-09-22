//
//  FSLabel.m
//  Pods
//
//  Created by Tomas Srna on 12/09/16.
//
//

#import <Foundation/Foundation.h>
#import "FSLabel.h"

@interface FSLabel ()

@end

@implementation FSLabel

- (nonnull id) initWithTitle:(nonnull NSString*)title tag:(nonnull NSString*)tag color:(nullable UIColor*)color font:(nullable UIFont*)font position:(CGPoint)position alignment:(NSTextAlignment)alignment {
    _title = title;
    _tag = tag;
    _color = color;
    _font = font;
    _position = position;
    _uiLabel = nil;
    _alignment = alignment;
    
    return self;
}

@end
