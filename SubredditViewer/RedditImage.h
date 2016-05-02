//
//  RedditImage.h
//  SubredditViewer
//
//  Created by Luiz Fernando 2 on 4/28/16.
//  Copyright © 2016 CiriglianoApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedditImage : NSObject

@property (nonatomic) CGSize size;
@property (strong, nonatomic) NSString *thumbnailURLString;
@property (strong, nonatomic) NSString *sourceURLString;

-(id) initWithDictionary:(NSDictionary *)dict;

@end
