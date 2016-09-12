//
//  FSLabel.h
//  Pods
//
//  Created by Tomas Srna on 09/09/16.
//
//

#ifndef FSLabel_h
#define FSLabel_h

@interface FSLabel : NSObject

@property (nonatomic, strong, nonnull) NSString* title;
@property (nonatomic, strong, nonnull) NSString* tag;
@property (nonatomic, strong, nullable) UIColor* color;
@property (nonatomic, strong, nullable) UIFont* font;
@property (nonatomic) CGPoint position;
@property (nonatomic, strong, nullable) UILabel* uiLabel;

- (nonnull id) initWithTitle:(nonnull NSString*)title tag:(nonnull NSString*)tag color:(nullable UIColor*)color font:(nullable UIFont*)font position:(CGPoint)position;

@end

#endif /* FSLabel_h */
