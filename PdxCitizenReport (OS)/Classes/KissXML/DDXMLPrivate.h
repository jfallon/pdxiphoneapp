// last updated from source on 7/13/2010 from:
// http://code.google.com/p/kissxml/source/browse/#svn/trunk

#import "DDXMLNode.h"
#import "DDXMLElement.h"
#import "DDXMLDocument.h"

// We can't rely solely on NSAssert, because many developers disable them for release builds.
// Our API contract requires us to keep these assertions intact.
#define DDCheck(condition, desc, ...)  { if(!(condition)) { [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd object:self file:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__ description:(desc), ##__VA_ARGS__]; } }

#define DDLastErrorKey @"DDXML:LastError"


@interface DDXMLNode (PrivateAPI)

+ (id)nodeWithUnknownPrimitive:(xmlKindPtr)kindPtr;

+ (id)nodeWithPrimitive:(xmlKindPtr)kindPtr;
- (id)initWithCheckedPrimitive:(xmlKindPtr)kindPtr;

+ (id)nodeWithPrimitive:(xmlNsPtr)ns nsParent:(xmlNodePtr)parent;
- (id)initWithCheckedPrimitive:(xmlNsPtr)ns nsParent:(xmlNodePtr)parent;

+ (BOOL)isXmlAttrPtr:(xmlKindPtr)kindPtr;
- (BOOL)isXmlAttrPtr;

+ (BOOL)isXmlNodePtr:(xmlKindPtr)kindPtr;
- (BOOL)isXmlNodePtr;

+ (BOOL)isXmlDocPtr:(xmlKindPtr)kindPtr;
- (BOOL)isXmlDocPtr;

+ (BOOL)isXmlDtdPtr:(xmlKindPtr)kindPtr;
- (BOOL)isXmlDtdPtr;

+ (BOOL)isXmlNsPtr:(xmlKindPtr)kindPtr;
- (BOOL)isXmlNsPtr;

- (BOOL)hasParent;

+ (void)recursiveStripDocPointersFromNode:(xmlNodePtr)node;

+ (void)detachAttribute:(xmlAttrPtr)attr fromNode:(xmlNodePtr)node;
+ (void)removeAttribute:(xmlAttrPtr)attr fromNode:(xmlNodePtr)node;
+ (void)removeAllAttributesFromNode:(xmlNodePtr)node;

+ (void)detachNamespace:(xmlNsPtr)ns fromNode:(xmlNodePtr)node;
+ (void)removeNamespace:(xmlNsPtr)ns fromNode:(xmlNodePtr)node;
+ (void)removeAllNamespacesFromNode:(xmlNodePtr)node;

+ (void)detachChild:(xmlNodePtr)child fromNode:(xmlNodePtr)node;
+ (void)removeChild:(xmlNodePtr)child fromNode:(xmlNodePtr)node;
+ (void)removeAllChildrenFromNode:(xmlNodePtr)node;

+ (void)removeAllChildrenFromDoc:(xmlDocPtr)doc;

- (void)nodeRetain;
- (void)nodeRelease;

+ (NSError *)lastError;

@end

@interface DDXMLElement (PrivateAPI)

+ (id)nodeWithPrimitive:(xmlKindPtr)kindPtr;
- (id)initWithCheckedPrimitive:(xmlKindPtr)kindPtr;

- (NSArray *)elementsWithName:(NSString *)name uri:(NSString *)URI;

+ (DDXMLNode *)resolveNamespaceForPrefix:(NSString *)prefix atNode:(xmlNodePtr)nodePtr;
+ (NSString *)resolvePrefixForURI:(NSString *)uri atNode:(xmlNodePtr)nodePtr;

@end

@interface DDXMLDocument (PrivateAPI)

+ (id)nodeWithPrimitive:(xmlKindPtr)kindPtr;
- (id)initWithCheckedPrimitive:(xmlKindPtr)kindPtr;

@end
