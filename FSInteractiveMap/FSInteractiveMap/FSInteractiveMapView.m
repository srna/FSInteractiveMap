//
//  FSInteractiveMapView.m
//  FSInteractiveMap
//
//  Created by Arthur GUIBERT on 23/12/2014.
//  Copyright (c) 2014 Arthur GUIBERT. All rights reserved.
//

#import "FSInteractiveMapView.h"
#import "FSSVG.h"
#import "FSLabel.h"
#import <UIKit/UIKit.h>

@interface FSInteractiveMapView ()

@property (nonatomic, strong) FSSVG* svg;
@property (nonatomic, strong) NSMutableArray* scaledPaths;
@property (nonatomic, strong) NSMutableArray* countryLabels;

@end

@implementation FSInteractiveMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self) {
        _scaledPaths = [NSMutableArray array];
        _labels = [NSMutableArray array];
        _countryLabels = [NSMutableArray array];
        [self setDefaultParameters];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self) {
        _scaledPaths = [NSMutableArray array];
        _labels = [NSMutableArray array];
        _countryLabels = [NSMutableArray array];
        [self setDefaultParameters];
    }
    
    return self;
}

- (void)setDefaultParameters
{
    self.fillColor = [UIColor colorWithWhite:0.85 alpha:1];
    self.strokeColor = [UIColor colorWithWhite:0.6 alpha:1];
}

#pragma mark - Labels

- (void)addLabel:(FSLabel*)label
{
    CGRect frameWithInsets = CGRectMake(self.frame.origin.x + _insets.origin.x, self.frame.origin.y + _insets.origin.y, self.frame.size.width - (_insets.size.width + _insets.origin.x), self.frame.size.height - (_insets.size.height + _insets.origin.y));
    float scaleHorizontal = frameWithInsets.size.width / _svg.bounds.size.width;
    float scaleVertical = frameWithInsets.size.height / _svg.bounds.size.height;
    float scale = MIN(scaleHorizontal, scaleVertical);
    
    UILabel *uiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    uiLabel.text = label.title;
    uiLabel.numberOfLines = 2;
    uiLabel.textAlignment = NSTextAlignmentCenter;
    
    if(label.font)
        uiLabel.font = label.font;
    
    if(label.color)
        uiLabel.textColor = label.color;
    
    [uiLabel sizeToFit];
    
    [self addSubview:uiLabel];
    label.uiLabel = uiLabel;
    
    [self positionLabel:label];
    
    [_labels addObject:label];
}

- (void)removeLabels
{
    while(_labels.count > 0)
    {
        FSLabel *label = _labels.lastObject;
        [label.uiLabel removeFromSuperview];
        _labels.removeLastObject;
    }
}

- (void)positionLabel:(FSLabel*)label
{
    label.uiLabel.frame = CGRectMake(label.uiLabel.frame.origin.x, label.uiLabel.frame.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [label.uiLabel sizeToFit];
    CGAffineTransform transform = [self getAffineTransform];
    CGPoint position = CGPointApplyAffineTransform(label.position, transform);
    position.x -= label.uiLabel.frame.size.width/2;
    position.y -= label.uiLabel.frame.size.height/2;
    label.uiLabel.frame = CGRectMake(position.x, position.y, label.uiLabel.frame.size.width, label.uiLabel.frame.size.height);
}

- (void)zoomLabelsWithScale:(CGFloat)scale screenScale:(CGFloat)screenScale
{
    [_labels enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        FSLabel* label = (FSLabel*)obj;
        label.uiLabel.font = [label.uiLabel.font fontWithSize:(label.font.pointSize / scale)];
        label.uiLabel.contentScaleFactor = scale * screenScale;
        
        [label.uiLabel sizeToFit];
        [self positionLabel:label];
    }];
}

#pragma mark - SVG map loading

- (void)loadMap:(NSString*)mapName withColors:(NSDictionary*)colorsDict titles:(NSDictionary*)titlesDict
{
    _svg = [FSSVG svgWithFile:mapName];
    
    [_countryLabels removeAllObjects];
    
    for (FSSVGPathElement* path in _svg.paths) {
        CGAffineTransform scaleTransform = [self getAffineTransform];
        
        UIBezierPath* scaled = [path.path copy];
        [scaled applyTransform:scaleTransform];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = scaled.CGPath;
        
        // Setting CAShapeLayer properties
        shapeLayer.strokeColor = self.strokeColor.CGColor;
        shapeLayer.lineWidth = 0.4;
        
        if(path.fill) {
            if(colorsDict && [colorsDict objectForKey:path.identifier]) {
                UIColor* color = [colorsDict objectForKey:path.identifier];
                shapeLayer.fillColor = color.CGColor;
            } else {
                shapeLayer.fillColor = self.fillColor.CGColor;
            }
            
        } else {
            shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        }
        
        [self.layer addSublayer:shapeLayer];
        
        CGPoint midPoint = [path getMidPoint];
        
        [_scaledPaths addObject:scaled];
        
        if ([titlesDict objectForKey:path.identifier]) {
            [_countryLabels addObject:[[FSLabel alloc]
                                       initWithTitle:[titlesDict objectForKey:path.identifier]
                                       tag:@"country_title"
                                       color:[UIColor whiteColor]
                                       font:[UIFont systemFontOfSize:10.0]
                                       position:midPoint]];
        }
    }
}

- (NSMutableArray*)getCountryLabels
{
    return _countryLabels;
}

- (CGAffineTransform)getAffineTransform
{
    // Create frame with insets
    CGRect frameWithInsets = CGRectMake(self.frame.origin.x + _insets.origin.x, self.frame.origin.y + _insets.origin.y, self.frame.size.width - (_insets.size.width + _insets.origin.x), self.frame.size.height - (_insets.size.height + _insets.origin.y));
    
    // Make the map fits inside the frame
    float scaleHorizontal = frameWithInsets.size.width / _svg.bounds.size.width;
    float scaleVertical = frameWithInsets.size.height / _svg.bounds.size.height;
    float scale = MIN(scaleHorizontal, scaleVertical);
    
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    scaleTransform = CGAffineTransformMakeScale(scale, scale);
    scaleTransform = CGAffineTransformTranslate(scaleTransform,-_svg.bounds.origin.x, -_svg.bounds.origin.y);
    scaleTransform = CGAffineTransformTranslate(scaleTransform, _insets.origin.x/scale, _insets.origin.y/scale);
    
    // Center
    scaleTransform = CGAffineTransformTranslate(scaleTransform, (frameWithInsets.size.width/scale - _svg.bounds.size.width) / 2, (frameWithInsets.size.height/scale - _svg.bounds.size.height) / 2);
    
    return scaleTransform;
}

- (void)loadMap:(NSString*)mapName withData:(NSDictionary*)data colorAxis:(NSArray*)colors titles:(NSDictionary*)titlesDict
{
    [self loadMap:mapName withColors:[self getColorsForData:data colorAxis:colors] titles: titlesDict];
}

- (NSDictionary*)getColorsForData:(NSDictionary*)data colorAxis:(NSArray*)colors
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:[data count]];
    
    float min = MAXFLOAT;
    float max = -MAXFLOAT;
    
    for (id key in data) {
        NSNumber* value = [data objectForKey:key];
        
        if([value floatValue] > max)
            max = [value floatValue];
        
        if([value floatValue] < min)
            min = [value floatValue];
    }
    
    for (id key in data) {
        NSNumber* value = [data objectForKey:key];
        float s = ([value floatValue] - min) / ( ((max-min) == 0 ? 1 : (max-min)) );
        float segmentLength = 1.0 / ( (([colors count] - 1) == 0 ? 1 : ([colors count] - 1)) );
        
        int minColorIndex = MAX(floorf(s / segmentLength),0);
        int maxColorIndex = MIN(ceilf(s / segmentLength), [colors count] - 1);
        
        UIColor* minColor = colors[minColorIndex];
        UIColor* maxColor = colors[maxColorIndex];
        
        s -= segmentLength * minColorIndex;
        
        CGFloat maxColorRed = 0;
        CGFloat maxColorGreen = 0;
        CGFloat maxColorBlue = 0;
        CGFloat minColorRed = 0;
        CGFloat minColorGreen = 0;
        CGFloat minColorBlue = 0;
        
        [maxColor getRed:&maxColorRed green:&maxColorGreen blue:&maxColorBlue alpha:nil];
        [minColor getRed:&minColorRed green:&minColorGreen blue:&minColorBlue alpha:nil];
        
        UIColor* color = [UIColor colorWithRed:minColorRed * (1.0 - s) + maxColorRed * s
                                         green:minColorGreen * (1.0 - s) + maxColorGreen * s
                                          blue:minColorBlue * (1.0 - s) + maxColorBlue * s
                                         alpha:1];
        
        [dict setObject:color forKey:key];
    }
    
    return dict;
}

#pragma mark - Updating the colors and/or the data

- (void)setColors:(NSDictionary*)colorsDict
{
    for(int i=0;i<[_scaledPaths count];i++) {
        FSSVGPathElement* element = _svg.paths[i];
        
        if([self.layer.sublayers[i] isKindOfClass:CAShapeLayer.class] && element.fill) {
            CAShapeLayer* l = (CAShapeLayer*)self.layer.sublayers[i];
            
            if(element.fill) {
                if(colorsDict && [colorsDict objectForKey:element.identifier]) {
                    UIColor* color = [colorsDict objectForKey:element.identifier];
                    l.fillColor = color.CGColor;
                } else {
                    l.fillColor = self.fillColor.CGColor;
                }
            } else {
                l.fillColor = [[UIColor clearColor] CGColor];
            }
        }
    }
}

- (void)setData:(NSDictionary*)data colorAxis:(NSArray*)colors
{
    [self setColors:[self getColorsForData:data colorAxis:colors]];
}

#pragma mark - Layers enumeration

- (void)enumerateLayersUsingBlock:(void (^)(NSString *, CAShapeLayer *))block
{
    for(int i=0;i<[_scaledPaths count];i++) {
        FSSVGPathElement* element = _svg.paths[i];
        
        if([self.layer.sublayers[i] isKindOfClass:CAShapeLayer.class] && element.fill) {
            CAShapeLayer* l = (CAShapeLayer*)self.layer.sublayers[i];
            block(element.identifier, l);
        }
    }
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    for(int i=0;i<[_scaledPaths count];i++) {
        UIBezierPath* path = _scaledPaths[i];
        if ([path containsPoint:touchPoint])
        {
            FSSVGPathElement* element = _svg.paths[i];
            
            if([self.layer.sublayers[i] isKindOfClass:CAShapeLayer.class] && element.fill) {
                CAShapeLayer* l = (CAShapeLayer*)self.layer.sublayers[i];
                
                if(_clickHandler) {
                    _clickHandler(element.identifier, l);
                }
            }
        }
    }
}

@end
