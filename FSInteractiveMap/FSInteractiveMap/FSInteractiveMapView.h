//
//  FSInteractiveMapView.h
//  FSInteractiveMap
//
//  Created by Arthur GUIBERT on 23/12/2014.
//  Copyright (c) 2014 Arthur GUIBERT. All rights reserved.
//

#import "FSLabel.h"
#import <UIKit/UIKit.h>

@interface FSInteractiveMapView : UIView

// Graphical properties
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic, strong) UIColor* strokeColor;
@property (nonatomic, strong) NSMutableArray* labels;
@property (nonatomic) CGRect insets;
@property (nonatomic, strong) UIFont* countryFont;

// Click handler
@property (nonatomic, copy) void (^clickHandler)(NSString* identifier, CAShapeLayer* layer);

// Loading functions
- (void)loadMap:(NSString*)mapName withColors:(NSDictionary*)colorsDict strokeColors:(NSDictionary*)strokeColors titles:(NSDictionary*)titlesDict;
- (void)loadMap:(NSString*)mapName withData:(NSDictionary*)data colorAxis:(NSArray*)colors titles:(NSDictionary*)titlesDict;

// Set the colors by element, if you want to make the map dynamic or update the colors
- (void)setColors:(NSDictionary*)colorsDict;
- (void)setData:(NSDictionary*)data colorAxis:(NSArray*)colors;

// Layers enumeration
- (void)enumerateLayersUsingBlock:(void(^)(NSString* identifier, CAShapeLayer* layer))block;

// Labels
- (void)addLabel:(FSLabel*)label;
- (void)removeLabels;
- (void)zoomLabelsWithScale:(CGFloat)scale screenScale:(CGFloat)screenScale;
- (NSMutableArray*)getCountryLabels;

@end
