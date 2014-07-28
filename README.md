AlassetsLibraryPicker
=====================
- (void)alImagePickerController:(ALImagePicker *)picker didFinishPickingMediaWithInfo:(NSArray *)info fromGroup:(ALAssetsGroup *)group{
    self.assets=info;
    NSString *groupName=[group valueForProperty:ALAssetsGroupPropertyName];
    if (group==nil) {
        groupName=@"全部照片";
    }
    [_headerView setLabelPhotoCount:info.count photoGroupName:groupName];
    collectionViewIsFirstRefrshShouldSlow=YES;
    [self.collectionView reloadData];
}
- (void)alImagePickerController:(ALImagePicker *)picker DidFinshPickGroups:(NSArray *)groups{
    _groupTableVC.alGroupsInfo=groups;
    [_groupTableVC.tableView reloadData];
}

////

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier=@"PickImageCell";
    PickImageViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    ALAsset *asset=self.assets[indexPath.item];
    cell.imageView.image=asset.thumbnail;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupVCCell" forIndexPath:indexPath];
    
        ALAssetsGroup *group=self.alGroupsInfo[indexPath.row];
        
        NSInteger number=[group numberOfAssets];
        NSString *nameSt=[group valueForProperty:ALAssetsGroupPropertyName];
        string=[nameSt stringByAppendingFormat:@"(%ld张)",(long)number];
    
    [cell.label setText:string];
    
    return cell;
}
