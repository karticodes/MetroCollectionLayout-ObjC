//
//  MetroFlowLayout.h
//  FlowLayoutSample
//
//  Created by Karthik on 3/19/15.
//  Copyright (c) 2015 Karthik. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Enum to represent the wide cell direction
 */
typedef NS_ENUM(NSUInteger, MetroCollectionLayoutDirection) {
    MetroCollectionLayoutDirectionLeft,
    MetroCollectionLayoutDirectionRight
};

@class MetroCollectionLayout;

@protocol MetroCollectionLayoutDelegate <NSObject>

@optional

/**
 *  Optional Delegate - If not implemented, half the width of collectionview is taken.
 *  gets the wide cell width to be used throughout the layout.
 *  @return CGFloat representing the wide cell width.
 */
-(CGFloat)wideCellWidthForCollectionView:(UICollectionView *)collectionView andLayout:(MetroCollectionLayout *)collectionViewLayout;

/**
 *  Should be an odd positive integer.
 *  Optional Delegate - If not implemented, 3 is taken for iPhone and 5 is taken for iPad.
 *  gets the number of items per group(number of collection items in the wide cell range) to be used in the layout.
 *  @return NSInteger representing number of items per group.
 */
-(NSInteger)numberOfItemsPerGroupForCollectionView:(UICollectionView *)collectionView andLayout:(MetroCollectionLayout *)collectionViewLayout;

/**
 *  Optional Delegate - If not implemented, self.shouldAutoAlign = NO;
 *  Determines whether the layout to be autoaligned, if items count per section is lesser than expected in order to avoid the empty
 *  spaces.
 *  @return BOOL representing the auto alignment.
 */
-(BOOL)shouldAutoAlignCollectionView:(UICollectionView *)collectionView;

/**
 *  Optional Delegate - If not implemented, taken alternatively starting from MetroCollectionLayoutDirectionLeft.
 *  gets the direction in which the wide cell to be aligned. If MetroCollectionLayoutDirectionLeft, the wide cell starts from left.
 *  @return MetroCollectionLayoutDirection representing the wide cell direction.
 */
- (MetroCollectionLayoutDirection)collectionView:(UICollectionView *)collectionView layout:(MetroCollectionLayout *)collectionViewLayout directionForGroup:(NSInteger)group inSection:(NSInteger)section;

/**
 *  Optional Delegate - If not implemented, the value taken as 0.
 *  gets the estimated size of Section header.
 *  @return CGSize representing the estimated size of Section Header.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(MetroCollectionLayout *)collectionViewLayout estimatedSizeForHeaderInSection:(NSInteger)section;

/**
 *  Optional Delegate - If not implemented, the value taken as 0.
 *  gets the estimated size of Section footer.
 *  @return CGSize representing the estimated size of Section footer.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(MetroCollectionLayout *)collectionViewLayout estimatedSizeForFooterInSection:(NSInteger)section;

@end

@interface MetroCollectionLayout : UICollectionViewLayout

@property (nonatomic, weak) id<MetroCollectionLayoutDelegate> delegate;
- (instancetype)initWithDelegate:(id<MetroCollectionLayoutDelegate>)delegate;

@end
