AlassetsLibraryPicker
=====================
<pre><code> 
- (void)alImagePickerController:(ALImagePicker *)picker didFinishPickingMediaWithInfo:(NSArray *)info fromGroup:(ALAssetsGroup *)group{
    self.assets=info;
    NSString *groupName=[group valueForProperty:ALAssetsGroupPropertyName];
    [self.collectionView reloadData];
}
</pre></code> 
<pre><code> 
- (void)alImagePickerController:(ALImagePicker *)picker DidFinshPickGroups:(NSArray *)groups{
    _groupTableVC.alGroupsInfo=groups;
    [_groupTableVC.tableView reloadData];
}
</pre></code> 


<pre><code> 
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier=@"PickImageCell";
    PickImageViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    ALAsset *asset=self.assets[indexPath.item];
    cell.imageView.image=asset.thumbnail;
}
</pre></code> 

<pre><code> 
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
</pre></code> 
