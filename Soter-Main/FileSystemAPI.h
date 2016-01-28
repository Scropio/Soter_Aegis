//
//  FileSystemAPI.h
//  iFDiskSDK
//
//  Created by Mac_ohm on 12/9/27.
//
//

#import <iFDiskSDK_iap2/iFDiskSDK_iap2.h>
#import <Foundation/Foundation.h>

//Ray 20150727
#define ENCRYPT_FILE                @".enc"
#define COPY_THE_SAME_FILE_MAX          100

#define COPY_OTG_TO_ALBUM               0
#define MOVE_OTG_TO_ALBUM               1
#define COPY_ALBUM_TO_OTG               2
#define MOVE_ALBUM_TO_OTG               3
#define JPG                             0
#define PNG                             1
#define PATH_ABSOLUTE                   0    //Absolute Path
#define PATH_RELATIVE                   1    //Relative Path

#define FILE_EXIST                      0
#define FILE_NOT_EXIST                  -1

//================================================================================
#define MIN_BLOCK_EXFAT                 32768
#define MIN_BLOCK_FAT32                 8192

#define FSC_LEN_MAXTRANFER          (48 * 1024)
#define MAX_WRITE_BUFFER_SIZE       (FSC_LEN_MAXTRANFER * 10)
#define MAX_APIDATA_SIZE            MAX_WRITE_BUFFER_SIZE
#define MAX_DATABUFFER              (1024 * 480)

#define SF_FIND_ROOT                @"Find ROOT"
#define SF_DEL_SFN                  @"DEL File(SFN.JPG)"
#define SF_RD_FILE_SFN              @"RD File(SFN.JPG)"
#define SF_WT_FILE_SFN              @"WT File(SFN.JPG)"
#define SF_SEEK_FILE                @"Seek File"
#define SF_AES_EN                   @"AES encrypt"
#define SF_AES_DE                   @"AES decrypt"
#define SF_CAPACITY                 @"Storage Capacity"
#define SF_FORMAT                   @"Quick Format"

#define SF_AVAILABLE_SPACE          @"Get Available Space"
#define SF_CREATE_FOLDER            @"Create Folder"
#define SF_IN_TO_EX_COPY            @"Copy (iDevice to iFDisk)"
#define SF_EX_TO_IN_COPY            @"Copy (iFDisk to iDevice)"
#define SF_DELETE_IFDISK            @"Delete (iFDisk)"
#define SF_OPEN_ABSOLUTE_PATH       @"Write file (AbsoluteTest.zip)"
#define SF_DELETE_ABSOLUTE_PATH     @"Delete file (AbsoluteTest.zip)"
#define SF_DIRECTORY_ABSOLUTE_PATH  @"Directory Demo (Absolute Path)"

#define SF_SEARCH_FILE              @"Search File"
#define SF_RENAME_FILE              @"File Rename"
#define SF_MOVE_FILE                @"Move File"
#define SF_RESIZE_FILE              @"File Resize"
#define SF_STREAM_PLAY              @"Stream Play"
#define SF_SET_VOLUME_LABEL         @"Set Volume Label"
#define SF_EX_COPY                  @"External Copy"
#define SF_ATTRIBUTE                @"Attribute Change"

#define PATTEN_STREAM_PLAY          @"streamPlayVideo.mp4"

#define PATTEN_SFN_ROOT             @"SFN.JPG"
#define PATTEN_RENAME               @"RenameTestFile.jpg"
#define PATTEN_ABSOLUTE_PATH        @"/absolutePathTest/iFDiskSDKTest/AbsoluteTest.zip"
#define PATTEN_DIRECTORY_ABSOLUTE_PATH  @"/absolutePathDirectory/iFDiskSDKTest/directoryTest"

#define AESFILETAG @"SoterAegis AES Tag"


//================================================================================
enum{
    SFOP_NONE = 0,
    SFOP_SEEK,
    SFOP_BROWSER,
    SFOP_DELETE,
    SFOP_READ_EX,
    SFOP_WRITE_EX,
    SFOP_AES_EN,
    SFOP_AES_DE,
    SFOP_CAPACITY = 8,
    SFOP_FORMAT,
    SFOP_AVAILABLE_SPACE,
    SFOP_CREATE_FOLDER,
    SFOP_IN_TO_EX_COPY,
    SFOP_EX_TO_IN_COPY,
    SFOP_DELETE_IFDISK,
    SFOP_ABSOLUTE_OPEN,
    SFOP_ABSOLUTE_DELETE,
    SFOP_ABSOLUTE_DIRECTORY,
    SFOP_SEARCH_FILE,
    SFOP_RENAME_FILE,
    SFOP_MOVE_FILE,
    SFOP_RESIZE_FILE,
    SFOP_STREAM_PLAY,
    SFOP_SET_VOLUME_LABEL,
    SFOP_EX_COPY,
    SFOP_ATTRIBUTE,
};

//================================================================================
@protocol FileSystemAPIDelegate <NSObject>
@required
- (void)checkAESComplete;
- (void)streamPlayVideo:(NSString *)fileName;
@optional
- (void)textViewMSG_Action:(NSString *)nssMessage;
- (void)textViewMSG_ActionBuffer:(uint8_t *)buffer bumpLength:(uint32_t)length;
@end
//================================================================================
@interface FileSystemAPI : NSObject
- (id)init:(id)idDelegate;
-(void)loadAESType;
- (uint64_t)returnFileSize:(NSString *)filePath;

- (void)fsCheckMode:(uint8_t)uintMode fsFile:(NSString *)nssFileName fsCMD:(NSString *)nssCMDName;

//Ray 20151007
- (void)doFileOTGtoAlbum:(UInt8)nssMode SrcPath:(NSString *)nssSrcPath;
- (BOOL)doAESEncryptOTGfile:(NSString *)nssSrcPath passWord:(NSString *)nssPassWord;
- (BOOL)doAESDecryptOTGfile:(NSString *)nssSrcPath passWord:(NSString *)nssPassWord;
- (NSMutableData *)doAESEncryptByData:(NSData *)nsSrcData passWord:(NSString *)nssPassWord;
- (NSMutableData *)doAESDecryptByData:(NSData *)nsSrcData passWord:(NSString *)nssPassWord;
- (NSMutableData *)doReadOTGfile:(NSString *)nssSrcPath;
- (void)CopyFileOTGtoDevice:(UInt8)nssMode SrcPath:(NSString *)nssSrcPath;
- (void)doDeleteOTGfile:(NSString *)nssSrcPath;

- (void)doWriteFileToOTG:(NSString *)nssSrcFileName
                fileName:(NSString *)nssDestFileName;

- (void)doWriteFileOTGtoOTG:(NSString *)nssSrcPath fileName:(NSString *)nssDestPath;
- (void)doWriteImageToOTG:(UInt8)imgType Image:(UIImage *)image fileName:(NSString *)nssWrtFileName;
- (NSMutableArray *)doListOTGFile:(UInt8)nssMode path:(NSString *)nssPath;


- (void)dealloc;


//Neil 20150821
-(uint64_t)getAvailableSpace;
-(uint64_t)totalAvailableSpace;


@property (nonatomic, assign) id fsAPIDelegate;
@property (nonatomic, readonly) uint64_t uintFileSize;
@property (nonatomic, readonly) uint64_t uintTranSize;
@property BOOL AESEnable;
@property (nonatomic,weak) id<FileSystemAPIDelegate>delegateForAPI;
@end

//================================================================================

