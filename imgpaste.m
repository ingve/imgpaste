#import <AppKit/AppKit.h>

NSBitmapImageFileType fileType() {
  NSArray *arguments = [[NSProcessInfo processInfo] arguments];
  NSUInteger argumentCount = [arguments count];

  if (argumentCount == 3 && [arguments[1] isEqualToString:@"-Prefer"]) {
    NSString *format = arguments[2];

    NSDictionary *formats = @{
      @"png" : @(NSBitmapImageFileTypePNG),
      @"jpg" : @(NSBitmapImageFileTypeJPEG),
      @"jpeg" : @(NSBitmapImageFileTypeJPEG),
      @"tiff" : @(NSBitmapImageFileTypeTIFF),
      @"gif" : @(NSBitmapImageFileTypeGIF),
      @"bmp" : @(NSBitmapImageFileTypeBMP)
    };

    NSNumber *fileTypeNumber = formats[format];
    if (fileTypeNumber) {
      return (NSBitmapImageFileType)[fileTypeNumber unsignedIntegerValue];
    }
  }

  return NSBitmapImageFileTypePNG;
}

NSData *getImageDataFromPasteboard(NSBitmapImageFileType fileType) {
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

  if (![pasteboard canReadObjectForClasses:@[ [NSImage class] ] options:nil]) {
    return nil;
  }

  NSArray *objects = [pasteboard readObjectsForClasses:@[ [NSImage class] ]
                                               options:nil];
  if (objects.count == 0) {
    return nil;
  }

  NSImage *image = objects[0];
  NSData *tiffData = [image TIFFRepresentation];
  if (!tiffData) {
    return nil;
  }

  NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:tiffData];
  if (!imageRep) {
    return nil;
  }

  NSData *imageData = [imageRep representationUsingType:fileType
                                             properties:@{}];
  if (!imageData) {
    return nil;
  }

  return imageData;
}

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSData *imageData = getImageDataFromPasteboard(fileType());

    if (imageData == nil) {
      fprintf(stderr, "Error getting image from clipboard\n");
      return EXIT_FAILURE;
    }

    NSFileHandle *stdout = [NSFileHandle fileHandleWithStandardOutput];
    [stdout writeData:imageData];
  }

  return EXIT_SUCCESS;
}
