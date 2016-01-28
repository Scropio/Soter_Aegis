//
//  FileSystemController.h
//  iFDiskSDK
//
//  Created by CECAPRD on 2014/06/05.
//  Copyright (c) 2014年 CECAPRD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EADSessionController.h"

//================================================================================
#define MAX_SECTORSIZE              512

#define FA_NORMAL   				0x00	// Normal file, no attributes
#define FA_RDONLY   				0x01    // Read only attribute
#define FA_HIDDEN   				0x02    // Hidden file
#define FA_SYSTEM   				0x04    // System file
#define FA_LABEL    				0x08    // Volume label
#define FA_DIREC    				0x10    // Directory
#define FA_ARCH     				0x20    // Archive
#define FA_LONGFILENAME				0x0F	// Long Filename, FAT32/16 only

#define MAX_FILES                   20

#define OF_AVAILABLE                0x00
#define OF_CREATE                   0x01
#define OF_READ                     0x02
#define OF_WRITE                    0x04
#define OF_LONGFILENAME             0x08
#define OF_EXIST                    0x10

#define EMPTY_STRING                @""
#define SPACE_STRING                @" "
#define DOT_STRING                  @"."
#define DOTDOT_STRING               @".."
#define TILDE_STRING                @"~"
#define ROOT_STRING                 @"\\"

//================================================================================
typedef uint8_t                     BYTE;
typedef uint16_t                    WORD;
typedef uint32_t                    DWORD;
typedef uint64_t                    QWORD;

typedef struct {
    BYTE sFileName[13];
    BYTE bAttributes;
    WORD ff_time;
    WORD ff_date;
    DWORD dwFileSize;
} FFBLK;

//==== file or directory info (part 1)
typedef struct {
	uint8_t type;					/* EXFAT_ENTRY_FILE */
	uint8_t continuations;
	uint16_t checksum;
	uint16_t attrib;				/* combination of EXFAT_ATTRIB_xxx */
	uint16_t __unknown1;
	uint16_t crtime, crdate;		/* creation date and time */
	uint16_t mtime, mdate;			/* latest modification date and time */
	uint16_t atime, adate;			/* latest access date and time */
	uint8_t crtime_cs;				/* creation time in cs (centiseconds) */
	uint8_t mtime_cs;				/* latest modification time in cs */
	uint8_t __unknown2[10];
} EXFAT_ENTRY_META1;

//====  file or directory info (part 2)
typedef struct {
	uint8_t type;					/* EXFAT_ENTRY_FILE_INFO */
	uint8_t flags;					/* combination of EXFAT_FLAG_xxx */
	uint8_t __unknown1;
	uint8_t name_length;            /* file name length */
	uint16_t name_hash;
	uint16_t __unknown2;
	uint64_t real_size;				/* in bytes, equals to size */
	uint8_t __unknown3[4];
	uint32_t start_cluster;
	uint64_t size;					/* in bytes, equals to real_size */
} EXFAT_ENTRY_META2;

typedef struct {
	EXFAT_ENTRY_META1 aFileEntry;
    EXFAT_ENTRY_META2 aFileInfoEntry;
    uint16_t aFilename[256];
} EXFAT_FFBLK;

typedef enum{
    FAT12,
    FAT16,
    FAT32,
    EXFAT
} FATTYPE;

typedef struct {
    BOOL enableAttr;            // Enable change attribute
    uint16_t attributes;
    
    BOOL enableCDate;           // Enable change creation date and time
	uint16_t creationDate;
    uint16_t creationTime;
    uint8_t creationTimeCS;     // exFAT only
    
    BOOL enableMDate;           // Enable change modification date and time
    uint16_t modificationDate;
    uint16_t modificationTime;
    uint8_t modificationTimeCS; // exFAT only
    
    BOOL enableADate;           // Enable change access date and time
    uint16_t accessDate;
    uint16_t accessTime;        // exFAT only
    
} FILE_ATTRIBUTE;

//================================================================================
@class EADSessionController;

@interface FileSystemController : NSObject
// Init or share the FileSystemController
+ (FileSystemController *)sharedController;

//==== return 0(NO) : FAIL, return 1(YES) : PASS =============================
// Initial the file system on the ios accessory device
- (BYTE)initFileSystem;

// Starts a search of files that match the specified pattern
- (BYTE)findFirst:(NSData *)shortFileName findFirstStruct:(FFBLK *)aFFBLK findFirstExact:(BOOL)isExact;
//Finds subsequent files that match the condition of the FindFirst function. FindFirst must be called first before calling FindNext
- (BYTE)findNext:(FFBLK *)aFFBLK;

@property (nonatomic, readonly) NSString *longFileName;
@property (nonatomic, readonly) int longFileNameIndex;

// Starts a search of files that match the specified pattern (exFAT)
- (BYTE)findFirstEXFAT:(NSString *)fileName findFirstStruct:(EXFAT_FFBLK *)aFFBLK findFirstExact:(BOOL)isExact;
// Finds subsequent files that match the condition of the FindFirst function. FindFirst must be called first before calling FindNext (exFAT)
- (BYTE)findNextEXFAT:(EXFAT_FFBLK *)aFFBLK;

// Get the current Directory.
- (NSString *)getCurrentDirectory;

// Change the current Directory.
- (BOOL)changeDirectory:(NSString *)directoryName;
- (BOOL)changeDirectoryAbsolutePath:(NSString *)directoryPath;

// Create the directory by giving name.
- (BOOL)createDirectory:(NSString *)directoryName;
- (BOOL)createDirectoryAbsolutePath:(NSString *)directoryPath;

//==== return -1 : FAIL ======================================================
// Deletes the specified file. The file must not be open when this function is called.
- (int)deleteFile:(NSString *)fileName;
- (int)deleteFileAbsolutePath:(NSString *)filePath;

// Opens (or creates) a file for reading or writing (Maximum of five files can be opened simultaneously).
- (int)openFile:(NSString *)fileName openMode:(BYTE)mode;
- (int)openFileAbsolutePath:(NSString *)filePath openMode:(BYTE)mode;

// Closes a file and releases the file handle for future use.
- (int)closeFile:(int)handle;

// Writes data from the specified buffer into the file.
- (int)flushData:(int)handle;

// Rename the file or directory (in the current directory). When using this function, the file must not be open.
- (int)renameFile:(NSString *)fileName toName:(NSString *)newFileName;

// Resize the file to the new size.
- (BOOL)resizeFile:(int)handle newSize:(QWORD)length;

// Gets the file attribute (in the current directory).
- (BOOL)getFileAttribute:(NSString *)fileName fileAttribute:(FILE_ATTRIBUTE *)fileAttribute;

// Sets the file attribute (in the current directory). When using this function, the file must not be open.
- (BOOL)setFileAttribute:(NSString *)fileName fileAttribute:(FILE_ATTRIBUTE)fileAttribute;

//============================================================================
// Writes data from the specified buffer into the file.
- (DWORD)writeFile:(int)handle writeBuf:(NSData *)data writeSize:(DWORD)length;

// Reads data from the specified buffer into the file
- (DWORD)readFile:(int)handle readBuf:(NSData *)data readSize:(DWORD)length;

// Sets the current position of this file to the given value.
- (QWORD)seekFile:(int)handle seekPosition:(QWORD)position;

// Return the file size of the file represented by the handle.
- (QWORD)getFileSize:(int)handle;

// Gets the position of the file.
- (QWORD)getFilePosition:(int)handle;

// Gets the mode the file was opened with.
- (BYTE)getFileOpenMode:(int)handle;

//============================================================================
// Cleans up the current directory and releases unused entry space.
- (void)packDirectory;

// Clean up the external device space.
- (void)quickFormat;
// If formatProcess = formatTotal, QuickFormat complete. ==> process: (formatProcess/formatTotal)%
@property (nonatomic, readonly) int32_t formatTotal, formatProcess;

// Return the FAT type of iFDisk.
- (FATTYPE)getFATType;

// Sets the volume label of iFDisk device (label name can't be more than 11 words, and FAT32 type only supports the name of ASCII code).
- (BOOL)setLabel:(NSString *)labelName;

// Gets the volume label of iFDisk device.
- (NSString *)getLabel;

// Return the total available space
- (QWORD)getTotalAvailableSpace;

// Return the available space
- (QWORD)getAvailableSpace;

// Search iFDisk storage by file name.
- (NSArray *)searchFile:(NSString *)fileName isExact:(BOOL)isExact;

// Search current directory by file name.
- (BOOL)searchFile:(NSString *)fileName;

// Cut the files or directories (in the current directory). When using this function, the file must not be open.
- (NSArray *)cutFiles:(NSArray *)filenames;

// Paste the files or directories to the current directory. The cut files can't be pasted in the same directory (or directories that have been cut).
- (NSArray *)pasteFiles;

//============================================================================
// Return YES, the external device support the AES encryption function.
- (BOOL)isAESEnabled;

// Turns on the encryption or decryption functions, and specifies the password.
- (BOOL)initAESwithPassword:(NSString *)password withType:(BOOL)isEncrypt;

// Transmit data to encrypt or to decrypt.
- (BOOL)sendAESData:(uint8_t *)buf withLen:(uint32_t)length;

// Turn off the encryption or decryption functions.
- (BOOL)setAESDisable;

//============================================================================
// Transform NSData to NSString.
- (NSString *)data2StrWithASCII:(NSData *)data;
- (NSString *)data2StrWithUTF16:(NSData *)data;
- (NSString *)bytes2StrWithUTF16:(uint16_t *)buf withLength:(uint8_t)length;

// Transform NSString to NSData.
- (NSData *)str2DataWithASCII:(NSString *)fileName;
- (NSData *)str2DataWithUTF16:(NSString *)fileName;

- (uint32_t)findStringEnd:(uint8_t *)buf length:(uint32_t)length;
@end
