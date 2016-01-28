//  Created by Oleg on 2015.
//  Copyright (c) 2015 Oleg Hnidets. All rights reserved.
//

#import "DemoViewController.h"
#import "OHSubtitlePlayer.h"

@interface DemoViewController ()

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (strong, nonatomic) IBOutlet OHSubtitlePlayer *subtitlePlayer;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //------------------------
    
    NSString *movieFilePath = [[NSBundle mainBundle] pathForResource:@"hemly.mp4" ofType:nil];

    
//        self.player = [[KSVideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height*0.57, self.view.frame.size.width) contentURL:[NSURL URLWithString:@"https://scontent.cdninstagram.com/hphotos-xfa1/t50.2886-16/11719145_918467924880620_816495633_n.mp4"]];
    
    //        self.player = [[KSVideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height*0.57, self.view.frame.size.width) contentURL:[[NSBundle mainBundle]
    //                                                                                                                                                          URLForResource:@"hemly"
    //                                                                                                                                                          withExtension:@"mp4"]];

    
    [self.subtitlePlayer loadViewControllerComponentsWithURL:[NSURL fileURLWithPath:movieFilePath] showSubtitleView:YES];
    [self.subtitlePlayer loadSubtitleWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example.vtt" ofType:nil]];
    
    [self.subtitlePlayer.subtitleView.button addTarget:self action:@selector(didPressSubtitleButton) forControlEvents:UIControlEventTouchUpInside];
    self.subtitlePlayer.subtitleView.titleLabel.text = @"English";
}

- (void)didPressSubtitleButton {
    NSLog(@"Click");
}

@end
