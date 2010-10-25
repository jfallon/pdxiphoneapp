// last updated from source on 7/13/2010 from:
// http://code.google.com/p/kissxml/source/browse/#svn/trunk

#import <Foundation/Foundation.h>
#import <libxml/tree.h>


@interface NSString (NSStringAdditions)

/**
 * xmlChar - A basic replacement for char, a byte in a UTF-8 encoded string.
 **/
- (const xmlChar *)xmlChar;

- (NSString *)stringByTrimming;

@end
