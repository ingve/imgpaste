#import <AppKit/AppKit.h>

NSData* getPNGDataFromPasteboard(void) {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    
    if (![pasteboard canReadObjectForClasses:@[[NSImage class]] options:nil]) {
        return nil;
    }
    
    NSArray *objects = [pasteboard readObjectsForClasses:@[[NSImage class]] options:nil];
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
    
    NSData *pngData = [imageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    if (!pngData) {
        return nil;
    }
    
    return pngData;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSData *pngData = getPNGDataFromPasteboard();
        
        if (pngData == nil) {
            fprintf(stderr, "Error getting image from clipboard\n");
            return EXIT_FAILURE;
        }
        
        NSFileHandle *stdout = [NSFileHandle fileHandleWithStandardOutput];
        [stdout writeData:pngData];
    }
    return EXIT_SUCCESS;
}
