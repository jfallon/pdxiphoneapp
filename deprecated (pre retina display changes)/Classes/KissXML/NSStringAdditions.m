// last updated from source on 7/13/2010 from:
// http://code.google.com/p/kissxml/source/browse/#svn/trunk

#import "NSStringAdditions.h"


@implementation NSString (NSStringAdditions)

- (const xmlChar *)xmlChar
{
	return (const xmlChar *)[self UTF8String];
}

#ifdef GNUSTEP
- (NSString *)stringByTrimming
{
	return [self stringByTrimmingSpaces];
}
#else
- (NSString *)stringByTrimming
{
	NSMutableString *mStr = [self mutableCopy];
	CFStringTrimWhitespace((CFMutableStringRef)mStr);
	
	NSString *result = [mStr copy];
	
	[mStr release];
	return [result autorelease];
}
#endif

@end
