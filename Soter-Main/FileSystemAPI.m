//
//  FileSystemAPI.m
//  iFDiSKSDK
//
//  Created by Mac_ohm on 12/9/27.
//
//

//#import "FileSystemAPI.h"

#import <Foundation/Foundation.h>
#import "FileSystemAPI.h"
#import "Language.h"
#import "LanguageViewController.h"


//================================================================================
@interface FileSystemAPI ()
{
    FileSystemController *fscController;
    
    BYTE byDataBuf[MAX_APIDATA_SIZE];
    BOOL isFileSystemInitial;
    uint64_t _uintFileSize, _uintTranSize;
    
    NSArray *nsaFilePattern;
    NSData *nsdFileNameASCII, *nsdFileNameUTF16;
    
    int intHandle;
    BOOL processEnd;
    UIAlertView *formatAlert;
    NSTimer *formatProcess;
    
}
@end

//================================================================================
@implementation FileSystemAPI
@synthesize fsAPIDelegate = _fsAPIDelegate;
@synthesize uintFileSize = _uintFileSize;
@synthesize uintTranSize = _uintTranSize;
@synthesize delegateForAPI;

//================================================================================
//Initial the fileSystem and set delegate
- (id)init:(id)idDelegate
{
    fscController = [FileSystemController sharedController];
    
    isFileSystemInitial = NO;
    
    [self doInitialFileSystem];
    
    _fsAPIDelegate = idDelegate;
    
    nsaFilePattern = @[PATTEN_SFN_ROOT];
    
    return self;
}

#pragma mark - OTG Encrypt/Descrypt Function
//================================================================================
//Ray add FileSystemAPI for SoterAegis 20150913
//Ray 20151011
//For stop operate
//start
//Ray add FileSystemAPI for SoterAegis 20150915
//Decryption file in OTG
- (BOOL)doAESDecryptOTGfile:(NSString *)nssSrcPath passWord:(NSString *)nssPassWord
{
    int handle;
    
    //[Read source file]
    handle = 1;
    NSData *nsSrcData = [self doReadOTGfile:nssSrcPath];
    
    //[Is encrypt file(target file name) exist?]
    NSString *nssDestPath = [nssSrcPath substringWithRange:NSMakeRange (0, nssSrcPath.length - 4)];//".enc" length
    handle = 1;
    handle = [fscController openFileAbsolutePath:nssDestPath openMode:OF_READ];
    
    if(handle == 0){
        //Ray 20151007
        //For Decrypt flash back to home page
        handle = [fscController closeFile:handle];
        
        NSString *str = [NSString stringWithFormat:[Language get:@"FileSystemAPI_msg1" alter:@"Target file(%@) is exist!"], nssDestPath];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return false;
    }
    //Ray 20151007
    //For Encrypt flash back to home page
    handle = [fscController closeFile:handle];
    
    //Ray for Ver.1.0.1
    //For fill 32 bytes
    if (nssPassWord.length < 32) {
        NSString *strPadding = @"00000000000000000000000000000000";//32 bytes
        nssPassWord = [strPadding stringByReplacingCharactersInRange:NSMakeRange(0, nssPassWord.length) withString:nssPassWord];
    }
//    NSString *str1 = [NSString stringWithFormat:@"nssPassWord(%@)", nssPassWord];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:str1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [alert show];
//    });
    
    //[Decrypt file by HW]
    NSData *nsmDecData = [self doAESDecryptByData:nsSrcData passWord:nssPassWord];
    if (nsmDecData == nil) {
        NSString *str = [Language get:@"FileSystemAPI_msg2" alter:@"It is't correct password!"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return false;
    }
    
    //[Write file to OTG]
    [self doWriteFileToOTGbyData:nssDestPath fileName:nsmDecData];
    
    return true;
}
//end

//================================================================================
//Ray add FileSystemAPI for SoterAegis 20150913
//Encryption data
//Ray for Ver.1.0.3
- (void)doWriteFileToOTGbyData:(NSString *)nssWrtFileName fileName:(NSData *)nsData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //[Is source file exist]
        int read_intHandle = 1;
        read_intHandle = [fscController openFileAbsolutePath:nssWrtFileName openMode:OF_READ];
        if(read_intHandle != 0){
            [fscController closeFile:read_intHandle];
            NSString *str = [Language get:@"FileSystemAPI_msg3" alter:@"Source file is't exist!"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
            return;
        }
        
        uint64_t FATblockSize;
        if ([fscController getFATType] == EXFAT) {
            FATblockSize = 32768; //exFAT defult:32K
        }
        else{ //FAT32
            FATblockSize = 8192; //FAT32 defult:8K
        }
        
        uint64_t srcFileSize = [fscController getFileSize:read_intHandle];
        uint64_t spaceSize = [fscController getAvailableSpace];
        if ((srcFileSize > spaceSize)) {
            [fscController closeFile:read_intHandle];
            NSString *str = @"Available Space is't enough!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
            return;
        }
        
        //[OTG create file]
        read_intHandle = 1;
        read_intHandle = [fscController openFileAbsolutePath:nssWrtFileName openMode:OF_CREATE];
        
        //[Get data size]
        uint32_t uintDataCount = 0;
        uint64_t uintDataSize = 0, uintDataOffset = 0, uintDataTranLen = 0;
        uintDataSize = nsData.length;
        _uintFileSize = uintDataSize;
        
        while((uintDataCount != -1) && (uintDataSize != 0)){
            @autoreleasepool{
                uintDataTranLen = ((uintDataSize > MAX_APIDATA_SIZE) ? MAX_APIDATA_SIZE : uintDataSize);
                NSData *aData = [nsData subdataWithRange:NSMakeRange(uintDataOffset, uintDataTranLen)];
                uintDataCount = [fscController writeFile:read_intHandle writeBuf:aData writeSize:(uint32_t)uintDataTranLen];
                uintDataOffset += uintDataCount;
                uintDataSize -= uintDataCount;
                _uintTranSize += uintDataCount;
            }
        }
        read_intHandle = [fscController closeFile:read_intHandle];
    });
}
//end

//================================================================================
//Ray add FileSystemAPI for SoterAegis 20150913
//Encryption data
- (NSMutableData *)doAESEncryptByData:(NSData *)nsSrcData passWord:(NSString *)nssPassWord
{
//    NSString *str = [NSString stringWithFormat:@"nssPassWord(%@)", nssPassWord];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [alert show];
//    });

    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
    
    //Count start
    //    clock_t start,finish;
    //    double totaltime;
    //    start=clock();
    //[Create encrypt temporary file]
    NSMutableData *nsmEncData = [NSMutableData data];
    
    //[Create file tag]
    //    [self debugMessageShow:@"[Create file tag]"];
    uint32_t srcSrcDataSize =  (uint32_t)nsSrcData.length;
    
    memcpy(byDataBuf, [[self addAESPaddingDataWithFileSize:srcSrcDataSize] bytes], MAX_SECTORSIZE);
    
    //Sent the encryption password, isEncrypt: YES = encrypt  , NO = decrypt
    BOOL isEncrypt = YES;
    [fscController initAESwithPassword:nssPassWord withType:isEncrypt];
    
    //First sent the AES file tag by 512 bytes
    [fscController sendAESData:byDataBuf withLen:MAX_SECTORSIZE];

//    NSString *str = [NSString stringWithFormat:@"nssPassWord(%@)", nssPassWord];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [alert show];
//    });

    //Byte to NSData
    NSData *nsTagBuf = [NSData dataWithBytes:byDataBuf length:MAX_SECTORSIZE];
    
    //Append tag
    [nsmEncData appendData:nsTagBuf];
    
    //[Encrypt file]
    //    [self debugMessageShow:@"[Encrypt file]"];
    
    //[Sector encryption]
    uint32_t index = 0;
    uint32_t lastDataLen = srcSrcDataSize;
    uint32_t uintTranDataLen = 0;
    //    [self debugMessageShow:@"lastDataLen(%d)", lastDataLen];
    

    @synchronized(self){
        do {
            @autoreleasepool {
                //Source file data <= 512B
                uintTranDataLen = ((lastDataLen > MAX_SECTORSIZE) ? MAX_SECTORSIZE : lastDataLen);
                //                [self debugMessageShow:@"uintTranDataLen(%d)", uintTranDataLen];
                
                //Get segment data bytes (512B)
                //Ray for ver.0.3.0
                [nsSrcData getBytes:byDataBuf range:NSMakeRange (index, uintTranDataLen)];
                //[nsSrcData getBytes:byDataBuf range:NSMakeRange (index, MAX_SECTORSIZE)];
                
                index += uintTranDataLen;
                //                [self debugMessageShow:@"index(%d)", index];
                
                //HW encryption
                [fscController sendAESData:byDataBuf withLen:uintTranDataLen];
                
                //Byte to NSData
                NSData *nsDataBuf = [NSData dataWithBytes:byDataBuf length:MAX_SECTORSIZE];
                
                //Append data
                [nsmEncData appendData:nsDataBuf];
                
                lastDataLen -= uintTranDataLen;
                //                [self debugMessageShow:@"lastDataLen(%d)", lastDataLen];
            }
        } while (lastDataLen);
    }
    

    //--------
//    do {
//        dataLenRead = read(srcHandle, byDataBuf, sizeof(byDataBuf));
//        if(dataLenRead % MAX_SECTORSIZE)
//            dataLenRead += MAX_SECTORSIZE - (dataLenRead % MAX_SECTORSIZE);
//        [fscController sendAESData:byDataBuf withLen:dataLenRead];
//        write(desHandle, byDataBuf, dataLenRead);
//    } while (dataLenRead);
    //--------
    
    //Disable the AES encrypt function
    [fscController setAESDisable];
    
    //    [self debugMessageShow:@"srcSrcDataSize(%d)", srcSrcDataSize];
    //    [self debugMessageShow:@"nsmEncData(%ld)", nsmEncData.length];
    
    //    //Count end
    //    finish=clock();
    //    totaltime=(double)(finish-start)/(double)CLOCKS_PER_SEC;
    //    [self debugMessageShow:@"doAESEncryptByData:totaltime(%f)", totaltime];
    return nsmEncData;
    //});
}

//================================================================================
//Ray add FileSystemAPI for SoterAegis 20150915
//Decryption data
- (NSMutableData *)doAESDecryptByData:(NSData *)nsSrcData passWord:(NSString *)nssPassWord
{
    //[Create Decrypt temporary file]
    NSMutableData *nsmDecData = [NSMutableData data];
    
    //[Create file tag]
    //[self debugMessageShow:@"[Create file tag]"];
    uint32_t srcSrcDataSize =  (uint32_t)nsSrcData.length;
    memcpy(byDataBuf, [[self addAESPaddingDataWithFileSize:srcSrcDataSize] bytes], MAX_SECTORSIZE);
    
    //Sent the encryption password, isEncrypt: YES = encrypt  , NO = decrypt
    BOOL isEncrypt = NO;
    [fscController initAESwithPassword:nssPassWord withType:isEncrypt];
    [nsSrcData getBytes:byDataBuf range:NSMakeRange (0, MAX_SECTORSIZE)];
    [fscController sendAESData:byDataBuf withLen:MAX_SECTORSIZE];
    NSString *fileTag;
    fileTag = [[NSString alloc] initWithBytes:byDataBuf length:[AESFILETAG length] encoding:NSUTF8StringEncoding];
    
    //Determine whether the correct password
    if([fileTag isEqualToString:AESFILETAG] == NO){
        [fscController setAESDisable];
        return nil;
    }
    
    //[Encrypt file]
    uint32_t index = MAX_SECTORSIZE;//second sector
    uint32_t lastDataLen = 0;//fileTotalSize;
    uint32_t uintTranDataLen = 0;
    
    ((uint8_t *)&lastDataLen)[0] = byDataBuf[[AESFILETAG length] + 3];
    ((uint8_t *)&lastDataLen)[1] = byDataBuf[[AESFILETAG length] + 2];
    ((uint8_t *)&lastDataLen)[2] = byDataBuf[[AESFILETAG length] + 1];
    ((uint8_t *)&lastDataLen)[3] = byDataBuf[[AESFILETAG length] + 0];

    //[Sector encryption]
    @synchronized(self){
        do {
            @autoreleasepool {
                //Source file data <= 512B
                uintTranDataLen = ((lastDataLen > MAX_SECTORSIZE) ? MAX_SECTORSIZE : lastDataLen);
                //Get segment data bytes (512B)
                [nsSrcData getBytes:byDataBuf range:NSMakeRange (index, MAX_SECTORSIZE)];
                //HW encryption
                [fscController sendAESData:byDataBuf withLen:uintTranDataLen];
                lastDataLen -= uintTranDataLen;
                //Byte to NSData
                NSData *nsDataBuf = [NSData dataWithBytes:byDataBuf length:uintTranDataLen];
                //Append data
                [nsmDecData appendData:nsDataBuf];
                index += uintTranDataLen;
            }
        } while (lastDataLen);
    }
    
    //Disable the AES decrypt function
    [fscController setAESDisable];

    return nsmDecData;
}

//================================================================================
//Ray add FileSystemAPI for SoterAegis 20150913
//Ray 20151011
//For stop operate
//start
//Encryption file in OTG
- (BOOL)doAESEncryptOTGfile:(NSString *)nssSrcPath passWord:(NSString *)nssPassWord
{
    int handle;
    
    //[Read source file]
    //Ray for Ver.0.3.0
    //for fix bug
    //handle = 1;
    NSData *nsSrcData = [self doReadOTGfile:nssSrcPath];
    
    //[Is encrypt file(target file name) exist?]
    NSString *nssDestPath = [nssSrcPath stringByAppendingString:ENCRYPT_FILE];
    handle = 1;
    handle = [fscController openFileAbsolutePath:nssDestPath openMode:OF_READ];
    
    if(handle == 0){
        //Ray 20151007
        //For Encrypt flash back to home page
        handle = [fscController closeFile:handle];
        NSString *str = [NSString stringWithFormat:[Language get:@"FileSystemAPI_msg1" alter:@"Target file(%@) is exist!"], nssDestPath];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return false;
    }
    
    //For Encrypt flash back to home page
    handle = [fscController closeFile:handle];
    
    //Ray for Ver.1.0.1
    //For fill 32 bytes
    if (nssPassWord.length < 32) {
        NSString *strPadding = @"00000000000000000000000000000000";//32 bytes
        nssPassWord = [strPadding stringByReplacingCharactersInRange:NSMakeRange(0, nssPassWord.length) withString:nssPassWord];
    }
//    NSString *str1 = [NSString stringWithFormat:@"nssPassWord(%@)", nssPassWord];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:str1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [alert show];
//    });
    
    //[Encrypt file by HW]
    NSData *nsmEncData = [self doAESEncryptByData:nsSrcData passWord:nssPassWord];
    
    //[Write file to OTG]
    [self doWriteFileToOTGbyData:nssDestPath fileName:nsmEncData];
    
    return true;
}
//end

#pragma MARK - File Control

//Ray add FileSystemAPI for SoterAegis 20151005
//Copy/Move file (OTG to device)
-(void)doFileOTGtoAlbum:(UInt8)nssMode SrcPath:(NSString *)nssSrcPath
{
    int read_intHandle;
    
    //[Change to root directory]
    [fscController changeDirectoryAbsolutePath:ROOT_STRING];
    //[self doChangeDirectory:ROOT_STRING];
    
    //[Is source file exist]
    [self debugMessageShow:@"[Is source file exist]"];
    read_intHandle = 0;
    read_intHandle = [fscController openFileAbsolutePath:nssSrcPath openMode:OF_READ];
    if(read_intHandle != 0){
        [fscController closeFile:read_intHandle];
        NSString *str = @"Source file is't exist!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return;
    }
    
    //[Copy file]
    [self debugMessageShow:@"[Copy file]"];
    
    if (read_intHandle != -1)
    {
        uint64_t dataLength = 0;
        uint64_t uintDataSize = 0;
        uint64_t uintDataTranLen = 0;
        
        uintDataSize = [fscController getFileSize:read_intHandle];
        //For image
        //BYTE byTotalDataBuf[uintDataSize];
        NSMutableData *nsTotalData = [NSMutableData data];
        
        @synchronized(self){
            while((dataLength != -1) && (uintDataSize != 0))
            {
                @autoreleasepool {
                    uintDataTranLen = ((uintDataSize > MAX_DATABUFFER) ? MAX_DATABUFFER : uintDataSize);
                    NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                    //Read file
                    dataLength = [fscController readFile:read_intHandle readBuf:aData readSize:(uint32_t)uintDataTranLen];
                    if ((dataLength!=0)&&(dataLength!=-1)) {
                        aData = [NSData dataWithBytes:[aData bytes] length:(uint32_t)dataLength];
                        //Write file
                        //                            [fscController writeFile:write_intHandle writeBuf:aData writeSize:(uint32_t)dataLength];
                        //                            [self debugMessageShow:@"writeFile"];
                        
                        //For image
                        [nsTotalData appendData:aData];
                    }
                    uintDataSize -= dataLength;
                }
            }
            
            //[Save to album]
            UIImage* image = [UIImage imageWithData:nsTotalData];
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
            [self debugMessageShow:@"Copy file to Album successed!"];
            
            if (nssMode == MOVE_OTG_TO_ALBUM) {
                [self doDeleteOTGfile:nssSrcPath];
                //                        //[self debugMessageShow:@"MOVE_TO_ALBUM"];
                //                        intHandle = 0;
                //                        intHandle = [fscController deleteFileAbsolutePath:nssSrcPath];
                //                        if(intHandle != -1){
                //                            [fscController packDirectory];
                //                            [self debugMessageShow:@"--- : Delete File(%@) SUCCESS!", nssSrcPath];
                //                        } else{
                //                            //[self debugMessageShow:@"--- : Delete File FAIL(%@)", nssFileName];
                //                        }
            }
            //                    else { //MOVE_TO_ALBUM
            //                        [self debugMessageShow:@"MOVE_TO_ALBUM"];
            //                    }
            
            read_intHandle = [fscController closeFile:read_intHandle];
        }
    }
    else
    {
        [self debugMessageShow:@"--- : Open file fail !!! "];
    }
    [fscController changeDirectoryAbsolutePath:ROOT_STRING];
    
    
    [self debugMessageShow:@"--- : External Copy to External End"];
    
}



//================================================================================
//Ray add FileSystemAPI for SoterAegis 20150812
//Read OTG file return NSMutableData
-(NSMutableData *)doReadOTGfile:(NSString *)nssSrcPath
{
    
    int read_intHandle;
    
    //[Change to root directory]
    [fscController changeDirectoryAbsolutePath:ROOT_STRING];
    //[self doChangeDirectory:ROOT_STRING];
    
    
    //[Is source file exist]
    //Ray for Ver.0.3.0
    //for fix bug
    read_intHandle = 1;
    read_intHandle = [fscController openFileAbsolutePath:nssSrcPath openMode:OF_READ];
    if(read_intHandle != 0){
        [fscController closeFile:read_intHandle];
        NSString *str = @"Source file is't exist!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return nil;
    }
    
    //[Copy file]
    if (read_intHandle != -1)
    {
        uint64_t dataLength = 0;
        uint64_t uintDataSize = 0;
        uint64_t uintDataTranLen = 0;
        
        uintDataSize = [fscController getFileSize:read_intHandle];
        
        //For image
        NSMutableData *nsTotalData = [NSMutableData data];
        
        @synchronized(self){
            while((dataLength != -1) && (uintDataSize != 0))
            {
                @autoreleasepool {
                    uintDataTranLen = ((uintDataSize > MAX_DATABUFFER) ? MAX_DATABUFFER : uintDataSize);
                    NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                    //Read file
                    dataLength = [fscController readFile:read_intHandle readBuf:aData readSize:(uint32_t)uintDataTranLen];
                    if ((dataLength!=0)&&(dataLength!=-1)) {
                        aData = [NSData dataWithBytes:[aData bytes] length:(uint32_t)dataLength];
                        //Write file
                        //                            [fscController writeFile:write_intHandle writeBuf:aData writeSize:(uint32_t)dataLength];
                        //                            [self debugMessageShow:@"writeFile"];
                        
                        //For image
                        [nsTotalData appendData:aData];
                    }
                    uintDataSize -= dataLength;
                }
            }
        }
        //Ray for Ver.0.3.0
        //for fix bug
        [fscController closeFile:read_intHandle];
        return nsTotalData;
    }
    //Ray for Ver.0.3.0
    //for fix bug
    [fscController closeFile:read_intHandle];
    return nil;
}

//================================================================================
//Ray add FileSystemAPI for SoterAegis 20150721
//Copy/Move file (OTG to device)
-(void)CopyFileOTGtoDevice:(UInt8)nssMode SrcPath:(NSString *)nssSrcPath
{
    int read_intHandle;
    
    //[Change to root directory]
    [fscController changeDirectoryAbsolutePath:ROOT_STRING];
    //[self doChangeDirectory:ROOT_STRING];
    
    //[Is source file exist]
    [self debugMessageShow:@"[Is source file exist]"];
    read_intHandle = 0;
    read_intHandle = [fscController openFileAbsolutePath:nssSrcPath openMode:OF_READ];
    if(read_intHandle != 0){
        [fscController closeFile:read_intHandle];
        NSString *str = @"Source file is't exist!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return;
    }
    
    //[Copy file]
    [self debugMessageShow:@"[Copy file]"];
    
    if (read_intHandle != -1)
    {
        uint64_t dataLength = 0;
        uint64_t uintDataSize = 0;
        uint64_t uintDataTranLen = 0;
        
        uintDataSize = [fscController getFileSize:read_intHandle];
        //For image
        //BYTE byTotalDataBuf[uintDataSize];
        NSMutableData *nsTotalData = [NSMutableData data];
        
        @synchronized(self){
            while((dataLength != -1) && (uintDataSize != 0))
            {
                @autoreleasepool {
                    uintDataTranLen = ((uintDataSize > MAX_DATABUFFER) ? MAX_DATABUFFER : uintDataSize);
                    NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                    //Read file
                    dataLength = [fscController readFile:read_intHandle readBuf:aData readSize:(uint32_t)uintDataTranLen];
                    if ((dataLength!=0)&&(dataLength!=-1)) {
                        aData = [NSData dataWithBytes:[aData bytes] length:(uint32_t)dataLength];
                        //Write file
                        //                            [fscController writeFile:write_intHandle writeBuf:aData writeSize:(uint32_t)dataLength];
                        //                            [self debugMessageShow:@"writeFile"];
                        
                        //For image
                        [nsTotalData appendData:aData];
                    }
                    uintDataSize -= dataLength;
                }
            }
            
            //[Save to album]
            UIImage* image = [UIImage imageWithData:nsTotalData];
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
            [self debugMessageShow:@"Copy file to Album successed!"];
            
            if (nssMode == MOVE_OTG_TO_ALBUM) {
                [self doDeleteOTGfile:nssSrcPath];
                //                        //[self debugMessageShow:@"MOVE_TO_ALBUM"];
                //                        intHandle = 0;
                //                        intHandle = [fscController deleteFileAbsolutePath:nssSrcPath];
                //                        if(intHandle != -1){
                //                            [fscController packDirectory];
                //                            [self debugMessageShow:@"--- : Delete File(%@) SUCCESS!", nssSrcPath];
                //                        } else{
                //                            //[self debugMessageShow:@"--- : Delete File FAIL(%@)", nssFileName];
                //                        }
            }
            //                    else { //MOVE_TO_ALBUM
            //                        [self debugMessageShow:@"MOVE_TO_ALBUM"];
            //                    }
            
            read_intHandle = [fscController closeFile:read_intHandle];
        }
    }
    else
    {
        [self debugMessageShow:@"--- : Open file fail !!! "];
    }
    [fscController changeDirectoryAbsolutePath:ROOT_STRING];
    
    
    [self debugMessageShow:@"--- : External Copy to External End"];
    
}

//Ray for Ver.1.0.3
//For file size
//start
//================================================================================
//Ray 20151020
//Return OTG File List (return FileName/Type/Size).
- (NSMutableArray *)doListOTGFile:(UInt8)nssMode path:(NSString *)nssPath
{
    if (nssMode == PATH_ABSOLUTE) {
        [fscController  changeDirectoryAbsolutePath:nssPath];
    }
    else {
        [fscController  changeDirectory:nssPath];
    }
    
    NSMutableArray *rtArray = [[NSMutableArray alloc]init];
    
    FFBLK ffblk;
    EXFAT_FFBLK exfatFFBLK;
    int intIndex = 0;
    NSString *tmpStr = EMPTY_STRING;
    
    if ([fscController getFATType] == EXFAT) {
        if([fscController findFirstEXFAT:tmpStr findFirstStruct:&exfatFFBLK findFirstExact:NO] == 0){
            //[self debugMessageShow:@"--- : Not Found..."];
            
        } else{
            intIndex++;
            //(1)Add file name
            tmpStr = [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length];
            [rtArray addObject:tmpStr];
            
            if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                //This is a folder
                //(2)Add file time
                [rtArray addObject:@"unknown"];
            } else{
                //This is a file
                //(2)Add file time
                UInt16 ff_date = ffblk.ff_date;
                UInt16 ff_time = ffblk.ff_time;
                UInt16 year = ((ff_date >> 9) & 127) + 1980; //year, [15:9], 63=0x7F
                UInt16 mouth = (ff_date >> 5) & 15; //mouth,[8:5], 15=0xF
                UInt16 day = ff_date & 31; //day, [4:0], 63=0x1F
                UInt16 hour = (ff_time >> 11) & 31; //year, [15:11], 31=0x1F
                UInt16 minute = (ff_time >> 5) & 63; //mouth,[10:5], 15=0x3F
                UInt16 second = ff_time & 63; //day, [4:0], 63=0x3F
                if (second > 60) {
                    second = 59;
                }
                NSString *strDate = [NSString stringWithFormat:@"%d-%d-%d  %d:%02d:%02d", year, mouth, day, hour, minute, second];
                [rtArray addObject:strDate];
            }
            
            while([fscController findNextEXFAT:&exfatFFBLK]){
                intIndex++;
                //(1)Add file name
                tmpStr = [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length];
                [rtArray addObject:tmpStr];
                
                if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                    //This is a folder
                    //(2)Add file time
                    [rtArray addObject:@"unknown"];
                } else{
                    //This is a file
                    //(2)Add file time
                    UInt16 ff_date = ffblk.ff_date;
                    UInt16 ff_time = ffblk.ff_time;
                    UInt16 year = ((ff_date >> 9) & 127) + 1980; //year, [15:9], 63=0x7F
                    UInt16 mouth = (ff_date >> 5) & 15; //mouth,[8:5], 15=0xF
                    UInt16 day = ff_date & 31; //day, [4:0], 63=0x1F
                    UInt16 hour = (ff_time >> 11) & 31; //year, [15:11], 31=0x1F
                    UInt16 minute = (ff_time >> 5) & 63; //mouth,[10:5], 15=0x3F
                    UInt16 second = ff_time & 63; //day, [4:0], 63=0x3F
                    if (second > 60) {
                        second = 59;
                    }
                    NSString *strDate = [NSString stringWithFormat:@"%d-%d-%d  %d:%02d:%02d", year, mouth, day, hour, minute, second];
                    [rtArray addObject:strDate];
                }
            }
        }
    } else {
        if([fscController findFirst:[fscController str2DataWithASCII:tmpStr] findFirstStruct:&ffblk findFirstExact:NO] == 0){
            //Not Found
        } else{
            if(ffblk.bAttributes != FA_LONGFILENAME){
                if([[fscController longFileName] isEqualToString:EMPTY_STRING]){
                    //nssFileName is short file name
                    tmpStr = [[NSString alloc] initWithBytes:ffblk.sFileName length:[fscController findStringEnd:ffblk.sFileName length:sizeof(ffblk.sFileName)] encoding:NSASCIIStringEncoding];
                } else{
                    //nssFileName is long file name
                    tmpStr = [fscController longFileName];
                }
                
                //(1)Add file name
                [rtArray addObject:tmpStr];
                
                intIndex++;
                
                //(2)Add file time
                if((ffblk.bAttributes & FA_DIREC) != 0){
                    //This is a folder
                    [rtArray addObject:@"unknown"];
                } else{
                    //This is a file
                    //                    NSString *str1 = [NSString stringWithFormat:@"file(%@)\nffblk.ff_date(%d)\nffblk.ff_time(%d)", tmpStr, ffblk.ff_date, ffblk.ff_time];
                    //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:str1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    //                        [alert show];
                    //                    });
                    
                    UInt16 ff_date = ffblk.ff_date;
                    UInt16 ff_time = ffblk.ff_time;
                    UInt16 year = ((ff_date >> 9) & 127) + 1980; //year, [15:9], 63=0x7F
                    UInt16 mouth = (ff_date >> 5) & 15; //mouth,[8:5], 15=0xF
                    UInt16 day = ff_date & 31; //day, [4:0], 63=0x1F
                    UInt16 hour = (ff_time >> 11) & 31; //year, [15:11], 31=0x1F
                    UInt16 minute = (ff_time >> 5) & 63; //mouth,[10:5], 15=0x3F
                    UInt16 second = ff_time & 63; //day, [4:0], 63=0x3F
                    if (second > 60) {
                        second = 59;
                    }
                    NSString *strDate = [NSString stringWithFormat:@"%d-%d-%d  %d:%02d:%02d", year, mouth, day, hour, minute, second];
                    [rtArray addObject:strDate];
                }
            }
            
            while(1){
                if([fscController findNext:&ffblk] == 0){ break;}
                
                if(ffblk.bAttributes != FA_LONGFILENAME){
                    if([[fscController longFileName] isEqualToString:EMPTY_STRING]){
                        //nssFileName is short file name
                        tmpStr = [[NSString alloc] initWithBytes:ffblk.sFileName length:[fscController findStringEnd:ffblk.sFileName length:sizeof(ffblk.sFileName)] encoding:NSASCIIStringEncoding];
                    } else{
                        if([fscController longFileNameIndex] != 0){ continue;}
                        //nssFileName is long file name
                        tmpStr = [fscController longFileName];
                    }
                    
                    //(1)Add file name
                    [rtArray addObject:tmpStr];
                    
                    intIndex++;
                    
                    //(2)Add file size
                    if((ffblk.bAttributes & FA_DIREC) != 0){
                        //This is a folder
                        [rtArray addObject:@"unknown"];
                    } else{
                        //This is a file
                        //                    NSString *str1 = [NSString stringWithFormat:@"file(%@)\nffblk.ff_date(%d)\nffblk.ff_time(%d)", tmpStr, ffblk.ff_date, ffblk.ff_time];
                        //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:str1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        //                    dispatch_async(dispatch_get_main_queue(), ^{
                        //                        [alert show];
                        //                    });
                        
                        UInt16 ff_date = ffblk.ff_date;
                        UInt16 ff_time = ffblk.ff_time;
                        UInt16 year = ((ff_date >> 9) & 127) + 1980; //year, [15:9], 63=0x7F
                        UInt16 mouth = (ff_date >> 5) & 15; //mouth,[8:5], 15=0xF
                        UInt16 day = ff_date & 31; //day, [4:0], 63=0x1F
                        UInt16 hour = (ff_time >> 11) & 31; //year, [15:11], 31=0x1F
                        UInt16 minute = (ff_time >> 5) & 63; //mouth,[10:5], 15=0x3F
                        UInt16 second = ff_time & 63; //day, [4:0], 63=0x3F
                        if (second > 60) {
                            second = 59;
                        }
                        NSString *strDate = [NSString stringWithFormat:@"%d-%d-%d  %d:%02d:%02d", year, mouth, day, hour, minute, second];
                        [rtArray addObject:strDate];
                    }
                }
            }
        }
    }
    return rtArray;
}
//end

//Add By Neil 09/10
- (NSMutableArray *)doListOTGFolder:(UInt8)nssMode path:(NSString *)nssPath
{
    //struct fileProperty *fProperty;
    //OTGfileProperty *fProperty = [[OTGfileProperty alloc] init];
    //NSArray *array = [ [ NSArray alloc ] initWithObjects:@"aa",@"bb",@"cc"];
    
    if (nssMode == PATH_ABSOLUTE) {
        [fscController  changeDirectoryAbsolutePath:nssPath];
    }
    else {
        [fscController  changeDirectory:nssPath];
    }
    
    NSMutableArray *rtArray = [[NSMutableArray alloc]init];
    
    //[rtArray addObjectsFromArray:array];
    
    
    //NSString *rtData = @"No Data";
    FFBLK ffblk;
    EXFAT_FFBLK exfatFFBLK;
    int intIndex = 0;
    NSString *tmpStr = EMPTY_STRING;
    
    if ([fscController getFATType] == EXFAT)
    {
        if([fscController findFirstEXFAT:tmpStr findFirstStruct:&exfatFFBLK findFirstExact:NO] == 0)
        {
            //[self debugMessageShow:@"--- : Not Found..."];
            
        }
        else
        {
            intIndex++;
            
            while([fscController findNextEXFAT:&exfatFFBLK]){
                intIndex++;
                if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                    //This is a folder
                    //[self debugMessageShow:@"--- : 1.(%03d)(D) %@", intIndex, [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length]];
                } else{
                    //This is a file
                    //[self debugMessageShow:@"--- : 1.(%03d)(F) %@", intIndex, [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length]];
                }
            }
        }
    }
    else
    {
        if([fscController findFirst:[fscController str2DataWithASCII:tmpStr] findFirstStruct:&ffblk findFirstExact:NO] == 0)
        {
            //[self debugMessageShow:@"--- : Not Found..."];
        }
        else
        {
            if(ffblk.bAttributes != FA_LONGFILENAME)
            {
                if([[fscController longFileName] isEqualToString:EMPTY_STRING])
                {
                    //nssFileName is short file name
                    tmpStr = [[NSString alloc] initWithBytes:ffblk.sFileName
                                                      length:[fscController findStringEnd:ffblk.sFileName
                                                                                   length:sizeof(ffblk.sFileName)]
                                                    encoding:NSASCIIStringEncoding];
                    
                }
                else
                {
                    tmpStr = [fscController longFileName];
                }
                
                
                
                intIndex++;
                
                if((ffblk.bAttributes & FA_DIREC) != 0){
                    //This is a folder
                    [rtArray addObject:tmpStr];
                }
            }
            
            while(1)
            {
                if([fscController findNext:&ffblk] == 0)
                {
                    break;
                }
                
                if(ffblk.bAttributes != FA_LONGFILENAME)
                {
                    if([[fscController longFileName] isEqualToString:EMPTY_STRING]){
                        //nssFileName is short file name
                        tmpStr = [[NSString alloc] initWithBytes:ffblk.sFileName length:[fscController findStringEnd:ffblk.sFileName length:sizeof(ffblk.sFileName)] encoding:NSASCIIStringEncoding];
                        //tmpStr = [tmpStr stringByAppendingString:@"_Ray3"];
                    } else{
                        if([fscController longFileNameIndex] != 0){ continue;}
                        //nssFileName is long file name
                        tmpStr = [fscController longFileName];
                        //tmpStr = [tmpStr stringByAppendingString:@"_Ray4"];
                    }
                    
                    
                    
                    intIndex++;
                    
                    if((ffblk.bAttributes & FA_DIREC) != 0){
                        //This is a folder
                        //[self debugMessageShow:@"--- : 2.(%03d)(D) %@", intIndex, tmpStr];
                        [rtArray addObject:tmpStr];
                    }
                }
            }
        }
    }
    return rtArray;
}


//================================================================================
//Ray 20150810
//Delete the OTG file
- (void)doDeleteOTGfile:(NSString *)nssSrcPath
{
    intHandle = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //dispatch_async(dispatch_get_main_queue(), ^{
        
        intHandle = [fscController deleteFileAbsolutePath:nssSrcPath];
        if(intHandle != -1){
            [fscController packDirectory];
            //[self debugMessageShow:@"--- : Delete File(%@) SUCCESS!", nssSrcPath];
        }
        //    else{
        //        //[self debugMessageShow:@"--- : Delete File FAIL(%@)", nssFileName];
        //    }
    });
    
}

//================================================================================
//Ray for Ver.1.0.3
//To add for available memory space
//start
//Write the file to OTG
- (void)doWriteFileToOTG:(NSString *)nssSrcFileName
                fileName:(NSString *)nssDestFileName;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        [Is source file exist]
        NSString *str;
        UIAlertView *alert;
//        NSString *str = [NSString stringWithFormat:@"--- :doWriteFileOTG(%@,%@)", nssSrcFileName, nssDestFileName];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [alert show];
//        });

        NSFileHandle *nsfhFile = [self readFileOpenPath:nssSrcFileName];
        
        BOOL FileCheck = [[NSFileManager defaultManager] fileExistsAtPath:nssSrcFileName];
        
        if(!FileCheck)
        {
            NSString *str = [NSString stringWithFormat:@"Source file isn't exist! %@",nssSrcFileName];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"]
                                                            message:str
                                                           delegate:self
                                                  cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"]
                                                  otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
            return;
        }
        int read_intHandle = 1;
        
        uint64_t FATblockSize;
        if ([fscController getFATType] == EXFAT) {
            FATblockSize = MIN_BLOCK_EXFAT; //exFAT defult:32K
        }
        else{ //FAT32
            FATblockSize = MIN_BLOCK_FAT32; //FAT32 defult:8K
        }
        
        
        uint64_t srcFileSize = [self returnFileSize:nssSrcFileName];
        uint64_t spaceSize = [fscController getAvailableSpace];
        if ((srcFileSize > spaceSize)) {
            [fscController closeFile:read_intHandle];
            NSString *str = @"Available Space is't enough!";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"]
                                                            message:str
                                                           delegate:self
                                                  cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"]
                                                  otherButtonTitles:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
            return;
        }
        
        //[Is destination file exist]
        int write_intHandle = 1;
        write_intHandle = [fscController openFileAbsolutePath:nssDestFileName openMode:OF_READ];
        if(write_intHandle == 0){
            [fscController closeFile:write_intHandle];
            NSString *str = @"Destination file is exist!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
            return;
        }
        
        //[Create file]
        //read_intHandle 1:Read file success
        //               0:File create success
        //              -1:File create failed
        read_intHandle = 1;
        read_intHandle = [fscController openFileAbsolutePath:nssDestFileName
                                                    openMode:OF_CREATE];
        if(read_intHandle == -1){
            return;
        }

        NSData *nsdDataBuf;
        uint32_t uintDataCount = 0;
        uint64_t uintDataOffset = 0;
        uint64_t uintDataSize,uintDataTranLen = 0;
        uintDataSize = [self returnFileSize:nssSrcFileName];
        _uintFileSize = uintDataSize;
        
//        str = [NSString stringWithFormat:@"uintDataTranLen %llu",uintDataSize];
//        alert = [[UIAlertView alloc] initWithTitle:@"Message"
//                                                        message:str
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [alert show];
//        });
        
        while((uintDataCount != -1) && (uintDataSize != 0)){
            @autoreleasepool{
                uintDataTranLen = ((uintDataSize > MAX_APIDATA_SIZE) ? MAX_APIDATA_SIZE : uintDataSize);
                nsdDataBuf = [self readFileHandle:nsfhFile
                                      readDataLen:(uint32_t)uintDataTranLen];
                [nsdDataBuf getBytes:byDataBuf];
                NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                uintDataCount = [fscController writeFile:read_intHandle writeBuf:aData writeSize:(uint32_t)uintDataTranLen];
                uintDataOffset += uintDataCount;
                uintDataSize -= uintDataCount;
                _uintTranSize += uintDataCount;
            }
        }
        
        [nsfhFile closeFile];
        intHandle = [fscController closeFile:intHandle];
    });
}
//end

- (void)doWriteFileOTGtoOTG:(NSString *)nssSrcPath fileName:(NSString *)nssDestPath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //        //Ray 20150930
        //        //For debug
        //        NSString *str2 = [NSString stringWithFormat:@"nssDestPathTmp(%@)", nssDestPathTmp];
        //        UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:@"Message" message:str2 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [alert2 show];
        //        });
        
        //[Is source file exist]
        int read_intHandle = 1;
        read_intHandle = [fscController openFileAbsolutePath:nssSrcPath openMode:OF_READ];
        if(read_intHandle != 0){
            [fscController closeFile:read_intHandle];
            NSString *str = @"Source file is't exist!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
            return;
        }
        
        //Ray for Ver.1.0.3
        //To add for available memory space
        //start
        uint64_t FATblockSize;
        if ([fscController getFATType] == EXFAT) {
            FATblockSize = 32768; //exFAT defult:32K
        }
        else{ //FAT32
            FATblockSize = 8192; //FAT32 defult:8K
        }
        uint64_t srcFileSize = [fscController getFileSize:read_intHandle];
        uint64_t spaceSize = [fscController getAvailableSpace];
        if ((srcFileSize > spaceSize)) {
            [fscController closeFile:read_intHandle];
            NSString *str = @"Available Space is't enough!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"FileSystemAPI_msg" alter:@"System Message"] message:str delegate:self cancelButtonTitle:[Language get:@"FileSystemAPI_OK" alter:@"OK"] otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
            return;
        }
        
        //For debug
        //        NSString *str2 = [NSString stringWithFormat:@"FATblockSize(%lld), srcFileSize(%lld), spaceSize(%lld)", FATblockSize, srcFileSize, spaceSize];
        //        UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:@"Message" message:str2 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [alert2 show];
        //        });
        //end
        
        [fscController closeFile:read_intHandle];
        
        //[Is destination file exist]
        NSString *nssDestPathTmp = nssDestPath;
        int write_intHandle = 1;
        write_intHandle = [fscController openFileAbsolutePath:nssDestPath openMode:OF_READ];
        if(write_intHandle == 0){
            [fscController closeFile:write_intHandle];
            NSString *nssSeparatedTmp;
            NSArray *array = [nssDestPath componentsSeparatedByString:@"."];
            NSString *strFileExtension = [NSString stringWithFormat:@".%@", array[array.count - 1]];
            NSArray *array1 = [nssDestPath componentsSeparatedByString:strFileExtension];
            nssSeparatedTmp = array1[0];
            for (uint8_t i = 1; i <= COPY_THE_SAME_FILE_MAX; i++) {
                nssDestPathTmp = [nssSeparatedTmp stringByAppendingString:[NSString stringWithFormat:@"(%d)%@", i ,strFileExtension]];
                write_intHandle = 0;
                write_intHandle = [fscController openFileAbsolutePath:nssDestPathTmp openMode:OF_READ];
                if(write_intHandle != 0)
                    i = COPY_THE_SAME_FILE_MAX + 1;
                [fscController closeFile:write_intHandle];
            }
        }
        else
            [fscController closeFile:write_intHandle];
        read_intHandle = 1;
        read_intHandle = [fscController openFileAbsolutePath:nssSrcPath openMode:OF_READ];
        write_intHandle = 1;
        write_intHandle = [fscController openFileAbsolutePath:nssDestPathTmp openMode:OF_CREATE];
        
        if ((read_intHandle != -1)&&(write_intHandle == 1))
        {
            uint64_t dataLength = 0;
            uint64_t uintDataSize = 0;
            uint64_t uintDataTranLen = 0;
            uintDataSize = [fscController getFileSize:read_intHandle];
            
            
            @synchronized(self){
                while((dataLength != -1) && (uintDataSize != 0))
                {
                    @autoreleasepool {
                        uintDataTranLen = ((uintDataSize > MAX_DATABUFFER) ? MAX_DATABUFFER : uintDataSize);
                        NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                        dataLength = [fscController readFile:read_intHandle readBuf:aData readSize:(uint32_t)uintDataTranLen];
                        if ((dataLength!=0)&&(dataLength!=-1)) {
                            aData = [NSData dataWithBytes:[aData bytes] length:(uint32_t)dataLength];
                            [fscController writeFile:write_intHandle writeBuf:aData writeSize:(uint32_t)dataLength];
                        }
                        uintDataSize -= dataLength;
                    }
                }
                read_intHandle = [fscController closeFile:read_intHandle];
                write_intHandle = [fscController closeFile:write_intHandle];
            }
        }
    });
    
}

//================================================================================
//Check the external accessory support the AES encryption or not
-(void)loadAESType
{
    self.AESEnable = [fscController isAESEnabled];
    if (self.AESEnable==YES)
    {
        [delegateForAPI checkAESComplete];
    }
    else
    {
        return;
    }
}

//================================================================================
- (void)dealloc
{
    _fsAPIDelegate = nil;
}

//================================================================================
- (void)debugMessageDump:(uint8_t *)buffer bumpLength:(uint32_t)length
{
    if([_fsAPIDelegate respondsToSelector:@selector(textViewMSG_ActionBuffer:bumpLength:)]){
        [_fsAPIDelegate textViewMSG_ActionBuffer:buffer bumpLength:length];
    } else{
        // Noting...
    }
}

//================================================================================
- (void)debugMessageShow:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    va_list ap;
    va_start(ap,format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    if([_fsAPIDelegate respondsToSelector:@selector(textViewMSG_Action:)]){
        [_fsAPIDelegate textViewMSG_Action:string];
    } else{
        // Noting...
    }
}

//================================================================================
//Return the file size (bytes)
- (uint64_t)returnFileSize:(NSString *)filePath
{
    uint64_t uintFileSize = 0;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil]){
        NSDictionary* nsdFile = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        uintFileSize = [nsdFile fileSize];
    }
    return uintFileSize;
}

//================================================================================
- (NSFileHandle *)makeFileOpenPath:(NSString *)filePath
{
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil]){
        // Nothing...
    } else{
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSFileHandle *nsfhFile;
    nsfhFile = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    
    [nsfhFile seekToFileOffset:[nsfhFile seekToEndOfFile]];
    
    return nsfhFile;
}

//================================================================================
- (void)makeFileHandle:(NSFileHandle *)nsfhFile writeData:(NSData *)fileData
{
    [nsfhFile writeData:fileData];
}

//================================================================================
- (NSFileHandle *)readFileOpenPath:(NSString *)filePath
{
    NSFileHandle *nsfhFile;
    nsfhFile = [NSFileHandle fileHandleForReadingAtPath:filePath];
    
    return nsfhFile;
}

//================================================================================
- (NSData *)readFileHandle:(NSFileHandle *)nsfhFile readDataLen:(uint32_t)fileDataLen
{
    return [nsfhFile readDataOfLength:fileDataLen];
}

//================================================================================
// initial file system
- (void)doInitialFileSystem
{
    if (!isFileSystemInitial)
    {
        if([fscController initFileSystem] == NO){
            [self debugMessageShow:@"--- : Initial FileSystem FAIL"];
            isFileSystemInitial = NO;
        } else{
            [self debugMessageShow:@"--- : Initial FileSystem SUCCESS"];
            isFileSystemInitial = YES;
        }
    }
    else
    {
        return;
    }
    
}

//================================================================================
//Change the current directory to the nssPathName directory
- (void)doChangeDirectory:(NSString *)nssPathName
{
    intHandle = 0;
    
    if(nssPathName == nil){
        [self debugMessageShow:@"--- : Change Dir IGNORE"];
        
    } else{
        intHandle = [fscController changeDirectory:nssPathName];
        if(intHandle != -1){ [self debugMessageShow:@"--- : Change Dir SUCCESS"];
        } else{              [self debugMessageShow:@"--- : Change Dir FAIL(%@)", nssPathName];}
    }
}

//================================================================================
//Browse files that in the current directory.
- (void)doBrowsFile
{
    FFBLK ffblk;
    EXFAT_FFBLK exfatFFBLK;
    int intIndex = 0;
    NSString *tmpStr = EMPTY_STRING;
    
    if ([fscController getFATType] == EXFAT) {
        if([fscController findFirstEXFAT:tmpStr findFirstStruct:&exfatFFBLK findFirstExact:NO] == 0){
            [self debugMessageShow:@"--- : Not Found..."];
            
        } else{
            intIndex++;
            if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                //This is a folder
                [self debugMessageShow:@"--- : 1.(%03d)(D) %@", intIndex, [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length]];
            } else{
                //This is a file
                [self debugMessageShow:@"--- : 1.(%03d)(F) %@", intIndex, [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length]];
            }
            
            while([fscController findNextEXFAT:&exfatFFBLK]){
                intIndex++;
                if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                    //This is a folder
                    [self debugMessageShow:@"--- : 1.(%03d)(D) %@", intIndex, [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length]];
                } else{
                    //This is a file
                    [self debugMessageShow:@"--- : 1.(%03d)(F) %@", intIndex, [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length]];
                }
            }
        }
    } else {
        if([fscController findFirst:[fscController str2DataWithASCII:tmpStr] findFirstStruct:&ffblk findFirstExact:NO] == 0){
            [self debugMessageShow:@"--- : Not Found..."];
        } else{
            if(ffblk.bAttributes != FA_LONGFILENAME){
                if([[fscController longFileName] isEqualToString:EMPTY_STRING]){
                    //nssFileName is short file name
                    tmpStr = [[NSString alloc] initWithBytes:ffblk.sFileName length:[fscController findStringEnd:ffblk.sFileName length:sizeof(ffblk.sFileName)] encoding:NSASCIIStringEncoding];
                } else{
                    //nssFileName is long file name
                    tmpStr = [fscController longFileName];
                }
                intIndex++;
                
                if((ffblk.bAttributes & FA_DIREC) != 0){
                    //This is a folder
                    [self debugMessageShow:@"--- : 1.(%03d)(D) %@", intIndex, tmpStr];
                } else{
                    //This is a file
                    [self debugMessageShow:@"--- : 1.(%03d)(F) %@", intIndex, tmpStr];
                }
            }
            
            while(1){
                if([fscController findNext:&ffblk] == 0){ break;}
                
                if(ffblk.bAttributes != FA_LONGFILENAME){
                    if([[fscController longFileName] isEqualToString:EMPTY_STRING]){
                        //nssFileName is short file name
                        tmpStr = [[NSString alloc] initWithBytes:ffblk.sFileName length:[fscController findStringEnd:ffblk.sFileName length:sizeof(ffblk.sFileName)] encoding:NSASCIIStringEncoding];
                    } else{
                        if([fscController longFileNameIndex] != 0){ continue;}
                        //nssFileName is long file name
                        tmpStr = [fscController longFileName];
                    }
                    intIndex++;
                    
                    if((ffblk.bAttributes & FA_DIREC) != 0){
                        //This is a folder
                        [self debugMessageShow:@"--- : 2.(%03d)(D) %@", intIndex, tmpStr];
                    } else{
                        //This is a file
                        [self debugMessageShow:@"--- : 2.(%03d)(F) %@", intIndex, tmpStr];
                    }
                }
            }
        }
    }
}

- (void)doBrowsFolder
{
    FFBLK ffblk;
    EXFAT_FFBLK exfatFFBLK;
    int intIndex = 0;
    NSString *tmpStr = EMPTY_STRING;
    
    if ([fscController getFATType] == EXFAT) {
        if([fscController findFirstEXFAT:tmpStr findFirstStruct:&exfatFFBLK findFirstExact:NO] == 0){
            [self debugMessageShow:@"--- : Not Found..."];
            
        } else{
            intIndex++;
            if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                //This is a folder
                [self debugMessageShow:@"--- : 1.(%03d)(D) %@", intIndex, [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length]];
            } else{
                //This is a file
                [self debugMessageShow:@"--- : 1.(%03d)(F) %@", intIndex, [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length]];
            }
            
            while([fscController findNextEXFAT:&exfatFFBLK]){
                intIndex++;
                if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                    //This is a folder
                    [self debugMessageShow:@"--- : 1.(%03d)(D) %@", intIndex, [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length]];
                } else{
                    //This is a file
                    [self debugMessageShow:@"--- : 1.(%03d)(F) %@", intIndex, [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length]];
                }
            }
        }
    } else {
        if([fscController findFirst:[fscController str2DataWithASCII:tmpStr] findFirstStruct:&ffblk findFirstExact:NO] == 0){
            [self debugMessageShow:@"--- : Not Found..."];
        } else{
            if(ffblk.bAttributes != FA_LONGFILENAME){
                if([[fscController longFileName] isEqualToString:EMPTY_STRING]){
                    //nssFileName is short file name
                    tmpStr = [[NSString alloc] initWithBytes:ffblk.sFileName length:[fscController findStringEnd:ffblk.sFileName length:sizeof(ffblk.sFileName)] encoding:NSASCIIStringEncoding];
                } else{
                    //nssFileName is long file name
                    tmpStr = [fscController longFileName];
                }
                intIndex++;
                
                if((ffblk.bAttributes & FA_DIREC) != 0){
                    //This is a folder
                    [self debugMessageShow:@"--- : 1.(%03d)(D) %@", intIndex, tmpStr];
                } else{
                    //This is a file
                    [self debugMessageShow:@"--- : 1.(%03d)(F) %@", intIndex, tmpStr];
                }
            }
            
            while(1){
                if([fscController findNext:&ffblk] == 0){ break;}
                
                if(ffblk.bAttributes != FA_LONGFILENAME){
                    if([[fscController longFileName] isEqualToString:EMPTY_STRING]){
                        //nssFileName is short file name
                        tmpStr = [[NSString alloc] initWithBytes:ffblk.sFileName length:[fscController findStringEnd:ffblk.sFileName length:sizeof(ffblk.sFileName)] encoding:NSASCIIStringEncoding];
                    } else{
                        if([fscController longFileNameIndex] != 0){ continue;}
                        //nssFileName is long file name
                        tmpStr = [fscController longFileName];
                    }
                    intIndex++;
                    
                    if((ffblk.bAttributes & FA_DIREC) != 0){
                        //This is a folder
                        [self debugMessageShow:@"--- : 2.(%03d)(D) %@", intIndex, tmpStr];
                    } else{
                        //This is a file
                        [self debugMessageShow:@"--- : 2.(%03d)(F) %@", intIndex, tmpStr];
                    }
                }
            }
        }
    }
}

//================================================================================
//Delete the file that in the current directory.
- (void)doDeleteFile_Directory:(NSString *)nssFileName
{
    intHandle = 0;
    if(nssFileName == nil){
        [self debugMessageShow:@"--- : Delete File IGNORE"];
    } else{
        intHandle = [fscController deleteFile:nssFileName];
        if(intHandle != -1){
            [fscController packDirectory];
            [self debugMessageShow:@"--- : Delete File(SFN.JPG) SUCCESS(%@)", nssFileName];
        } else{
            [self debugMessageShow:@"--- : Delete File FAIL(%@)", nssFileName];
        }
    }
}

//================================================================================
//Read the file that in the current directory.
- (void)doReadFile:(NSString *)nssFileName
{
    intHandle = 0;
    
    if(nssFileName == nil){
        [self debugMessageShow:@"--- : Open File IGNORE"]; return;
    }
    
    intHandle = [fscController openFile:nssFileName openMode:OF_READ];
    [self debugMessageShow:@"nssFileName(%@)", nssFileName];
    [self debugMessageShow:@"intHandle(%d)", intHandle];
    if(intHandle != -1){
        [self debugMessageShow:@"--- : Open File(SFN.JPG) SUCCESS(%@)", nssFileName];
    }
    else{
        [self debugMessageShow:@"--- : Open File FAIL(%@)", nssFileName];
    }
    
    NSString *nssPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    //==== Delete Dircetory ======================================================
    [[NSFileManager defaultManager] removeItemAtPath:nssPath error:nil];
    //==== Create Dircetory ======================================================
    [[NSFileManager defaultManager] createDirectoryAtPath:nssPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    uint32_t uintDataCount = 0;
    NSString *nssFilePath = [nssPath stringByAppendingPathComponent:nssFileName];
    
    NSFileHandle *nsfhFile = [self makeFileOpenPath:nssFilePath];
    do{
        NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
        uintDataCount = [fscController readFile:intHandle readBuf:aData readSize:MAX_APIDATA_SIZE];
        if((uintDataCount != -1) && (uintDataCount != 0)){
            aData = [NSData dataWithBytes:[aData bytes] length:uintDataCount];
            
            //write the data to the application tmp directory
            [self makeFileHandle:nsfhFile writeData:aData];
        }else{
            break;
        }
    } while((uintDataCount != -1) && (uintDataCount != 0));
    
    //Neil
    [self debugMessageShow:@"DO_READ_FILE:%@",nssFilePath];
    
    if(uintDataCount == 0){ [self debugMessageShow:@"--- : Read File SUCCESS"];
    } else{                 [self debugMessageShow:@"--- : Read File FAIL"];}
    [nsfhFile closeFile];
    intHandle = [fscController closeFile:intHandle];
    if(intHandle != -1){ [self debugMessageShow:@"--- : Close File SUCCESS"];
    } else{              [self debugMessageShow:@"--- : Close File FAIL"];}
}

//================================================================================
//Write the file to current directory
- (void)doWriteFile:(NSString *)nssFileName
{
    
    intHandle = 0;
    
    if(nssFileName == nil){ [self debugMessageShow:@"--- : Open File IGNORE"]; return;}
    
    intHandle = [fscController openFile:nssFileName openMode:OF_READ];
    if(intHandle != -1){ [self debugMessageShow:@"--- : File EXIST:(%@)", nssFileName];
        [fscController closeFile:intHandle];
        return;
    }
    
    intHandle = [fscController openFile:nssFileName openMode:OF_CREATE];
    if(intHandle == -1){ [self debugMessageShow:@"--- : Open File FAIL(%@)", nssFileName]; return;
    } else{              [self debugMessageShow:@"--- : Open File(LFN) SUCCESS(%@)", nssFileName];}
    
    NSString *nssPath;
    nssPath = [[NSBundle mainBundle] pathForResource:nssFileName ofType:nil];
    
    NSData *nsdDataBuf;
    uint32_t uintDataCount = 0;
    uint64_t uintDataSize = 0, uintDataOffset = 0;
    NSString *nssFilePath = nssPath;
    uint64_t uintDataTranLen = 0;
    uintDataSize = [self returnFileSize:nssFilePath];
    _uintFileSize = uintDataSize;
    
    NSFileHandle *nsfhFile = [self readFileOpenPath:nssFilePath];
    
    while((uintDataCount != -1) && (uintDataSize != 0)){
        @autoreleasepool{
            uintDataTranLen = ((uintDataSize > MAX_APIDATA_SIZE) ? MAX_APIDATA_SIZE : uintDataSize);
            nsdDataBuf = [self readFileHandle:nsfhFile readDataLen:(uint32_t)uintDataTranLen];
            [nsdDataBuf getBytes:byDataBuf];
            NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
            uintDataCount = [fscController writeFile:intHandle writeBuf:aData writeSize:(uint32_t)uintDataTranLen];
            
            uintDataOffset += uintDataCount;
            uintDataSize -= uintDataCount;
            _uintTranSize += uintDataCount;
        }
    }
    
    if((uintDataCount == 0) || (uintDataSize == 0)){ [self debugMessageShow:@"--- : Write File SUCCESS"];
    } else{                                          [self debugMessageShow:@"--- : Write File FAIL"];}
    
    [nsfhFile closeFile];
    intHandle = [fscController closeFile:intHandle];
    if(intHandle != -1){ [self debugMessageShow:@"--- : Close File SUCCESS"];
    } else{              [self debugMessageShow:@"--- : Close File FAIL"];}
}

//================================================================================
//Seek the file process
- (void)doSeekFile
{
    NSString *nssFileName = @"SeekFileTest.txt";
    intHandle = 0;
    
    //===== File pattern =========================================================
    intHandle = [fscController openFile:nssFileName openMode:OF_READ];
    if(intHandle != -1){ [self debugMessageShow:@"--- : File EXIST(LFN)(%@)", nssFileName]; [fscController closeFile:intHandle]; return;}
    
    intHandle = [fscController openFile:nssFileName openMode:OF_CREATE];
    if(intHandle == -1){ [self debugMessageShow:@"--- : Open File FAIL(%@)", nssFileName]; return;
    } else{              [self debugMessageShow:@"--- : Open File(LFN) SUCCESS(%@)", nssFileName];}
    
#define SECTORSIZE  512
    NSData *nsdDataBuf;
    uint32_t uintDataCount = 0;
    uint64_t uintDataSize = (SECTORSIZE * 4);
    uint64_t uintDataTranLen = 0;
    int intCount = 0;
    
    while((uintDataCount != -1) && (uintDataSize != 0)){
        @autoreleasepool{
            uintDataTranLen = ((uintDataSize > SECTORSIZE) ? SECTORSIZE : uintDataSize);
            [nsdDataBuf getBytes:byDataBuf];
            memset(byDataBuf, (0x41 + intCount), SECTORSIZE);
            NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
            uintDataCount = [fscController writeFile:intHandle writeBuf:aData writeSize:(uint32_t)uintDataTranLen];
            
            intCount++;
            uintDataSize -= uintDataCount;
            _uintTranSize += uintDataCount;
        }
    }
    
    if((uintDataCount == 0) || (uintDataSize == 0)){ [self debugMessageShow:@"--- : Write File SUCCESS"];
    } else{                                          [self debugMessageShow:@"--- : Write File FAIL"];}
    
    intHandle = [fscController closeFile:intHandle];
    if(intHandle != -1){ [self debugMessageShow:@"--- : Close File SUCCESS"];
    } else{              [self debugMessageShow:@"--- : Close File FAIL"];}
    
    //==== Seek file and flush data ==============================================
    intHandle = [fscController openFile:nssFileName openMode:OF_WRITE];
    if(intHandle != -1){ [self debugMessageShow:@"--- : Open File(LFN) SUCCESS(%@)", nssFileName];
    } else{              [self debugMessageShow:@"--- : Open File FAIL(%@)", nssFileName];}
    
    uintDataSize = (SECTORSIZE * 2);
    
    while((uintDataCount != -1) && (uintDataSize != 0)){
        @autoreleasepool{
            uintDataTranLen = ((uintDataSize > SECTORSIZE) ? SECTORSIZE : uintDataSize);
            [nsdDataBuf getBytes:byDataBuf];
            memset(byDataBuf, (0x61 + intCount), SECTORSIZE);
            NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
            uintDataCount = [fscController writeFile:intHandle writeBuf:aData writeSize:(uint32_t)uintDataTranLen];
            [fscController flushData:intHandle];
            
            [fscController seekFile:intHandle seekPosition:0];
            
            BYTE byTempBuf[SECTORSIZE];
            NSData *bData = [NSData dataWithBytes:byTempBuf length:sizeof(byTempBuf)];
            [fscController readFile:intHandle readBuf:bData readSize:SECTORSIZE];
            [self debugMessageDump:byDataBuf bumpLength:SECTORSIZE];
            
            [fscController seekFile:intHandle seekPosition:0];
            
            intCount++;
            uintDataSize -= uintDataCount;
            _uintTranSize += uintDataCount;
        }
    }
    
    intHandle = [fscController closeFile:intHandle];
    if(intHandle != -1){ [self debugMessageShow:@"--- : Close File SUCCESS"];
    } else{              [self debugMessageShow:@"--- : Close File FAIL"];}
}

//================================================================================
//Encrypt the file
- (void)doAESEncryptFile:(NSString *)nssFileName
{
    if(nssFileName == nil){ [self debugMessageShow:@"--- : Encrypt File IGNORE"]; return;}
    
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    BOOL haveFile = [[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:nssFileName]];
    BOOL haveFileS = [[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:[nssFileName stringByAppendingPathExtension:@"secpro"]]];
    
    if (haveFileS)
    {
        [self debugMessageShow:@"--- : Already have the same name file (secpro)"];
        [[NSFileManager defaultManager] removeItemAtPath:[docPath stringByAppendingPathComponent:[nssFileName stringByAppendingPathExtension:@"secpro"]] error:nil];
    }
    if (haveFile)
    {
        [self debugMessageShow:@"--- : Already have the same name file (JPG)"];
        [[NSFileManager defaultManager] removeItemAtPath:[docPath stringByAppendingPathComponent:nssFileName] error:nil];
    }
    
    [self debugMessageShow:@"--- : Now encrypt File"];
    
    BOOL isEncrypt = YES;
    int srcHandle, desHandle;
    NSString *filePath;
    uint32_t dataLenRead = 0;
    uint32_t fileTotalSize = 0;
    filePath = [[NSBundle mainBundle] pathForResource:nssFileName ofType:nil];
    srcHandle = open([filePath UTF8String], O_RDONLY);
    fileTotalSize = (uint32_t)[self returnFileSize:filePath];
    filePath = [docPath stringByAppendingPathComponent:[nssFileName stringByAppendingPathExtension:@"secpro"]];
    desHandle = creat([filePath UTF8String], S_IREAD | S_IWRITE);
    
    //Create the AES file tag
    memcpy(byDataBuf, [[self addAESPaddingDataWithFileSize:fileTotalSize] bytes], MAX_SECTORSIZE);
    
    //Sent the encryption password, isEncrypt: YES = encrypt  , NO = decrypt
    [fscController initAESwithPassword:@"password" withType:isEncrypt];
    
    //First sent the AES file tag by 512 bytes
    [fscController sendAESData:byDataBuf withLen:MAX_SECTORSIZE];
    
    write(desHandle, byDataBuf, MAX_SECTORSIZE);
    
    do {
        dataLenRead = read(srcHandle, byDataBuf, sizeof(byDataBuf));
        if(dataLenRead % MAX_SECTORSIZE)
            dataLenRead += MAX_SECTORSIZE - (dataLenRead % MAX_SECTORSIZE);
        [fscController sendAESData:byDataBuf withLen:dataLenRead];
        write(desHandle, byDataBuf, dataLenRead);
    } while (dataLenRead);
    
    //Disable the AES encrypt function
    [fscController setAESDisable];
    close(srcHandle);
    close(desHandle);
    [self debugMessageShow:@"--- : Encrypt File complete"];
    [self debugMessageShow:@"--- : The File in the application Documents, please check it by iTunes or iTools"];
}

//================================================================================
//Add the AES file tag
- (NSData *)addAESPaddingDataWithFileSize:(uint32_t)aFileTotalSize
{
    NSMutableData *tagData;
    uint32_t paddingLen = 0;
    NSData *paddingData;
    void *paddingBytes;
    
    uint32_t newFileTotalSize;
    ((uint8_t *)&newFileTotalSize)[0] = ((uint8_t *)&aFileTotalSize)[3];
    ((uint8_t *)&newFileTotalSize)[1] = ((uint8_t *)&aFileTotalSize)[2];
    ((uint8_t *)&newFileTotalSize)[2] = ((uint8_t *)&aFileTotalSize)[1];
    ((uint8_t *)&newFileTotalSize)[3] = ((uint8_t *)&aFileTotalSize)[0];
    
    tagData = [[NSMutableData alloc] initWithData:[AESFILETAG dataUsingEncoding:NSUTF8StringEncoding]];
    [tagData appendData:[[NSData alloc] initWithBytes:&newFileTotalSize length:sizeof(newFileTotalSize)]];
    
    paddingLen = MAX_SECTORSIZE - [AESFILETAG length] - sizeof(newFileTotalSize);
    paddingBytes = malloc(paddingLen);
    arc4random_buf(paddingBytes, paddingLen);
    paddingData = [NSData dataWithBytes:paddingBytes length:paddingLen];
    [tagData appendData:paddingData];
    free(paddingBytes);
    
    return tagData;
}

//================================================================================
//Decrypt the file
- (void)doAESDecryptFile:(NSString *)nssFileName
{
    BOOL isEncrypt = NO;
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    BOOL haveFile = [[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:nssFileName]];
    BOOL haveFileS = [[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:[nssFileName stringByAppendingPathExtension:@"secpro"]]];
    
    if (!haveFileS)
    {
        [self debugMessageShow:@"--- : Decrypt error!  No file can decrypt!"];
        return;
    }
    
    if (haveFile)
    {
        [self debugMessageShow:@"--- : Already have the same name file (JPG)"];
        [[NSFileManager defaultManager] removeItemAtPath:[docPath stringByAppendingPathComponent:nssFileName] error:nil];
    }
    
    [self debugMessageShow:@"--- : Now decrypt File"];
    int srcHandle, desHandle;
    NSString *filePath;
    uint32_t dataLenRead = 0;
    uint32_t fileTotalSize = 0;
    filePath = [docPath stringByAppendingPathComponent:[nssFileName stringByAppendingPathExtension:@"secpro"]];
    srcHandle = open([filePath UTF8String], O_RDONLY);
    
    //Sent the decryption password, isEncrypt: YES = encrypt  , NO = decrypt
    [fscController initAESwithPassword:@"password" withType:isEncrypt];
    read(srcHandle, byDataBuf, MAX_SECTORSIZE);
    [fscController sendAESData:byDataBuf withLen:MAX_SECTORSIZE];
    filePath = [[NSString alloc] initWithBytes:byDataBuf length:[AESFILETAG length] encoding:NSUTF8StringEncoding];
    
    //Determine whether the correct password
    if([filePath isEqualToString:AESFILETAG] == NO){
        [fscController setAESDisable];
        close(srcHandle);
        return;
    }
    
    ((uint8_t *)&fileTotalSize)[0] = byDataBuf[[AESFILETAG length] + 3];
    ((uint8_t *)&fileTotalSize)[1] = byDataBuf[[AESFILETAG length] + 2];
    ((uint8_t *)&fileTotalSize)[2] = byDataBuf[[AESFILETAG length] + 1];
    ((uint8_t *)&fileTotalSize)[3] = byDataBuf[[AESFILETAG length] + 0];
    
    
    filePath = [docPath stringByAppendingPathComponent:nssFileName];
    desHandle = creat([filePath UTF8String], S_IREAD | S_IWRITE);
    do {
        dataLenRead = read(srcHandle, byDataBuf, sizeof(byDataBuf));
        [fscController sendAESData:byDataBuf withLen:dataLenRead];
        if(dataLenRead >= fileTotalSize)
            dataLenRead = fileTotalSize;
        write(desHandle, byDataBuf, dataLenRead);
        fileTotalSize -= dataLenRead;
    } while (dataLenRead);
    //Disable the AES decrypt function
    [fscController setAESDisable];
    close(srcHandle);
    close(desHandle);
    
    [[NSFileManager defaultManager] removeItemAtPath:[docPath stringByAppendingPathComponent:[nssFileName stringByAppendingPathExtension:@"secpro"]] error:nil];
    [self debugMessageShow:@"--- : Decrypt File complete"];
    [self debugMessageShow:@"--- : The File in the application Documents, please check it by iTunes or iTools"];
}

//================================================================================
//Get the total available space in iFDisk
//-(void)totalAvailableSpace
//{
//    uint64_t totalCapacity = [fscController getTotalAvailableSpace];
//    NSString *formatString = [NSString stringWithFormat:@"--- : Storage Capacity: (%llu) bytes", totalCapacity];
//    [self debugMessageShow:@"%@",formatString];
//}

-(uint64_t)totalAvailableSpace
{
    uint64_t totalCapacity = [fscController getTotalAvailableSpace];
    
    return totalCapacity;
}

//-(void)totalAvailableSpace
//{
//    uint64_t totalCapacity = [fscController getTotalAvailableSpace];
//    NSString *formatString = [NSString stringWithFormat:@"--- : Storage Capacity: (%llu) bytes", totalCapacity];
//    [self debugMessageShow:@"%@",formatString];
//}

//================================================================================
//Format the iFDisk
- (void)quickFormat
{
    processEnd = NO;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        formatAlert = [[UIAlertView alloc] initWithTitle:@"Do Format"
                                                 message:@"Formating..."
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:nil];
        formatAlert.alertViewStyle = UIAlertViewStyleDefault;
        [formatAlert show];
        
        formatProcess = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(formatProcess) userInfo:nil repeats:YES];
    });
    
    [fscController quickFormat];
    processEnd = YES;
}

//================================================================================
//Display the process of format
-(void)formatProcess
{
    if (processEnd)
    {
        [formatAlert setMessage:[NSString stringWithFormat:@"--- : The Format Process: ( %1.0f %%)", 100*(((float)fscController.formatProcess)/((float)fscController.formatTotal))]];
        [formatAlert dismissWithClickedButtonIndex:0 animated:YES];
        if(formatProcess!=nil)
        {
            [formatProcess invalidate];
        }
        [self debugMessageShow:@"--- : Format complete!!!"];
    }
    else
    {
        [formatAlert setMessage:[NSString stringWithFormat:@"--- : The Format Process: ( %1.0f %%)", 100*(((float)fscController.formatProcess)/((float)fscController.formatTotal))]];
    }
    
}
//================================================================================
// Get the available space in iFDisk
//-(void)getAvailableSpace
//{
//    uint64_t spaceSize = [fscController getAvailableSpace];
//    NSString *formatString = [NSString stringWithFormat:@"--- Available Space: (%llu) bytes", spaceSize];
//    [self debugMessageShow:@"%@",formatString];
//    
//    return
//}

-(uint64_t)getAvailableSpace
{
    uint64_t spaceSize = [fscController getAvailableSpace];
//    NSString *formatString = [NSString stringWithFormat:@"--- Available Space: (%llu) bytes", spaceSize];
//    [self debugMessageShow:@"%@",formatString];
    
    return spaceSize;
}

//-(uint64_t)getAvailableSpace
//{
//    uint64_t spaceSize = [fscController getAvailableSpace];
//    
//    return spaceSize;
//}

//================================================================================
//Create the folder in the current directory
-(void)createFolder
{
    if([fscController searchFile:@"iFDiskTest"])
    {
        [self debugMessageShow:@"Folder already exists!"];
    }
    else
    {
        [fscController createDirectory:@"iFDiskTest"];
        [self debugMessageShow:@"Create Folder complete"];
    }
}
//================================================================================
//Demo the multi select copy (iDevice copy to iFDisk)
-(void)INCopyToEX
{
    NSString *iFDiskTestFolder1 = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"iFDiskTestFolder1"];
    NSString *iFDiskTestFolder2 = [iFDiskTestFolder1 stringByAppendingPathComponent:@"iFDiskTestFolder2"];
    NSString *test0Path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test0.zip"];
    NSString *test1Path = [iFDiskTestFolder1 stringByAppendingPathComponent:@"test1.zip"];
    NSString *test2_1Path = [iFDiskTestFolder2 stringByAppendingPathComponent:@"test2_1.zip"];
    NSString *test2_2path = [iFDiskTestFolder2 stringByAppendingPathComponent:@"test2_2.zip"];
    
    NSString *test0 = [[NSBundle mainBundle] pathForResource:@"test0" ofType:@"zip"];
    NSString *test1 = [[NSBundle mainBundle] pathForResource:@"test1" ofType:@"zip"];
    NSString *test2_1 = [[NSBundle mainBundle] pathForResource:@"test2_1" ofType:@"zip"];
    NSString *test2_2 = [[NSBundle mainBundle] pathForResource:@"test2_2" ofType:@"zip"];
    
    //Create the test pattern in iDevice
    if(![[NSFileManager defaultManager] fileExistsAtPath:test0Path])
    {
        [[NSFileManager defaultManager] copyItemAtPath:test0 toPath:test0Path error:nil];
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:iFDiskTestFolder1])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:iFDiskTestFolder1 withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:iFDiskTestFolder2 withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:test1 toPath:test1Path error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:test2_1 toPath:test2_1Path error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:test2_2 toPath:test2_2path error:nil];
    }
    
    NSArray *internalMultiFile = [[NSArray alloc] initWithObjects:iFDiskTestFolder1,test0Path, nil];
    
    //Do the multi select copy (iDevice copy to iFDisk)
    [self internalCopyToExternal:internalMultiFile];
    [self debugMessageShow:@"--- : Internal Copy To External Complete"];
}
//================================================================================
//Copy file to current directory in the iFDisk
//The NSArray (internalMultiFile) is the group of file (or folder) path.
//The function support single select copy and multi select copy
-(void)internalCopyToExternal:(NSArray *)internalMultiFile
{
    int _copyCnt = 0;
    NSInteger iHandle = 0;
    
    while (_copyCnt < [internalMultiFile count])
    {
        BOOL isDir = [[NSFileManager defaultManager] fileExistsAtPath:internalMultiFile[_copyCnt] isDirectory:&isDir]&&isDir;
        
        if(isDir)
        {
            [self internalDirCopyToExternal:internalMultiFile[_copyCnt]];
        }
        else
        {
            BOOL fileExist;
            fileExist = [fscController searchFile:[internalMultiFile[_copyCnt] lastPathComponent]];
            if (fileExist)
            {
                [self debugMessageShow:@"--- : Already have the file in External"];
                
                //Already have the same name file, if want to replace file or other operation, can do it here.
                //Replace file example:
                
                /*
                 [fscController deleteFile:[internalMultiFile[_copyCnt] lastPathComponent]];
                 
                 NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:internalMultiFile[_copyCnt]];
                 iHandle = [fscController openFile:internalMultiFile[_copyCnt] openMode:OF_CREATE];
                 if (iHandle != -1)
                 {
                 uint32_t dataLength = 0;
                 uint32_t uintDataSize = 0;
                 uint32_t uintDataTranLen = 0;
                 uintDataSize = (uint32_t)[self returnFileSize:internalMultiFile[_copyCnt]];
                 @synchronized(self){
                 while((dataLength != -1) && (uintDataSize != 0))
                 {
                 @autoreleasepool {
                 uintDataTranLen = ((uintDataSize > MAX_DATABUFFER) ? MAX_DATABUFFER : uintDataSize);
                 [[fileHandle readDataOfLength:uintDataTranLen] getBytes:byDataBuf];
                 NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                 dataLength = [fscController writeFile:iHandle writeBuf:aData writeSize:uintDataTranLen];
                 uintDataSize -= dataLength;
                 }
                 }
                 [fscController closeFile:iHandle];
                 [fileHandle closeFile];
                 }
                 }
                 */
                
            }
            else
            {
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:internalMultiFile[_copyCnt]];
                iHandle = [fscController openFile:[internalMultiFile[_copyCnt] lastPathComponent]
                                         openMode:OF_CREATE];
                if (iHandle != -1)
                {
                    uint32_t dataLength = 0;
                    uint32_t uintDataSize = 0;
                    uint32_t uintDataTranLen = 0;
                    uintDataSize = (uint32_t)[self returnFileSize:internalMultiFile[_copyCnt]];
                    @synchronized(self){
                        while((dataLength != -1) && (uintDataSize != 0))
                        {
                            @autoreleasepool {
                                uintDataTranLen = ((uintDataSize > MAX_DATABUFFER) ? MAX_DATABUFFER : uintDataSize);
                                [[fileHandle readDataOfLength:uintDataTranLen] getBytes:byDataBuf];
                                NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                                dataLength = [fscController writeFile:iHandle writeBuf:aData writeSize:uintDataTranLen];
                                uintDataSize -= dataLength;
                            }
                        }
                        [fscController closeFile:iHandle];
                        [fileHandle closeFile];
                    }
                }
            }
            
        }
        _copyCnt++;
        
    }
}
//================================================================================
-(void)internalDirCopyToExternal:(NSString *)path
{
    BOOL fileExist;
    fileExist = [fscController searchFile:[path lastPathComponent]];
    if (fileExist)
    {
        [self debugMessageShow:@"--- : Already have the file in External"];
        //Already have the same name directory, if want to replace the directory or other operation, can do it here.
        //Replace directory example:
        /*
         [self dirDelete:[path lastPathComponent]];
         [self internalDirCopyToExternal:path];
         */
    }
    else
    {
        [fscController createDirectory:[path lastPathComponent]];
        [fscController changeDirectory:[path lastPathComponent]];
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:path];
        NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        NSUInteger cnt = 0;
        NSInteger iHandle = 0;
        for (cnt = 0; cnt < [fileList count]; cnt++) {
            BOOL isDir = [[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:fileList[cnt]] isDirectory:&isDir]&&isDir;
            if (isDir) {
                [self internalDirCopyToExternal:[path stringByAppendingPathComponent:fileList[cnt]]];
            }else{
                NSString *copyPath = [[NSString alloc] initWithString:[path stringByAppendingPathComponent:fileList[cnt]]];
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:copyPath];
                iHandle = [fscController openFile:fileList[cnt]
                                         openMode:OF_CREATE];
                
                if (iHandle != -1){
                    uint32_t dataLength = 0;
                    uint32_t uintDataSize = 0;
                    uint32_t uintDataTranLen = 0;
                    uintDataSize = (uint32_t)[self returnFileSize:copyPath];
                    
                    while((dataLength != -1) && (uintDataSize != 0))
                    {
                        @autoreleasepool {
                            uintDataTranLen = ((uintDataSize > MAX_DATABUFFER) ? MAX_DATABUFFER : uintDataSize);
                            [[fileHandle readDataOfLength:uintDataTranLen] getBytes:byDataBuf];
                            NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                            dataLength = [fscController writeFile:iHandle writeBuf:aData writeSize:uintDataTranLen];
                            uintDataSize -= dataLength;
                        }
                    }
                }
                [fscController closeFile:iHandle];
            }
        }
        [fscController changeDirectory:DOTDOT_STRING];
    }
}
//================================================================================
//Demo the multi select copy (iFDisk copy to iDevice)
-(void)EXCopyToIN
{
    NSString *iFDiskTestFolder = @"iFDiskTestFolder1";
    NSString *test0 = @"test0.zip";
    
    BOOL fileExist;
    fileExist = ([fscController searchFile:iFDiskTestFolder]&&[fscController searchFile:test0]);
    if (fileExist)
    {
        NSString *copyToDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *iFDiskTestFolder1 = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"iFDiskTestFolder1"];
        NSString *test0Path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test0.zip"];
        [[NSFileManager defaultManager] removeItemAtPath:iFDiskTestFolder1 error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:test0Path error:nil];
        
        NSArray *externalMultiFile = [[NSArray alloc] initWithObjects:test0,iFDiskTestFolder, nil];
        [self externalCopyToInternal:externalMultiFile copyToDirectory:copyToDirectory];
        [self debugMessageShow:@"--- : External Copy To internal Complete"];
    }
    else
    {
        [self debugMessageShow:@"--- : Please do this function after the Copy (iDevice to iFDisk)"];
    }
    
    
}
//================================================================================
//Copy file (in the current directory of iFDisk) to iDevice
//The NSArray (externalMultiFile) is the group of file (or folder) path.
//The NSString (directoryPath) is the directory path that want to Copy to.
//The function support single select copy and multi select copy
-(void)externalCopyToInternal:(NSArray *)externalMultiFile copyToDirectory:(NSString *)directoryPath
{
    @autoreleasepool {
        NSInteger iHandle = 0;
        int _copyCnt = 0;
        while (_copyCnt < [externalMultiFile count])
        {
            NSData *nameData = [externalMultiFile[_copyCnt] dataUsingEncoding:NSASCIIStringEncoding];
            FFBLK ffblk;
            ffblk.bAttributes = 0;
            EXFAT_FFBLK exfatFFBLK;
            exfatFFBLK.aFileEntry.attrib = 0;
            BOOL fileExist = NO;
            
            if ([fscController getFATType] == EXFAT) {
                fileExist = [fscController findFirstEXFAT:externalMultiFile[_copyCnt] findFirstStruct:&exfatFFBLK findFirstExact:YES];
            }else{
                if ([nameData length]==0) {
                    fileExist = [fscController findFirst:[fscController str2DataWithUTF16:externalMultiFile[_copyCnt]] findFirstStruct:&ffblk findFirstExact:YES];
                }else{
                    if ([fscController findFirst:[fscController str2DataWithUTF16:externalMultiFile[_copyCnt]] findFirstStruct:&ffblk findFirstExact:YES]) {
                        fileExist = YES;
                    }else if([fscController findFirst:[fscController str2DataWithASCII:externalMultiFile[_copyCnt]] findFirstStruct:&ffblk findFirstExact:YES]){
                        fileExist = YES;
                    }
                }
            }
            
            if (fileExist)
            {
                if ([fscController getFATType] == EXFAT) {
                    if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                        // this is folder
                        NSString *copyPath = [directoryPath stringByAppendingPathComponent:externalMultiFile[_copyCnt]];
                        [self externalDirCopyToInternal:copyPath];
                    } else{
                        //this is file
                        NSString *copyPath = [directoryPath stringByAppendingPathComponent:externalMultiFile[_copyCnt]];
                        [[NSFileManager defaultManager] createFileAtPath:copyPath contents:nil attributes:nil];
                        iHandle = [fscController openFile:externalMultiFile[_copyCnt]
                                                 openMode:OF_READ];
                        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:copyPath];
                        uint32_t dataLength;
                        if (iHandle != -1) {
                            do{
                                @autoreleasepool{
                                    NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                                    dataLength = [fscController readFile:iHandle readBuf:aData readSize:MAX_DATABUFFER];
                                    aData = [NSData dataWithBytes:[aData bytes] length:dataLength];
                                    [fileHandle writeData:aData];
                                }
                            } while((dataLength != -1) && (dataLength != 0));
                        }
                        [fscController closeFile:iHandle];
                        [fileHandle closeFile];
                    }
                }else{
                    if((ffblk.bAttributes & FA_DIREC) != 0){
                        // this is folder
                        NSString *copyPath = [directoryPath stringByAppendingPathComponent:externalMultiFile[_copyCnt]];
                        [self externalDirCopyToInternal:copyPath];
                        
                    } else {
                        //this is file
                        NSString *copyPath = [directoryPath stringByAppendingPathComponent:externalMultiFile[_copyCnt]];
                        [[NSFileManager defaultManager] createFileAtPath:copyPath contents:nil attributes:nil];
                        iHandle = [fscController openFile:externalMultiFile[_copyCnt]
                                                 openMode:OF_READ];
                        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:copyPath];
                        uint32_t dataLength;
                        if (iHandle != -1) {
                            do{
                                @autoreleasepool{
                                    NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                                    dataLength = [fscController readFile:iHandle readBuf:aData readSize:MAX_DATABUFFER];
                                    aData = [NSData dataWithBytes:[aData bytes] length:dataLength];
                                    [fileHandle writeData:aData];
                                }
                            } while((dataLength != -1) && (dataLength != 0));
                        }
                        [fscController closeFile:iHandle];
                        [fileHandle closeFile];
                    }
                }
            }
            
            _copyCnt++;
        }
        
    }
    
    
}
//================================================================================
-(void)externalDirCopyToInternal:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm changeCurrentDirectoryPath:path];
    [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    NSInteger iHandle = -1;
    iHandle = [fscController changeDirectory:[path lastPathComponent]];
    if(!iHandle){
        //change directory fail!!!
        return;
    }
    NSMutableArray *fileList = [[NSMutableArray alloc]init];
    NSMutableArray *isDirList = [[NSMutableArray alloc]init];
    FFBLK ffblk;
    EXFAT_FFBLK exfatFFBLK;
    NSString *tmpFileName;
    uint32_t cnt = 0;
    
    
    if ([fscController getFATType] == EXFAT) {
        if([fscController findFirstEXFAT:@"" findFirstStruct:&exfatFFBLK findFirstExact:NO] == 0){
            // Not found...
            fileList = nil;
            isDirList = nil;
        } else{
            if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                //This is a folder
                tmpFileName = [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length];
                [fileList addObject:tmpFileName];
                [isDirList addObject:@"isDir"];
                
            } else{
                //This is a file
                tmpFileName = [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length];
                [fileList addObject:tmpFileName];
                [isDirList addObject:@"notDir"];
            }
            
            while([fscController findNextEXFAT:&exfatFFBLK]){
                if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                    //This is a folder
                    tmpFileName = [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length];
                    [fileList addObject:tmpFileName];
                    [isDirList addObject:@"isDir"];
                } else{
                    //This is a file
                    tmpFileName = [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length];
                    [fileList addObject:tmpFileName];
                    [isDirList addObject:@"notDir"];
                }
            }
        }
    }else{
        if([fscController findFirst:[fscController str2DataWithASCII:@""] findFirstStruct:&ffblk findFirstExact:NO] == 0)
        {
            // Not found...
            fileList = nil;
            isDirList = nil;
        }
        else
        {
            BOOL isPoint = NO;
            if(ffblk.bAttributes != FA_LONGFILENAME){
                if([fscController.longFileName isEqualToString:@""]){
                    tmpFileName = [[NSString alloc] initWithBytes:ffblk.sFileName length:[fscController findStringEnd:ffblk.sFileName length:sizeof(ffblk.sFileName)] encoding:NSASCIIStringEncoding];
                    if ([tmpFileName isEqualToString:@"."] || [tmpFileName isEqualToString:@".."]) {
                        isPoint = YES;
                    }else {
                        isPoint = NO;
                    }
                } else{
                    tmpFileName = fscController.longFileName;
                    if ([tmpFileName isEqualToString:@"."] || [tmpFileName isEqualToString:@".."]) {
                        isPoint = YES;
                    }else{
                        isPoint = NO;
                    }
                }
                if (isPoint == NO) {
                    if((ffblk.bAttributes & FA_DIREC) != 0){
                        [fileList addObject:tmpFileName];
                        [isDirList addObject:@"isDir"];
                    } else {
                        [fileList addObject:tmpFileName];
                        [isDirList addObject:@"notDir"];
                    }
                }
            }
            while(1){
                if([fscController findNext:&ffblk] == 0){ break;}
                if(ffblk.bAttributes != FA_LONGFILENAME)
                {
                    if([fscController.longFileName isEqualToString:@""]){
                        tmpFileName = [[NSString alloc] initWithBytes:ffblk.sFileName
                                                               length:[fscController findStringEnd:ffblk.sFileName
                                                                                            length:sizeof(ffblk.sFileName)]
                                                             encoding:NSASCIIStringEncoding];
                        if ([tmpFileName isEqualToString:@"."] || [tmpFileName isEqualToString:@".."]) continue;
                    } else{
                        if(fscController.longFileNameIndex != 0){ continue;}
                        tmpFileName = fscController.longFileName;
                        if ([tmpFileName isEqualToString:@"."] || [tmpFileName isEqualToString:@".."]) continue;
                    }
                    
                    if((ffblk.bAttributes & FA_DIREC) != 0){
                        [fileList addObject:tmpFileName];
                        [isDirList addObject:@"isDir"];
                    } else {
                        [fileList addObject:tmpFileName];
                        [isDirList addObject:@"notDir"];
                    }
                }
            }
        }
    }
    
    //    DWORD fileTotalSize = 0;
    if (fileList != nil){
        if ([fileList count]>0) {
            for (cnt = 0; cnt < [fileList count]; cnt++)
            {
                if ([isDirList[cnt] isEqualToString:@"isDir"]) {
                    [self externalDirCopyToInternal:[path stringByAppendingPathComponent:fileList[cnt]]];
                }else{
                    [fm createFileAtPath:[path stringByAppendingPathComponent:fileList[cnt]] contents:nil attributes:nil];
                    
                    iHandle = [fscController openFile:fileList[cnt] openMode:OF_READ];
                    if (iHandle == -1) {
                        //open file fail!!!
                    }
                    //                    fileTotalSize = (uint32_t)[fscController getFileSize:iHandle];
                    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[path stringByAppendingPathComponent:fileList[cnt]]];
                    uint32_t dataLength;
                    if (iHandle != -1) {
                        uint32_t size = (uint32_t)[fscController getFileSize:iHandle];
                        while (1) {
                            @autoreleasepool{
                                NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                                dataLength = [fscController readFile:iHandle readBuf:aData readSize:MAX_DATABUFFER];
                                size -= dataLength;
                                aData = [NSData dataWithBytes:[aData bytes] length:dataLength];
                                [fileHandle writeData:aData];
                                if (!size) break;
                            }
                        }
                    }
                    [fileHandle closeFile];
                    [fscController closeFile:iHandle];
                }
            }
        }
    }
    [fscController changeDirectory:DOTDOT_STRING];
    [fm changeCurrentDirectoryPath:[path stringByDeletingLastPathComponent]];
    fileList = nil;
    isDirList = nil;
    tmpFileName = nil;
}
//================================================================================
//Demo Delete files in current directory of iFDisk
-(void)deleteItem
{
    NSString *iFDiskTestFolder1 = @"iFDiskTestFolder1";
    NSString *test0 = @"test0.zip";
    NSArray *MultiDeleteFile = [[NSArray alloc] initWithObjects:iFDiskTestFolder1,test0, nil];
    [self runDelete:MultiDeleteFile];
    [fscController packDirectory];
    [self debugMessageShow:@"--- : Delete File Complete"];
}
//================================================================================
//Delete files in current directory of iFDisk
//support multi-select and single-select
//The NSArray (MultiDeleteFile) is the group of file name

-(void)runDelete:(NSArray *)MultiDeleteFile
{
    for (int i = 0; i<[MultiDeleteFile count]; i++)
    {
        NSData *nameData = [MultiDeleteFile[i] dataUsingEncoding:NSASCIIStringEncoding];
        FFBLK ffblk;
        ffblk.bAttributes = 0;
        EXFAT_FFBLK exfatFFBLK;
        exfatFFBLK.aFileEntry.attrib = 0;
        BOOL fileExist = NO;
        
        if ([fscController getFATType] == EXFAT) {
            fileExist = [fscController findFirstEXFAT:MultiDeleteFile[i] findFirstStruct:&exfatFFBLK findFirstExact:YES];
        }else{
            if ([nameData length]==0) {
                fileExist = [fscController findFirst:[fscController str2DataWithUTF16:MultiDeleteFile[i]] findFirstStruct:&ffblk findFirstExact:YES];
            }
            else
            {
                fileExist = ([fscController findFirst:[fscController str2DataWithUTF16:MultiDeleteFile[i]] findFirstStruct:&ffblk findFirstExact:YES])||([fscController findFirst:[fscController str2DataWithASCII:MultiDeleteFile[i]] findFirstStruct:&ffblk findFirstExact:YES]);
            }
        }
        
        if (fileExist)
        {
            if ([fscController getFATType] == EXFAT) {
                if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                    // this is folder
                    [self dirDelete:MultiDeleteFile[i]];
                } else{
                    //this is file
                    [fscController deleteFile:MultiDeleteFile[i]];
                }
            }else{
                if((ffblk.bAttributes & FA_DIREC) != 0){
                    // this is folder
                    [self dirDelete:MultiDeleteFile[i]];
                } else {
                    //this is file
                    [fscController deleteFile:MultiDeleteFile[i]];
                }
            }
        }
        else
        {
            //delete file fail. no file can be deleted.
            [self debugMessageShow:@"--- : Delete File Fail. Please Do This Function After the Copy (iDevice to iFDisk) "];
        }
    }
}
//================================================================================
- (void)dirDelete:(NSString *)path
{
    @autoreleasepool {
        NSInteger iHandle = -1;
        iHandle = [fscController changeDirectory:path];
        if(!iHandle){
            //change directory fail!!!
            return;
        }
        NSMutableArray *fileList = [[NSMutableArray alloc]init];
        NSMutableArray *isDirList = [[NSMutableArray alloc]init];
        FFBLK ffblk;
        EXFAT_FFBLK exfatFFBLK;
        NSString *tmpFileName = @"";
        uint32_t cnt=0;
        
        if ([fscController getFATType] == EXFAT) {
            if([fscController findFirstEXFAT:@"" findFirstStruct:&exfatFFBLK findFirstExact:NO] == 0){
                // Not found...
                fileList = nil;
                isDirList = nil;
            } else{
                if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                    //This is a folder
                    tmpFileName = [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length];
                    [fileList addObject:tmpFileName];
                    [isDirList addObject:@"isDir"];
                    
                } else{
                    //This is a file
                    tmpFileName = [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length];
                    [fileList addObject:tmpFileName];
                    [isDirList addObject:@"notDir"];
                }
                
                while([fscController findNextEXFAT:&exfatFFBLK]){
                    if((exfatFFBLK.aFileEntry.attrib  & FA_DIREC) != 0){
                        //This is a folder
                        tmpFileName = [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length];
                        [fileList addObject:tmpFileName];
                        [isDirList addObject:@"isDir"];
                    } else{
                        //This is a file
                        tmpFileName = [fscController bytes2StrWithUTF16:exfatFFBLK.aFilename withLength:exfatFFBLK.aFileInfoEntry.name_length];
                        [fileList addObject:tmpFileName];
                        [isDirList addObject:@"notDir"];
                    }
                }
            }
        }else{
            if([fscController findFirst:[fscController str2DataWithASCII:@""] findFirstStruct:&ffblk findFirstExact:NO] == 0){
                fileList = nil;
                isDirList = nil;
            }else{
                BOOL isPoint = NO;
                if(ffblk.bAttributes != FA_LONGFILENAME){
                    if([fscController.longFileName isEqualToString:@""]){
                        tmpFileName = [[NSString alloc] initWithBytes:ffblk.sFileName length:[fscController findStringEnd:ffblk.sFileName length:sizeof(ffblk.sFileName)] encoding:NSASCIIStringEncoding];
                        if ([tmpFileName isEqualToString:@"."] || [tmpFileName isEqualToString:@".."]) {
                            isPoint = YES;
                        }else {
                            isPoint = NO;
                        }
                    } else{
                        tmpFileName = fscController.longFileName;
                        if ([tmpFileName isEqualToString:@"."] || [tmpFileName isEqualToString:@".."]) {
                            isPoint = YES;
                        }else{
                            isPoint = NO;
                        }
                    }
                    if (isPoint == NO) {
                        if((ffblk.bAttributes & FA_DIREC) != 0){
                            [isDirList addObject:@"isDir"];
                            [fileList addObject:tmpFileName];
                        } else {
                            [isDirList addObject:@"notDir"];
                            [fileList addObject:tmpFileName];
                        }
                    }
                }
                while(1){
                    if([fscController findNext:&ffblk] == 0){ break;}
                    if(ffblk.bAttributes != FA_LONGFILENAME){
                        if([fscController.longFileName isEqualToString:@""]){
                            tmpFileName = [[NSString alloc] initWithBytes:ffblk.sFileName
                                                                   length:[fscController findStringEnd:ffblk.sFileName
                                                                                                length:sizeof(ffblk.sFileName)]
                                                                 encoding:NSASCIIStringEncoding];
                            if ([tmpFileName isEqualToString:@"."] || [tmpFileName isEqualToString:@".."]) continue;
                        } else{
                            if(fscController.longFileNameIndex != 0){ continue;}
                            tmpFileName = fscController.longFileName;
                            if ([tmpFileName isEqualToString:@"."] || [tmpFileName isEqualToString:@".."]) continue;
                        }
                        
                        if((ffblk.bAttributes & FA_DIREC) != 0){
                            [isDirList addObject:@"isDir"];
                            [fileList addObject:tmpFileName];
                        } else{
                            [isDirList addObject:@"notDir"];
                            [fileList addObject:tmpFileName];
                        }
                    }
                }
            }
        }
        
        if (fileList != nil) {
            if ([fileList count]>0) {
                for (cnt = 0; cnt < [fileList count]; cnt++) {
                    if ([isDirList[cnt] isEqualToString:@"isDir"]) {
                        [self dirDelete:fileList[cnt]];
                    }else{
                        //                        iHandle = -1;
                        iHandle = [fscController deleteFile:fileList[cnt]];
                        if(iHandle==(-1)){
                            //delete file fail!!!
                        }
                    }
                }
            }
        }
        [fscController changeDirectory:DOTDOT_STRING];
        //        iHandle = -1;
        iHandle = [fscController deleteFile:path];
        if(iHandle==(-1))
        {
            //delete folder fail!!!
        }
        
        fileList = nil;
        isDirList = nil;
    }
}
//================================================================================
//Open file by absolute path
-(void)absolutePathOpenDemo
{
    NSString *test0 = [[NSBundle mainBundle] pathForResource:@"test0" ofType:@"zip"];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:test0];
    int absolute_intHandle = [fscController openFileAbsolutePath:PATTEN_ABSOLUTE_PATH openMode:OF_CREATE];
    if (absolute_intHandle != -1)
    {
        uint32_t dataLength = 0;
        uint32_t uintDataSize = 0;
        uint32_t uintDataTranLen = 0;
        uintDataSize = (uint32_t)[self returnFileSize:test0];
        @synchronized(self){
            while((dataLength != -1) && (uintDataSize != 0))
            {
                @autoreleasepool {
                    uintDataTranLen = ((uintDataSize > MAX_DATABUFFER) ? MAX_DATABUFFER : uintDataSize);
                    [[fileHandle readDataOfLength:uintDataTranLen] getBytes:byDataBuf];
                    NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                    dataLength = [fscController writeFile:absolute_intHandle writeBuf:aData writeSize:uintDataTranLen];
                    uintDataSize -= dataLength;
                }
            }
            [fscController closeFile:absolute_intHandle];
            [fileHandle closeFile];
        }
        
        [self debugMessageShow:@"--- : Absolute Path Open File and Write a File Demo Success (/absolutePathTest/iFDiskSDKTest/AbsoluteTest.zip) "];
    }
    else
    {
        [self debugMessageShow:@"--- : File EXIST (/absolutePathTest/iFDiskSDKTest/AbsoluteTest.zip) "];
    }
}
//================================================================================
//Delete file by absolute path
-(void)absolutePathDeleteDemo
{
    int absolute_intHandle = 0;
    
    absolute_intHandle = [fscController deleteFileAbsolutePath:PATTEN_ABSOLUTE_PATH];
    if(absolute_intHandle != -1){ [self debugMessageShow:@"--- : Delete File SUCCESS(%@) (Only delete file, not Delete Folder)", PATTEN_ABSOLUTE_PATH];
    } else{              [self debugMessageShow:@"--- : Delete File FAIL(%@)", PATTEN_ABSOLUTE_PATH];}
    
}
//================================================================================
//Demo the absolute path directory operations
-(void)absolutePathDirectoryDemo
{
    [self debugMessageShow:@"--- : Current Directory: (%@)",[fscController getCurrentDirectory]];
    
    if([fscController createDirectoryAbsolutePath:PATTEN_DIRECTORY_ABSOLUTE_PATH])
    {
        [self debugMessageShow:@"--- : Create Directory Success :(%@)",PATTEN_DIRECTORY_ABSOLUTE_PATH];
        [self debugMessageShow:@"--- : Current Directory: (%@)",[fscController getCurrentDirectory]];
        
        if ([fscController changeDirectoryAbsolutePath:PATTEN_DIRECTORY_ABSOLUTE_PATH])
        {
            [self debugMessageShow:@"--- : Change Directory Success"];
            [self debugMessageShow:@"--- : Current Directory: (%@)",[fscController getCurrentDirectory]];
            [self debugMessageShow:@"--- : Change Directory to Root"];
            [fscController changeDirectory:ROOT_STRING];
        }
        else
        {
            [self debugMessageShow:@"--- : Change Directory Fail"];
        }
    }
    else
    {
        [self debugMessageShow:@"--- : Create Directory Fail (Directory Exist)"];
    }
    
    [self debugMessageShow:@"--- : Current Directory: (%@)",[fscController getCurrentDirectory]];
}

//================================================================================
//Search file Demo
-(void)searchFileDemo
{
    [self debugMessageShow:@"*** Search Name: \"test1.zip\" (Exact)"];
    NSArray * filePathExact = [fscController searchFile:@"test1.zip" isExact:YES];
    if ([filePathExact count]<1) {
        [self debugMessageShow:@"--- : NO Found"];
    }else{
        for (NSString *path in filePathExact) {
            [self debugMessageShow:@"--- : %@",path];
        }
    }
    [self debugMessageShow:@"***--------------------------------***"];
    [self debugMessageShow:@"***--------------------------------***"];
    
    [self debugMessageShow:@"*** Search Name: \"test\"  (Not Exact)"];
    NSArray * filePathNoExact = [fscController searchFile:@"test" isExact:NO];
    if ([filePathNoExact count]<1) {
        [self debugMessageShow:@"--- : NO Found"];
    }else{
        for (NSString *path in filePathNoExact) {
            [self debugMessageShow:@"--- : %@",path];
        }
    }
}
//================================================================================
//Rename file Demo
-(void)renameFileDemo
{
    [self debugMessageShow:@"--- : Rename function Start"];
    [self debugMessageShow:@"*** File Rename: \"SFN.JPG\" to \"RenameTestFile.jpg\" "];
    if([fscController searchFile:PATTEN_SFN_ROOT])
    {
        if ([fscController renameFile:PATTEN_SFN_ROOT toName:PATTEN_RENAME]==-1)
        {
            [self debugMessageShow:@"--- : Rename File Fail"];
        }else{
            [self debugMessageShow:@"--- : Rename (\"SFN.JPG\") to (\"RenameTestFile.jpg\") Success"];
        }
    }else{
        [self debugMessageShow:@"--- : Rename File Fail. Please Do This Function After the [WT File(SFN.JPG)] Function"];
    }
    
    [self debugMessageShow:@"--- : Rename function End"];
}
//================================================================================
//Move file Demo
-(void)moveFileDemo
{
    NSString *movePatten1 = @"test2_1.zip";
    NSString *movePatten2 = @"test2_2.zip";
    NSArray *moveGroup = [NSArray arrayWithObjects:movePatten1,movePatten2,nil];
    [self debugMessageShow:@"--- : Move File Process Start"];
    [self doWriteFile:movePatten1];
    [self doWriteFile:movePatten2];
    [self createFolder];
    if ([[fscController cutFiles:moveGroup] count]==0) {
        [self debugMessageShow:@"--- : Change directory to \"iFDiskTest\" "];
        [fscController changeDirectory:@"iFDiskTest"];
        if ([[fscController pasteFiles] count]==0) {
            [self debugMessageShow:@"--- : Browse \"iFDiskTest\" folder"];
            [self doBrowsFile];
        }else{
            [self debugMessageShow:@"--- : Move file fail (May file already exists)"];
        }
        [self debugMessageShow:@"--- : Change directory to ROOT"];
        [fscController changeDirectory:ROOT_STRING];
        [self debugMessageShow:@"--- : Move File Process End"];
    }else{
        [self debugMessageShow:@"--- : Move file fail (Cut fail)"];
    }
}
//================================================================================
//File resize Demo
-(void)resizeFileDemo
{
    NSString *resizePatten1 = @"test1.zip";
    NSString *resizePatten2 = @"resizePatten.zip";
    [self debugMessageShow:@"--- : Resize File Process Start"];
    if(![fscController searchFile:resizePatten2]){
        [self doWriteFile:resizePatten1];
        [fscController renameFile:resizePatten1 toName:resizePatten2];
    }
    int resizeFileHandle = [fscController openFile:resizePatten2 openMode:OF_WRITE];
    QWORD fileSize = [fscController getFileSize:resizeFileHandle];
    [self debugMessageShow:@"--- : Resize File Before (resizePatten.zip file size: %llu)",fileSize];
    [fscController resizeFile:resizeFileHandle newSize:(fileSize+(480*1024))];
    fileSize = [fscController getFileSize:resizeFileHandle];
    [self debugMessageShow:@"--- : Resize File After (resizePatten.zip file size: %llu)",fileSize];
    [fscController closeFile:resizeFileHandle];
    [self debugMessageShow:@"--- : Resize File Process End"];
}
//================================================================================
//URL stream play video Demo
-(void)streamPlay
{
    //Play the video in the current directory
    [self debugMessageShow:@"--- : Copy Stream Test Video"];
    [self doWriteFile:PATTEN_SFN_ROOT];
    [self doWriteFile:PATTEN_STREAM_PLAY];
    [self debugMessageShow:@"--- : Copy Stream Test Video complete"];
    [delegateForAPI streamPlayVideo:PATTEN_STREAM_PLAY];
    
    // You can also use absolute path to play video.
    // Example:
    // Want to play the video at (/TestFolder/streamPlayVideo.mp4)
    // [delegateForAPI streamPlayVideo:@"/TestFolder/streamPlayVideo.mp4"];
}
//================================================================================
//Sets Volume label
-(void)setVolumeLabel
{
    [self debugMessageShow:@"--- : Set Volume Labe Start"];
    
    NSString *labelName1 = [fscController getLabel];
    [self debugMessageShow:@"--- : Get Volume Labe (before): %@",labelName1];
    
    //Labe name can not be more than 11 words, and FAT32 type only supports the name of ASCII code
    if ([fscController setLabel:@"iFDiskSDK"]) {
        [self debugMessageShow:@"--- : Set Volume Labe:\"iFDiskSDK\""];
        NSString *labelName2 = [fscController getLabel];
        [self debugMessageShow:@"--- : Get Volume Labe (after): %@",labelName2];
    }else{
        [self debugMessageShow:@"--- : Set Volume Labe fail"];
    }
    [self debugMessageShow:@"--- : Set Volume Labe End"];
}
//================================================================================
//Copy file (external to external)
-(void)externalCopyToExternal
{
    [self debugMessageShow:@"--- : External Copy to External Start"];
    
    NSString *readFolder = @"/exCopyToExFolder_ForRead";
    NSString *writeFolder = @"/exCopyToExFolder_ForWrite";
    [fscController createDirectoryAbsolutePath:readFolder];
    [fscController createDirectoryAbsolutePath:writeFolder];
    [fscController changeDirectoryAbsolutePath:readFolder];
    
    [self doWriteFile:PATTEN_SFN_ROOT];
    
    int read_intHandle = [fscController openFileAbsolutePath:[readFolder stringByAppendingPathComponent:PATTEN_SFN_ROOT] openMode:OF_READ];
    int write_intHandle = [fscController openFileAbsolutePath:[writeFolder stringByAppendingPathComponent:@"externalCopyTest.jpg"] openMode:OF_CREATE];
    
    if ((read_intHandle != -1)&&(write_intHandle != -1))
    {
        uint64_t dataLength = 0;
        uint64_t uintDataSize = 0;
        uint64_t uintDataTranLen = 0;
        uintDataSize = [fscController getFileSize:read_intHandle];
        @synchronized(self){
            while((dataLength != -1) && (uintDataSize != 0))
            {
                @autoreleasepool {
                    uintDataTranLen = ((uintDataSize > MAX_DATABUFFER) ? MAX_DATABUFFER : uintDataSize);
                    NSData *aData = [NSData dataWithBytes:byDataBuf length:sizeof(byDataBuf)];
                    dataLength = [fscController readFile:read_intHandle readBuf:aData readSize:(uint32_t)uintDataTranLen];
                    if ((dataLength!=0)&&(dataLength!=-1)) {
                        aData = [NSData dataWithBytes:[aData bytes] length:(uint32_t)dataLength];
                        [fscController writeFile:write_intHandle writeBuf:aData writeSize:(uint32_t)dataLength];
                    }
                    uintDataSize -= dataLength;
                }
            }
            read_intHandle = [fscController closeFile:read_intHandle];
            write_intHandle = [fscController closeFile:write_intHandle];
        }
        
        [self debugMessageShow:@"--- : Close file result: readHandle:%d ,writeHandle:%d",read_intHandle,write_intHandle];
    }
    else
    {
        [self debugMessageShow:@"--- : Open file fail !!! "];
    }
    [fscController changeDirectoryAbsolutePath:@"/"];
    
    [self debugMessageShow:@"--- : External Copy to External End"];
    
}
//================================================================================
- (void)doAttributeDemo
{
    NSString *filePatten = @"test2_1.zip";
    NSString *dirPatten = @"testDir";
    FILE_ATTRIBUTE fileAttribute, fileAttribute2;
    
    [self doWriteFile:filePatten];
    [fscController createDirectory:dirPatten];
    
    sleep(3);
    
    NSString *referenceFile = @"test0.zip";
    [self doWriteFile:referenceFile];
    
    if ([fscController getFileAttribute:filePatten fileAttribute:&fileAttribute]) {
        
        [self debugMessageShow:@"--- : File Old: attributes: %u , CDate: %u , CTime: %u , MDate: %u , MTime: %u , ADate: %u , ATime: %u",fileAttribute.attributes,fileAttribute.creationDate,fileAttribute.creationTime,fileAttribute.modificationDate,fileAttribute.modificationTime,fileAttribute.accessDate,fileAttribute.accessTime];
        
        if ([fscController getFileAttribute:referenceFile fileAttribute:&fileAttribute2]) {
            fileAttribute.enableAttr = YES;
            fileAttribute.attributes = fileAttribute2.attributes | FA_RDONLY;
            
            fileAttribute.enableCDate = YES;
            fileAttribute.creationDate = fileAttribute2.creationDate;
            fileAttribute.creationTime = fileAttribute2.creationTime;
            fileAttribute.creationTimeCS = fileAttribute2.creationTimeCS;
            
            fileAttribute.enableMDate = YES;
            fileAttribute.modificationDate = fileAttribute2.modificationDate;
            fileAttribute.modificationTime = fileAttribute2.modificationTime;
            fileAttribute.modificationTimeCS = fileAttribute2.modificationTimeCS;
            
            fileAttribute.enableADate = YES;
            fileAttribute.accessDate = fileAttribute2.accessDate;
            fileAttribute.accessTime = fileAttribute2.accessTime;
            
            [fscController setFileAttribute:filePatten fileAttribute:fileAttribute];
            
            if ([fscController getFileAttribute:filePatten fileAttribute:&fileAttribute]) {
                [self debugMessageShow:@"--- : File New: attributes: %u , CDate: %u , CTime: %u , MDate: %u , MTime: %u , ADate: %u , ATime: %u",fileAttribute.attributes,fileAttribute.creationDate,fileAttribute.creationTime,fileAttribute.modificationDate,fileAttribute.modificationTime,fileAttribute.accessDate,fileAttribute.accessTime];
            }
        }
    }
    
    if ([fscController getFileAttribute:dirPatten fileAttribute:&fileAttribute]) {
        
        [self debugMessageShow:@"--- : Folder Old: attributes: %u , CDate: %u , CTime: %u , MDate: %u , MTime: %u , ADate: %u , ATime: %u",fileAttribute.attributes,fileAttribute.creationDate,fileAttribute.creationTime,fileAttribute.modificationDate,fileAttribute.modificationTime,fileAttribute.accessDate,fileAttribute.accessTime];
        
        if ([fscController getFileAttribute:referenceFile fileAttribute:&fileAttribute2]) {
            fileAttribute.enableAttr = YES;
            fileAttribute.attributes = fileAttribute2.attributes | FA_RDONLY | FA_DIREC;
            
            fileAttribute.enableCDate = YES;
            fileAttribute.creationDate = fileAttribute2.creationDate;
            fileAttribute.creationTime = fileAttribute2.creationTime;
            fileAttribute.creationTimeCS = fileAttribute2.creationTimeCS;
            
            fileAttribute.enableMDate = YES;
            fileAttribute.modificationDate = fileAttribute2.modificationDate;
            fileAttribute.modificationTime = fileAttribute2.modificationTime;
            fileAttribute.modificationTimeCS = fileAttribute2.modificationTimeCS;
            
            fileAttribute.enableADate = YES;
            fileAttribute.accessDate = fileAttribute2.accessDate;
            fileAttribute.accessTime = fileAttribute2.accessTime;
            
            [fscController setFileAttribute:dirPatten fileAttribute:fileAttribute];
            
            if ([fscController getFileAttribute:dirPatten fileAttribute:&fileAttribute]) {
                [self debugMessageShow:@"--- : Folder New: attributes: %u , CDate: %u , CTime: %u , MDate: %u , MTime: %u , ADate: %u , ATime: %u",fileAttribute.attributes,fileAttribute.creationDate,fileAttribute.creationTime,fileAttribute.modificationDate,fileAttribute.modificationTime,fileAttribute.accessDate,fileAttribute.accessTime];
            }
        }
    }
    
}

//================================================================================

- (void)fsCheckMode:(uint8_t)uintMode fsFile:(NSString *)nssFileName fsCMD:(NSString *)nssCMDName
{
    //Ray 20150625
    [self debugMessageShow:@"fsCheckMode"];
    [self debugMessageShow:@"uintMode:(%d)", uintMode];
    [self debugMessageShow:@"nssFileName:(%@)", nssFileName];
    [self debugMessageShow:@"nssCMDName:(%@)", nssCMDName];
    //NSString *fileName = @"ray.txt";
    //NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *path = [pathList objectAtIndex:0];
    
    _uintFileSize = 0;
    _uintTranSize = 0;
    
    [self debugMessageShow:@"*** : Command (%@)", nssCMDName];
    //============================================================================
    if(isFileSystemInitial == NO){
        [self doInitialFileSystem];
        if(isFileSystemInitial == NO){
            [self debugMessageShow:@"*** : Command TERMINAL (FileSystemERROR)"];
            return;
        }
    }
    
    //Change directory to root
    [self doChangeDirectory:ROOT_STRING];

    switch(uintMode){
            //====================================================================
        case SFOP_BROWSER:
            //[fscController  changeDirectoryAbsolutePath:@"/PLi"];
            //[self doChangeDirectory:@"PLi"];
            //[self doChangeDirectory:@"Read"];
            [self doBrowsFile];
            
            break;
            //====================================================================
        case SFOP_DELETE:
            [self doDeleteFile_Directory:nssFileName];
            break;
            //====================================================================
        case SFOP_READ_EX:
            [self doReadFile:nssFileName];
            break;
            //====================================================================
        case SFOP_WRITE_EX:
            
//            if (1){
//                //加上檔名
//                path = [path stringByAppendingPathComponent:fileName];
//                [self debugMessageShow:@"--- : path:(%@)", path];
//                //NSLog([@"存取檔案的路徑：" stringByAppendingString: path]);
//                
//                //寫入檔案
//                NSString *data = @"file data";
//                [data writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
//                
////                //讀取檔案
////                NSString *rdata = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
////                [self debugMessageShow:@"--- : ray.txt data:(%@)", rdata];
////                //NSLog([@"檔案內容：" stringByAppendingString: rdata]);
////                
////                
////                //判斷檔案是否存在
////                if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
////                    [self debugMessageShow:@"--- : 檔案存在"];
////                    //                   NSLog([@"檔案存在，開始刪除：" stringByAppendingString: path]);
////                    //                   //刪除檔案
////                    //                   [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
////                }
//            }
//            [self doWriteFileToOTG:path:fileName];

            [self doWriteFile:nssFileName];
            break;
            //====================================================================
        case SFOP_SEEK:
            [self doSeekFile];
            break;
            //====================================================================
        case SFOP_CAPACITY:
            [self totalAvailableSpace];
            break;
            //====================================================================
        case SFOP_FORMAT:
            [self quickFormat];
            break;
            //====================================================================
        case SFOP_AES_EN:
            [self doAESEncryptFile:nssFileName];
            break;
            //====================================================================
        case SFOP_AES_DE:
            [self doAESDecryptFile:nssFileName];
            break;
            //====================================================================
        case SFOP_AVAILABLE_SPACE:
            [self getAvailableSpace];
            break;
            //====================================================================
        case SFOP_CREATE_FOLDER:
            [self createFolder];
            break;
            //====================================================================
        case SFOP_IN_TO_EX_COPY:
            [self INCopyToEX];
            break;
            //====================================================================
        case SFOP_EX_TO_IN_COPY:
            [self EXCopyToIN];
            break;
            //====================================================================
        case SFOP_DELETE_IFDISK:
            [self deleteItem];
            break;
            //====================================================================
        case SFOP_ABSOLUTE_OPEN:
            [self absolutePathOpenDemo];
            break;
            //====================================================================
        case SFOP_ABSOLUTE_DELETE:
            [self absolutePathDeleteDemo];
            break;
            //====================================================================
        case SFOP_ABSOLUTE_DIRECTORY:
            [self absolutePathDirectoryDemo];
            break;
            //====================================================================
        case SFOP_SEARCH_FILE:
            [self searchFileDemo];
            break;
            //====================================================================
        case SFOP_RENAME_FILE:
            [self renameFileDemo];
            break;
        case SFOP_MOVE_FILE:
            [self moveFileDemo];
            break;
            //====================================================================
        case SFOP_RESIZE_FILE:
            [self resizeFileDemo];
            break;
            //====================================================================
        case SFOP_STREAM_PLAY:
            [self streamPlay];
            break;
            //====================================================================
        case SFOP_SET_VOLUME_LABEL:
            [self setVolumeLabel];
            break;
            //====================================================================
        case SFOP_EX_COPY:
            [self externalCopyToExternal];
            break;
            //====================================================================
        case SFOP_ATTRIBUTE:
            [self doAttributeDemo];
            break;
            //====================================================================
        default:
            break;
    }
    
    [self debugMessageShow:@"*** : Command FINISH"];
}


//================================================================================
//Ray for Ver.1.0.3
//To add for available memory space
//start
//Write the image from album to OTG
- (void)doWriteImageToOTG:(UInt8)imgType Image:(UIImage *)image fileName:(NSString *)nssWrtFileName
{
    //[Is destination file exist]
    int write_intHandle = 1;
    write_intHandle = [fscController openFileAbsolutePath:nssWrtFileName openMode:OF_READ];
    if(write_intHandle == 0){
        [fscController closeFile:write_intHandle];
        NSString *str = @"Destination file is exist!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return;
    }
    
    //OTG File *Point
    int read_intHandle = 1;
    read_intHandle = [fscController openFileAbsolutePath:nssWrtFileName openMode:OF_CREATE];
    //[self debugMessageShow:@"intHandle(%d)", intHandle];
    
    uint32_t uintDataCount = 0;
    uint64_t uintDataSize = 0, uintDataOffset = 0;
    uint64_t uintDataTranLen = 0;
    
    //[Image to NSData]
    NSData *nsdImgData;
    
    if (imgType == JPG) {
        nsdImgData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(image,1)];
    }
    else {
        nsdImgData = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
    }
    
    //[Get data size]
    uintDataSize = nsdImgData.length;
    
    uint64_t FATblockSize;
    if ([fscController getFATType] == EXFAT) {
        FATblockSize = 32768; //exFAT defult:32K
    }
    else{ //FAT32
        FATblockSize = 8192; //FAT32 defult:8K
    }
    //uint64_t srcFileSize = [fscController getFileSize:read_intHandle];
    uint64_t srcFileSize = uintDataSize;
    uint64_t spaceSize = [fscController getAvailableSpace];
    //For debug
    NSString *str2 = [NSString stringWithFormat:@"FATblockSize(%lld), srcFileSize(%lld), spaceSize(%lld)", FATblockSize, srcFileSize, spaceSize];
    UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:@"Message" message:str2 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert2 show];
    });
    
    if ((srcFileSize > spaceSize) || (spaceSize == 0)) {
        read_intHandle = [fscController closeFile:intHandle];
        
        NSString *str = @"Available Space is't enough!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return;
    }
    
    //NSData to byte[]
    Byte *bytImgData = (Byte*)malloc(uintDataSize);
    memcpy(bytImgData, [nsdImgData bytes], uintDataSize);
    _uintFileSize = uintDataSize;
    
    while((uintDataCount != -1) && (uintDataSize != 0)){
        @autoreleasepool{
            uintDataTranLen = ((uintDataSize > MAX_APIDATA_SIZE) ? MAX_APIDATA_SIZE : uintDataSize);
            
            //取480K bytes
            NSData *aData = [nsdImgData subdataWithRange:NSMakeRange(uintDataOffset, uintDataTranLen)];
            uintDataCount = [fscController writeFile:read_intHandle writeBuf:aData writeSize:(uint32_t)uintDataTranLen];
            uintDataOffset += uintDataCount;
            uintDataSize -= uintDataCount;
            _uintTranSize += uintDataCount;
        }
    }
    read_intHandle = [fscController closeFile:intHandle];
}
//end



@end
