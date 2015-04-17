//
//  ViewController.m
//  MetroCollectionLayoutSample
//
//  Created by Karthik M R on 16/04/15.
//  Copyright (c) 2015 Karti Codes. All rights reserved.
//

#import "ViewController.h"

static NSString *const MetroCollectionCellIdentifier = @"MetroCollectionViewCell";
static NSString *const MetroCollectionHeaderIdentifier = @"MetroCollectionViewHeader";
static NSString *const MetroCollectionFooterIdentifier = @"MetroCollectionViewFooter";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initialiseCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization
-(void)initialiseCollectionView{
    self.collectionView.collectionViewLayout = [[MetroCollectionLayout alloc] initWithDelegate:self];
}

#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MetroCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MetroCollectionCellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cell;
}

#pragma mark - Collection View Delegates
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *supplementaryView;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MetroCollectionHeaderIdentifier forIndexPath:indexPath];
    }else{
        supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:MetroCollectionFooterIdentifier forIndexPath:indexPath];
    }
    return supplementaryView;
}

#pragma mark - Metro Collection Layout Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(MetroCollectionLayout *)collectionViewLayout estimatedSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 83);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(MetroCollectionLayout *)collectionViewLayout estimatedSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 83);
}

-(CGFloat)wideCellWidthForCollectionView:(UICollectionView *)collectionView andLayout:(MetroCollectionLayout *)collectionViewLayout{
    return CGRectGetWidth(self.collectionView.bounds)/2;
}

-(NSInteger)numberOfItemsPerGroupForCollectionView:(UICollectionView *)collectionView andLayout:(MetroCollectionLayout *)collectionViewLayout{
    return 5;
}

-(BOOL)shouldAutoAlignCollectionView:(UICollectionView *)collectionView{
    return NO;
}

- (MetroCollectionLayoutDirection)collectionView:(UICollectionView *)collectionView layout:(MetroCollectionLayout *)collectionViewLayout directionForGroup:(NSInteger)group inSection:(NSInteger)section{
    if (group % 2 == 0) {
        return MetroCollectionLayoutDirectionLeft;
    } else {
        return MetroCollectionLayoutDirectionRight;
    }
}

@end
