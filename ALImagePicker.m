
//
//  ALImagePicker.m
//  LOFTERCam
//
//  Created by ZQP on 14-7-8.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "ALImagePicker.h"

@interface ALImagePicker ()
{
    NSMutableArray *_allAssetsArray;
    
    NSMutableArray *_assetLibraryGroups;
    
    int _allAssetsint;
    
    NSMutableArray *_assetsForGroupArray;
}
@end

@implementation ALImagePicker{

}
+(instancetype)shareAlImagePicker{
    static ALImagePicker *picker=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        picker=[[ALImagePicker alloc]init];
        [picker creatLoftCamAlbum];
    });
    return picker;
}
+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static ALAssetsLibrary *assetsLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    
    return assetsLibrary;
}
-(id)init{
    if (self=[super init]) {
        _allAssetsArray=[[NSMutableArray alloc]init];
        _assetLibraryGroups=[[NSMutableArray alloc]init];
        _assetsForGroupArray=[[NSMutableArray alloc]init];;
    }
    return self;
}
- (void)loadAssetsGroups
{
    [_assetLibraryGroups removeAllObjects];
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _allAssetsint=0;
        
        @autoreleasepool {
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
            {
                if (group==nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong ALImagePicker *strongSelf = weakSelf;
                        NSNumber *allAlassetsN=[[NSNumber alloc]initWithInt:_allAssetsint];
                        [_assetLibraryGroups insertObject:allAlassetsN atIndex:0];
                        NSArray *array=[_assetLibraryGroups copy];
                        [strongSelf.delegate alImagePickerController:strongSelf DidFinshPickGroups:array];
                    });
                    return;
                }
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"LOFTCam"]) {
                    return;
                }
                
                int propertyType=[[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                if(propertyType==ALAssetsGroupSavedPhotos){
                    [_assetLibraryGroups insertObject:group atIndex:0];
                }else if(propertyType==ALAssetsGroupAlbum){
                    if(_assetLibraryGroups.count>=1)[_assetLibraryGroups insertObject:group atIndex:1];
                    else [_assetLibraryGroups addObject:group];
                }else if(propertyType!=ALAssetsGroupPhotoStream){
                    [_assetLibraryGroups addObject:group];
                }
                if (propertyType!=ALAssetsGroupPhotoStream) _allAssetsint+=group.numberOfAssets;//把相册的所有照片数量加起来，然后作为全部照片的数量 放数组的第一个元素传过去。
                
                
            };
            
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                NSLog(@"A problem occured. Error: %@", error.localizedDescription);
            };
            
            [[ALImagePicker defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                          usingBlock:assetGroupEnumerator
                                                                        failureBlock:assetGroupEnumberatorFailure];

        }
        
    });
}
- (void)loadassetsForGroup:(ALAssetsGroup*)group{
    [_assetsForGroupArray removeAllObjects];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __strong typeof(self) strongSelf = weakSelf;
        @autoreleasepool {
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {

        if (result == nil)
        {
            return;
        }
        [_assetsForGroupArray addObject:result];
    }];
            

        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *array=[_assetsForGroupArray copy];
            [strongSelf.delegate alImagePickerController:self didFinishPickingMediaWithInfo:array fromGroup:group];
        });

 
    });

}
- (void)loadAllAssets{
    [_allAssetsArray removeAllObjects];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __strong typeof(self) strongSelf = weakSelf;


            @autoreleasepool {
                void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                {
                    if (group == nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //                                    NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)
                            NSArray *array=[_allAssetsArray copy];
                            [strongSelf.delegate alImagePickerController:self didFinishPickingMediaWithInfo:array fromGroup:nil];
                        });
                        return;
                    }
                    
                    NSString *type=[group valueForProperty:ALAssetsGroupPropertyType];

                    if (type.intValue==ALAssetsGroupPhotoStream) {
                        return;
                    }
                    
                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"LOFTCam"]) {
                        return;
                    }
                    if (type.intValue==ALAssetsGroupSavedPhotos) {
                        [group enumerateAssetsWithOptions:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                            if (result == nil)
                            {
                                return;
                            }
                            [_allAssetsArray insertObject:result atIndex:0];
                        }];
                    }else{
                        [group enumerateAssetsWithOptions:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                            if (result == nil)
                            {
                                return;
                            }
                            [_allAssetsArray addObject:result];
                        }];
                    }
                };
                
                void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                    NSLog(@"A problem occured. Error: %@", error.localizedDescription);
                    //                [self.imagePickerController performSelector:@selector(didFail:) withObject:error];
                };
                [[ALImagePicker defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                    usingBlock:assetGroupEnumerator
                                                                  failureBlock:assetGroupEnumberatorFailure];
//                NSLog(@"组外");

            }
    });

}
-(void)creatLoftCamAlbum{
    BOOL hasAlbum=[[NSUserDefaults  standardUserDefaults] boolForKey:@"HASLOFTCAMALBUM"];
    if (hasAlbum) return;

    [[ALImagePicker defaultAssetsLibrary] addAssetsGroupAlbumWithName:@"LOFTCam" resultBlock:^(ALAssetsGroup *group) {
    
        NSURL *url=[group valueForProperty:ALAssetsGroupPropertyURL];
        NSLog(@"%@",[url absoluteString]);
        
        [[NSUserDefaults  standardUserDefaults] setBool:YES forKey:@"HASLOFTCAMALBUM"];
        [[NSUserDefaults  standardUserDefaults] setURL:url forKey:@"LOFTCAMALBUMURL"];
        
    } failureBlock:^(NSError *error) {
        
    }];
}

@end
