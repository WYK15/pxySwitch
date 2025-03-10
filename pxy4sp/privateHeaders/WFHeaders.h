#import <Foundation/Foundation.h>

@interface WFNetworkScanRecord : NSObject
@property (nonatomic,copy) NSString * ssid;  
@end

@interface WFInterface : NSObject
@property (nonatomic,retain) WFNetworkScanRecord * currentNetwork; 
@end


@interface WFClient : NSObject
@property (nonatomic,retain) WFInterface *interface;
+(id)sharedInstance;
@end

@interface WFOperation : NSOperation
@end


@interface WFSaveSettingsOperation : WFOperation
-(id)initWithSSID:(id)arg1 settings:(id)arg2 ;
-(void)setCurrentNetwork:(BOOL)arg1 ;
-(void)start;

@end

@interface WFSettingsProxy : NSObject

@property (nonatomic,copy) NSString * server;                                  //@synthesize server=_server - In the implementation block
@property (nonatomic,copy) NSString * port;                                    //@synthesize port=_port - In the implementation block
@property (nonatomic,copy) NSString * username;                                //@synthesize username=_username - In the implementation block
@property (nonatomic,copy) NSString * autoConfigureURL;                        //@synthesize autoConfigureURL=_autoConfigureURL - In the implementation block
@property (nonatomic,retain) NSDictionary * items;                             //@synthesize items=_items - In the implementation block
@property (assign,nonatomic) BOOL customProxy;                                 //@synthesize customProxy=_customProxy - In the implementation block
@property (assign,nonatomic) BOOL authenticated;                               //@synthesize authenticated=_authenticated - In the implementation block
@property (assign,nonatomic) BOOL autoConfigured;                              //@synthesize autoConfigured=_autoConfigured - In the implementation block
@property (assign,nonatomic) BOOL autoDiscoveryEnabled;                        //@synthesize autoDiscoveryEnabled=_autoDiscoveryEnabled - In the implementation block
@property (nonatomic,copy) NSString * password;                                //@synthesize password=_password - In the implementation block
@property (getter=isAutomatic,nonatomic,readonly) BOOL automatic; 
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy,readonly) NSString * description; 
@property (copy,readonly) NSString * debugDescription; 

-(void)setPassword:(NSString *)arg1 ;
-(id)initWithDictionary:(id)arg1 ;
+(id)defaultProxyConfiguration;
@end