//
//  ViewController.h
//  MetroCollectionLayoutSample
//
//  Created by Karthik M R on 16/04/15.
//  Copyright (c) 2015 Karti Codes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroCollectionLayout.h"
#import "MetroCollectionViewCell.h"

@interface ViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, MetroCollectionLayoutDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end

