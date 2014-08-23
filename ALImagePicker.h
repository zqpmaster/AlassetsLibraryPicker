//
//  ALImagePicker.h
//
//  Created by ZQP on 14-7-8.
//

#import <Foundation/Foundation.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@class ALImagePicker;

@protocol ALImagePickerDelegate <NSObject>

@optional;
- (void)alImagePickerController:(ALImagePicker *)picker didFinishPickingMediaWithInfo:(NSArray *)info fromGroup:(ALAssetsGroup*)group;//如果group为nil，为所有照片
- (void)alImagePickerController:(ALImagePicker *)picker DidFinshPickGroups:(NSArray*)groups;

@end

@interface ALImagePicker : NSObject

+ (ALAssetsLibrary *)defaultAssetsLibrary;
+ (instancetype)shareAlImagePicker;

//@property (nonatomic, strong) NSMutableArray *assetsGroups;
//@property (nonatomic, strong) NSMutableArray *assets;
//@property (strong) ALAssetsGroup *assetsGroup;
@property (weak,nonatomic)id<ALImagePickerDelegate>delegate;

- (void)loadAssetsGroups;//完成后会执行代理方法DidFinshPickGroups
- (void)loadAllAssets;//完成后会执行代理方法didFinishPickingMediaWithInfo
- (void)loadassetsForGroup:(ALAssetsGroup*)group isFilter:(BOOL)isFilter;//完成后会执行代理方法didFinishPickingMediaWithInfo
- (void)loadAssetsForGroupWithName:(NSString *)namel;
- (NSInteger)countOfTheGroup:(ALAssetsGroup*)group;

-(void)deleteAsset:(ALAsset*)asset;
@end
