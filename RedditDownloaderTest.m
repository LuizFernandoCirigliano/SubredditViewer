//
//  RedditDownloaderTest.m
//  SubredditViewer
//
//  Created by Luiz Fernando 2 on 4/28/16.
//  Copyright © 2016 CiriglianoApps. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RedditDownloader.h"

@interface RedditDownloaderTest : XCTestCase

@property (strong, nonatomic) RedditDownloader *rd;
@property (strong, nonatomic) NSDictionary *json;
@end

@interface RedditDownloader (Testing)

-(NSArray *) getPhotoArrayFromJSON:(NSDictionary *)redditJSON;

@end

@implementation RedditDownloaderTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.rd = [[RedditDownloader alloc] initWithSubreddit:@"roomporn"];
    NSString * filePath = [[NSBundle bundleForClass:[self class] ] pathForResource:@"testjson" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    self.json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void) testJsonParsing {
    
    NSArray *photos = [self.rd getPhotoArrayFromJSON:self.json];
    
    XCTAssertEqual(3, photos.count);
    XCTAssertTrue([[photos[0] sourceURLString] isEqualToString:@"https://i.redditmedia.com/LCLCF9B4XbGGw30oSVbKJJcFuBBBW1q-pEvu1JXAe3Q.jpg?s=27316476641a12c22f5949bd6a0f6945"]);
}

-(void) testDownload {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Download works"];
    
    [self.rd getNextPicturesWithCompletion:^(NSArray * _Nullable photos, NSError * _Nullable error) {
        XCTAssertNotNil(photos);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}



@end
