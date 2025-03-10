
void* _CTServerConnectionCreate(CFAllocatorRef, void *, void *);
int64_t _CTServerConnectionSetCellularUsagePolicy(CFTypeRef* ct, NSString* identifier, NSDictionary* policies);

void chineseWifiFixup(void) 
{
    _CTServerConnectionSetCellularUsagePolicy(
        _CTServerConnectionCreate(kCFAllocatorDefault, NULL, NULL),
        NSBundle.mainBundle.bundleIdentifier,
        @{
            @"kCTCellularDataUsagePolicy" : @"kCTCellularDataUsagePolicyAlwaysAllow",
            @"kCTWiFiDataUsagePolicy" : @"kCTCellularDataUsagePolicyAlwaysAllow"
        }
	);
}

NSString *safeStr(NSString *str) {
    if (str == nil || str.length == 0) {
        return @"";
    }
    return str;
}