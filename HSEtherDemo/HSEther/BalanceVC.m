//
//  BalanceVC.m
//  HSEther
//

//

#import "BalanceVC.h"

#import "HSEther.h"
@interface BalanceVC ()
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;

@end

@implementation BalanceVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"hs_getBalanceWithTokens";

    [HSEther hs_getBalanceWithTokens:@[@"0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0",@"0x0806552bc66a44d9ebe4af007cbb93114c4c0a76"] withAddress:@"0xe83aec696478bba2404eaa0eb9b1f2d58269d637" block:^(NSArray *arrayBanlance, BOOL suc) {

        self.centerLabel.text = [NSString stringWithFormat:@"以太坊地址【0xe83aec696478bba2404eaa0eb9b1f2d58269d637】的\n\n以太坊余额为 %@\n\nEOS余额为 %@\n\nZAG余额为 %@\n\n\n关于余额为何特别长，因为不同代币数量小数位数是不一样的，比如以太坊可以保留18位小数",arrayBanlance.firstObject,arrayBanlance[1],arrayBanlance.lastObject];
        
        //余额验证请点击
        //https://etherscan.io/address/0xe83aec696478bba2404eaa0eb9b1f2d58269d637
    }];
}


@end
