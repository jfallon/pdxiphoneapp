// last updated from source on 7/13/2010 from:
// http://code.google.com/p/kissxml/source/browse/#svn/trunk

#import <Foundation/Foundation.h>
#import "DDXML.h"

// These methods are not part of the standard NSXML API.
// But any developer working extensively with XML will likely appreciate them.

@interface DDXMLElement (DDAdditions)

+ (DDXMLElement *)elementWithName:(NSString *)name xmlns:(NSString *)ns;

- (DDXMLElement *)elementForName:(NSString *)name;
- (DDXMLElement *)elementForName:(NSString *)name xmlns:(NSString *)xmlns;

- (NSString *)xmlns;
- (void)setXmlns:(NSString *)ns;

- (void)addAttributeWithName:(NSString *)name stringValue:(NSString *)string;

- (NSDictionary *)attributesAsDictionary;

@end
