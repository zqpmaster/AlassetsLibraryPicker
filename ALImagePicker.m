//

//
//  ALImagePicker.m
//
//  Created by ZQP on 14-7-8.
//


#import "ALImagePicker.h"
#import "Utility.h"
@interface ALImagePicker ()
{
//    NSMutableArray *_allAssetsArray;
    
    NSMutableArray *_assetLibraryGroups;
    
    int _allAssetsint;
    
    NSMutableArray *_assetsForGroupArray;
    
    NSMutableArray *_allAssetsGroupArrayTemp;
    
}

@property (nonatomic,strong)NSMutableArray *allAssetsArray;
@end

@implementation ALImagePicker{

}
+(instancetype)shareAlImagePicker{
    static ALImagePicker *picker=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        picker=[[ALImagePicker alloc]init];
//        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [picker creatAlbumWithName:@"TheNameOfAlbum" semaphore:nil];
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

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
        self.allAssetsArray=[[NSMutableArray alloc]init];
        _assetLibraryGroups=[[NSMutableArray alloc]init];
        _assetsForGroupArray=[[NSMutableArray alloc]init];
        _loftCamAssetsSet=[[NSMutableSet alloc]init];
    }
    return self;
}
- (void)loadAssetsGroups
{
    [_assetLibraryGroups removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        _allAssetsint=0;
        
        @autoreleasepool {
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
            {

                if (group==nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSNumber *allAlassetsN=[[NSNumber alloc]initWithInt:_allAssetsint];
                        [_assetLibraryGroups insertObject:allAlassetsN atIndex:0];
                        NSArray *array=[_assetLibraryGroups copy];
                        [self.delegate alImagePickerController:self DidFinshPickGroups:array];
                    });
                    return;
                }
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"LOFTCam"]) {
                    [self loadLOFTCamToSet:group];
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
                if (propertyType!=ALAssetsGroupPhotoStream) {
                    _allAssetsint+=[self countOfTheGroup:group];
                }//把相册的所有照片数量加起来，然后作为全部照片的数量 放数组的第一个元素
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

- (void)loadAllAssets{
    
    dispatch_group_t loadingGroup = dispatch_group_create();
    NSMutableArray * assets = [[NSMutableArray array] init];
    NSMutableArray * albums = [[NSMutableArray array] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    @autoreleasepool {
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if(index != NSNotFound) {
            if ([self filterAsset:asset]) {
                return;
            }
            [assets addObject:asset];
        } else {
            dispatch_group_leave(loadingGroup);
        }
    };
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            NSString *type=[group valueForProperty:ALAssetsGroupPropertyType];
            
            if (type.intValue==ALAssetsGroupPhotoStream) {
                return;
            }
            
            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"LOFTCam"]) {
                [self loadLOFTCamToSet:group];
                return;
            }
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if (type.intValue==ALAssetsGroupSavedPhotos) {
                [albums insertObject:group atIndex:0];

            }else{
                [albums addObject: group];
            }
            
        } else {

            NSLog(@"Found %ld albums", (long)[albums count]);
            // album loading is done
            for (ALAssetsGroup * album in albums) {
                dispatch_group_enter(loadingGroup);
                [album enumerateAssetsWithOptions:NSEnumerationReverse usingBlock: assetEnumerator];
            }
            dispatch_group_notify(loadingGroup, dispatch_get_main_queue(), ^{
                NSLog(@"DONE: ALAsset array contains %ld elements", (long)[assets count]);
                [[self delegate] alImagePickerController:self didFinishPickingMediaWithInfo:assets fromGroup:nil];
            });
        }
    };
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
        NSLog(@"A problem occured. Error: %@", error.localizedDescription);
        //                [self.imagePickerController performSelector:@selector(didFail:) withObject:error];
    };

    [[ALImagePicker defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                                        usingBlock:assetGroupEnumerator
                                                      failureBlock:assetGroupEnumberatorFailure];
    }
    });
    
}

-(void)loadAssetsForGroupWithName:(NSString *)name{
    [[ALImagePicker defaultAssetsLibrary]  enumerateGroupsWithTypes:ALAssetsGroupAlbum
                         usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                             
                             //compare the names of the albums
                             if ([name compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                 [self loadassetsForGroup:group isFilter:NO];
                                 return;
                             }
                         }failureBlock:^(NSError *error) {
                             
                         }];
}
- (void)loadassetsForGroup:(ALAssetsGroup*)group isFilter:(BOOL)isFilter{
    [_assetsForGroupArray removeAllObjects];
    
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result == nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSArray *array=[_assetsForGroupArray copy];
                        [[self delegate] alImagePickerController:self didFinishPickingMediaWithInfo:array fromGroup:group];
                    });
                    return;
                }
                if (isFilter&&[self filterAsset:result]) {
                    return;
                }
                [_assetsForGroupArray addObject:result];
            }];
            
            
        }
        
    });
    
}

-(void)creatAlbumWithName:(NSString*)name semaphore:(dispatch_semaphore_t)semaphore{

    [[ALImagePicker defaultAssetsLibrary] assetsGroupForGroupName:name withResult:^(ALAssetsGroup *group) {
        if (group) {
            return;
        }
        [[ALImagePicker defaultAssetsLibrary] addAssetsGroupAlbumWithName:name resultBlock:^(ALAssetsGroup *group) {
            
        } failureBlock:^(NSError *error) {
            NSLog(@"无法创建相册相册");
            [[NSNotificationCenter defaultCenter] postNotificationName:CamForbidNotification object:nil];
        }];
        
    }];
}

-(NSInteger)countOfTheGroup:(ALAssetsGroup *)group{
    __block NSInteger count=0;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result==nil) {
            dispatch_semaphore_signal(semaphore);
            return;
        }
        if ([self filterAsset:result]) {
            return;
        }
        count++;
        }];
    });

    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
    return count;
}
-(void)deleteAsset:(ALAsset *)asset{
    [asset setImageData:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
    }];
}
-(BOOL)filterAsset:(ALAsset*)asset{
    if ([asset.defaultRepresentation.filename hasSuffix:@".PNG"]) {
        return YES;
    }
    if (asset.defaultRepresentation.dimensions.width*asset.defaultRepresentation.dimensions.height < 2500) {
        return YES;
    }
        return NO;
}

@end
