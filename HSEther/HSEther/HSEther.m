//
//  HSEther.m
//  HSEther
//
//  Created by 侯帅 on 2018/4/20.
//  Copyright © 2018年 com.houshuai. All rights reserved.
//

#import "HSEther.h"
#import <ethers/ethers.h>

@interface HSEther()

@end

@implementation HSEther



#pragma mark - 创建

//创建钱包
+(void)hs_createWithPwd:(NSString *)pwd block:(void(^)(NSString *address,NSString *keyStore,NSString *mnemonicPhrase,NSString *privateKey))block
{
    
    //创建随机私钥
    Account *account = [Account randomMnemonicAccount];
    
    
    //创建keystore
    [account encryptSecretStorageJSON:pwd callback:^(NSString *json)
    {
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        //地址
        NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
        
        //私钥
        NSString *privateKeyStr = [SecureData dataToHexString:account.privateKey];
        
        //回调
        block(addressStr,json,account.mnemonicPhrase,privateKeyStr);
    }];
}



#pragma mark - 导入

//助记词导入
+(void)hs_inportMnemonics:(NSString *)mnemonics pwd:(NSString *)pwd block:(void(^)(NSString *address,NSString *keyStore,NSString *mnemonicPhrase,NSString *privateKey,BOOL suc,HSWalletError error))block
{
    if (mnemonics.length < 1)
    {
        block(@"",@"",@"",@"",NO,HSWalletErrorMnemonicsLength);
        return;
    }
    
    if (pwd.length < 1)
    {
        block(@"",@"",@"",@"",NO,HSWalletErrorPwdLength);
        return;
    }
    
    
    NSArray *arrayMnemonics = [mnemonics componentsSeparatedByString:@" "];
    if (arrayMnemonics.count != 12)
    {
        block(@"",@"",@"",@"",NO,HSWalletErrorMnemonicsCount);
        return;
    }
    
    
    
    for (NSString *m in arrayMnemonics)
    {
        if (![Account isValidMnemonicWord:m])
        {
            NSString *msg = [NSString stringWithFormat:@"助记词 %@ 有误", m];
            NSLog(@"%@",msg);
            block(@"",@"",@"",@"",NO,HSWalletErrorMnemonicsValidWord);
            return;
        }
    }
    
    
    
    
    if (![Account isValidMnemonicPhrase:mnemonics])
    {
        block(@"",@"",@"",@"",NO,HSWalletErrorMnemonicsValidPhrase);
        return;
    }
    
    
    
    Account *account = [Account accountWithMnemonicPhrase:mnemonics];
    if (pwd == nil || [pwd isEqualToString:@""])
    {
        block(account.address.checksumAddress,@"没有keystore，请传入密码即可生成私钥",account.mnemonicPhrase,@"没有私钥，请传入密码即可生成私钥",YES,HSWalletImportMnemonicsSuc);
    }
    else
    {
        //生成keystore
        [account encryptSecretStorageJSON:pwd callback:^(NSString *json)
        {
            NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            //地址
            NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
            
            //私钥
            NSString *privateKeyStr = [SecureData dataToHexString:account.privateKey];
            
            //回调
            block(addressStr,json,account.mnemonicPhrase,privateKeyStr,YES,HSWalletImportMnemonicsSuc);
            
        }];
    }
    
}







//keystore导入
+(void)hs_importKeyStore:(NSString *)keyStore
                     pwd:(NSString *)pwd
                   block:(void(^)(NSString *address,NSString *keyStore,NSString *mnemonicPhrase,NSString *privateKey,BOOL suc,HSWalletError error))block
{
    if (pwd.length < 1)
    {
        block(@"",@"",@"",@"",NO,HSWalletErrorPwdLength);
        return;
    }
    
    if (keyStore.length < 1)
    {
        block(@"",@"",@"",@"",NO,HSWalletErrorKeyStoreLength);
        return;
    }
    
    //解密keystory
    [Account decryptSecretStorageJSON:keyStore password:pwd callback:^(Account *account, NSError *NSError)
    {
        if (NSError)
        {
            NSLog(@"keyStore解密失败%@",NSError.localizedDescription);
            block(@"",@"",@"",@"",NO,HSWalletErrorKeyStoreValid);
            return ;
        }
        else
        {
            if (pwd == nil || [pwd isEqualToString:@""])
            {
                block(account.address.checksumAddress,@"没有keystore，请传入密码即可生成私钥",account.mnemonicPhrase,@"没有私钥，请传入密码即可生成私钥",YES,HSWalletImportKeyStoreSuc);
            }
            else
            {
                
                [account encryptSecretStorageJSON:pwd callback:^(NSString *json)
                {
                    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:nil];
                    
                    //地址
                    NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
                    
                    //私钥
                    NSString *privateKeyStr = [SecureData dataToHexString:account.privateKey];
                    
                    //回调
                    block(addressStr,json,account.mnemonicPhrase,privateKeyStr,YES,HSWalletImportKeyStoreSuc);
                }];
            }
        }
    }];
}






//私钥导入
+(void)hs_importWalletForPrivateKey:(NSString *)privateKey
                                pwd:(NSString *)pwd
                              block:(void(^)(NSString *address,NSString *keyStore,NSString *mnemonicPhrase,NSString *privateKey,BOOL suc,HSWalletError error))block
{
    if (privateKey.length < 1)
    {
        block(@"",@"",@"",@"",NO,HSWalletErrorPrivateKeyLength);
        return;
    }
    
    if (pwd.length < 1)
    {
        block(@"",@"",@"",@"",NO,HSWalletErrorPwdLength);
        return;
    }
    
    //解密私钥
    Account *account = [Account accountWithPrivateKey:[SecureData hexStringToData:[privateKey hasPrefix:@"0x"]?privateKey:[@"0x" stringByAppendingString:privateKey]]];
    
    //生成keystore
    [account encryptSecretStorageJSON:pwd callback:^(NSString *json)
    {
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
        //地址
        NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
        
        //私钥
        NSString *privateKeyStr = [SecureData dataToHexString:account.privateKey];
        
        //回调
        block(addressStr,json,account.mnemonicPhrase,privateKeyStr,YES,HSWalletImportPrivateKeySuc);
    }];
}







#pragma mark - 查询

//查询余额
+(void)hs_getBalanceWithTokens:(NSArray<NSString *> *)arrayToken
                   withAddress:(NSString *)address
                         block:(void(^)(NSArray *arrayBanlance,BOOL suc))block
{
    
    //校验地址长度
    if (address.length != @"0x4f3B600378BD40b93B85DFd8A4aDf7c05E719672".length)
    {
        NSLog(@"%@ 地址错误",address);
        block([NSArray array],NO);
        return;
    }
    

    //创建一个数组，保存所有的查询条件------{地址：币种}
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@{@"contractAddress":address,@"symbol":@"eth",@"type":@"eth"}];
    for (NSString *tokenStr in arrayToken)
    {
        [array addObject:@{@"contractAddress":tokenStr,@"symbol":@"",@"type":@"eth"}];
    }
    
    
    //缓存在本地
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"HSCoinListArrayM"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    //创建查询器
//    EtherscanProvider * scanner = [[EtherscanProvider alloc]initWithChainId:ChainIdHomestead];
    EtherscanProvider * scanner = [[EtherscanProvider alloc]initWithChainId:ChainIdRopsten];
    
    
    //创建地址
    Address * addressObjc = [Address addressWithString:address];
    
    
    //查询器开始查询地址
    [[scanner getTokenBalance:addressObjc] onCompletion:^(ArrayPromise *promise)
    {
        
        if (!promise.result || promise.error)
        {
            NSLog(@"%@ hs_getBalanceWithTokens 获取失败",address);
            block([NSArray array],NO);
        }
        
        
        else
        {
            NSMutableArray *arrayBalance = [NSMutableArray array];
            for (Erc20Token *obj in promise.value)
            {
                [arrayBalance addObject:obj.balance.decimalString];
            }
            block(arrayBalance,YES);
        }
    }];
    
}









#pragma mark - 交易

//转账必读！！！！
//【 1】供3种方式  1 以太坊官方限流配置https://etherscan.io/apis   2 web3配置（找你们公司后台）  3 infura配置（https://infura.io）  本方式使用以太坊官方限流配置RCWEX6WYBXMJZHD5FD617NZ99TZADKBEDJ（这个是我侯帅的key，你们最好自己去申请）
//【2】 转账前先弄清楚参数意义 see https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sendtransaction
//【3】 转账签名方式 分为eth转账和 erc20（代币）转账，分别是不同的签名。
//提供3种方式  1 以太坊官方限流配置   2 web3配置  3 infura配置  本方式使用以太坊官方限流配置RCWEX6WYBXMJZHD5FD617NZ99TZADKBEDJ


+(void)hs_sendToAssress:(NSString *)toAddress money:(NSString *)money tokenETH:(NSString *)tokenETH decimal:(NSString *)decimal currentKeyStore:(NSString *)keyStore pwd:(NSString *)pwd gasPrice:(NSString *)gasPrice gasLimit:(NSString *)gasLimit block:(void(^)(NSString *hashStr,BOOL suc,HSWalletError error))block
{
    
    //创建账号
    __block Account * senderAccount;
    
    
    //创建查询器
//    __block EtherscanProvider * queryManager = [[EtherscanProvider alloc]initWithChainId:ChainIdHomestead apiKey:@"RCWEX6WYBXMJZHD5FD617NZ99TZADKBEDJ"];
    __block EtherscanProvider * queryManager = [[EtherscanProvider alloc]initWithChainId:ChainIdRopsten apiKey:@"EnzWrJh0nqFufb0bv2ka"];
    
    
    
    //从keystore获取发送人地址
    NSData *jsonData = [keyStore dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    __block NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
    
    
    
    //从发送人地址，创建交易对象
    __block Transaction * transactionManager = [Transaction transactionWithFromAddress:[Address addressWithString:addressStr]];
    
    
    //从keystore获取私钥
    NSLog(@"1 开始新建钱包");
    [Account decryptSecretStorageJSON:keyStore password:pwd callback:^(Account *account, NSError *NSError)
    {
        if (NSError == nil)
        {
            senderAccount = account;
            NSLog(@"2 新建钱包成功 开始获取nonce");
            
            
            
            
            
            //查询之前的交易记录
            [[queryManager getTransactionCount:transactionManager.fromAddress] onCompletion:^(IntegerPromise *pro)
            {
                if (pro.error != nil)
                {
                    NSLog(@"%@获取nonce失败",pro.error);
                    
                    block(@"",NO,HSWalletErrorNotNonce);
                }
                else
                {

                    NSLog(@"3 获取nonce成功 值为%ld",pro.value);
                    transactionManager.nonce = pro.value;



                    
                    
                    
                    //查询Gas
                    NSLog(@"4 开始获取gasPrice");
                    [[queryManager getGasPrice] onCompletion:^(BigNumberPromise *proGasPrice)
                    {
                        if (proGasPrice.error == nil)
                        {

                            NSLog(@"5 获取gasPrice成功 值为%@",proGasPrice.value.decimalString);
                            
                            if (gasPrice == nil)
                            {
                                
                                transactionManager.gasPrice = proGasPrice.value;
                            }
                            else
                            {
                                NSLog(@"手动设置了gasPrice = %@",gasPrice);
                                
                                transactionManager.gasPrice = [[BigNumber bigNumberWithDecimalString:gasPrice] mul:[BigNumber bigNumberWithDecimalString:@"1000000000"]];;
                            }
                            
                            
                            
                            
                            //设置chainID
                            transactionManager.chainId = queryManager.chainId;
                            
                            
                            
                            //设置收件人地址
                            transactionManager.toAddress = [Address addressWithString:toAddress];
                            
                            
                            
                            
                            //设置转账金额
                            NSInteger i = money.doubleValue * pow(10.0, decimal.integerValue);
                            BigNumber *b = [BigNumber bigNumberWithInteger:i];
                            transactionManager.value = b;
                            
                            
                            
                            //默认ETH币
                            if (tokenETH == nil)
                            {
                                
                                if (gasLimit == nil)
                                {
                                    
                                    transactionManager.gasLimit = [BigNumber bigNumberWithDecimalString:@"21000"];
                                }
                                else
                                {
                                    
                                    NSLog(@"手动设置了gasLimit = %@",gasLimit);
                                    transactionManager.gasLimit = [BigNumber bigNumberWithDecimalString:gasLimit];
                                }
                                
                                
                                transactionManager.data = [SecureData secureDataWithCapacity:0].data;
                                
                            }
                            
                            
                            
                            //其他代币
                            else
                            {
                                
                                if (gasLimit == nil)
                                {
                                    
                                    transactionManager.gasLimit = [BigNumber bigNumberWithDecimalString:@"60000"];
                                }
                                else
                                {
                                    NSLog(@"手动设置了gasLimit = %@",gasLimit);
                                    transactionManager.gasLimit = [BigNumber bigNumberWithDecimalString:gasLimit];
                                }
                                
                                
                                
                                SecureData *data = [SecureData secureDataWithCapacity:68];
                                [data appendData:[SecureData hexStringToData:@"0xa9059cbb"]];
                                
                                NSData *dataAddress = transactionManager.toAddress.data;//转入地址（真实代币转入地址添加到data里面）
                                for (int i=0; i < 32 - dataAddress.length; i++)
                                {
                                    [data appendByte:'\0'];
                                }
                                
                                [data appendData:dataAddress];
                                
                                NSData *valueData = transactionManager.value.data;//真实代币交易数量添加到data里面
                                for (int i=0; i < 32 - valueData.length; i++)
                                {
                                    [data appendByte:'\0'];
                                }
                                [data appendData:valueData];
                                
                                transactionManager.value = [BigNumber constantZero];
                                transactionManager.data = data.data;
                                transactionManager.toAddress = [Address addressWithString:tokenETH];//合约地址（代币交易 转入地址为合约地址）
                                
                                
                            }
                            
                            
                            
                            
                            
                            
                            //签名
                            [senderAccount sign:transactionManager];
                            
                            
                            //发送
                            NSData * signedTransaction = [transactionManager serialize];
                            
                            
                            
                            NSLog(@"6 开始转账");
                            [[queryManager sendTransaction:signedTransaction] onCompletion:^(HashPromise * pro)
                            {
                                
                                NSLog(@"CloudKeychainSigner: Sent - signed=%@ hash=%@ error=%@", signedTransaction, pro.value, pro.error);
                                
                                if (pro.error == nil)
                                {
                                    NSLog(@"\n---------------【生成转账交易成功！！！！】--------------\n哈希值 = %@\n",transactionManager.transactionHash.hexString);
                                    NSLog(@" 7成功 哈希值 =  %@",pro.value.hexString);
                                    
                                    block(pro.value.hexString,YES,HSWalletSucSend);
                                    [[queryManager getTransaction:pro.value]onCompletion:^(TransactionInfoPromise *info) {
                                        if (info.error == nil)
                                        {
                                            NSLog(@"===%@",info.value.transactionHash.hexString);
                                        }
                                        else
                                        {
                                            
                                            NSLog(@" 9查询哈希%@失败 %@",pro.value.hexString,pro.error);
                                        }
                                    }];
                                    
                                }
                                else
                                {
                                    NSLog(@" 8转账失败 %@",pro.error);
                                    block(@"",NO,HSWalletErrorSend);
                                }
                            }];
                        }
                        else
                        {
                            
                            block(@"",NO,HSWalletErrorNotGasPrice);
                        }
                    }];



                }
            }];



        }
        else
        {
            NSLog(@"密码错误%@",NSError);
            block(@"",NO,HSWalletErrorPWD);
        }
    }];
}

@end
