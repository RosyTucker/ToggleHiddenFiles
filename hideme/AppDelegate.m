#import "AppDelegate.h"

@implementation AppDelegate

NSStatusItem *statusItem;
NSMenuItem *toggleItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupStatusBarWithMenu:[self setupMenu]];
}

-(void) setupStatusBarWithMenu:(NSMenu*) menu
{
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"icon.png"]];
    [statusItem setToolTip:@"Show/Hide Hidden Files"];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menu];
}


-(NSMenu*) setupMenu
{
    NSMenu *theMenu = [[NSMenu alloc] init];
    toggleItem = [[NSMenuItem alloc] initWithTitle:[self getToggleItemTitle] action:@selector(toggleHiddenFiles) keyEquivalent:@""];
    
    [theMenu addItem:toggleItem];
    [theMenu addItem:[NSMenuItem separatorItem]];
    [[theMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"]
     setKeyEquivalentModifierMask:NSCommandKeyMask];
    return theMenu;
}


-(bool) getHiddenFilesState{
    NSTask *task = [[NSTask alloc] init];
    task.arguments = @[@"read",@"com.apple.finder",@"AppleShowAllFiles"];
    [task setLaunchPath:@"/usr/bin/defaults"];
    NSPipe * out = [NSPipe pipe];
    [task setStandardOutput:out];
    [task launch];
    [task waitUntilExit];
    
    NSFileHandle * read = [out fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    return [stringRead boolValue];
}

-(NSString*) toggleHiddenFilesState
{
    if([self getHiddenFilesState])
        return @"false";
    return @"true";
}


-(NSString*) getToggleFlag
{
    if([self getHiddenFilesState])
        return @"Hide";
    return @"Show";
}

-(NSString*) getToggleItemTitle
{
    return [NSString stringWithFormat:@"%@ Hidden Files", [self getToggleFlag]];
}

-(void) toggleHiddenFiles
{
    NSTask *task = [[NSTask alloc] init];
    task.arguments = @[@"write",@"com.apple.finder",@"AppleShowAllFiles",[self toggleHiddenFilesState]];
    [task setLaunchPath:@"/usr/bin/defaults"];
    [task launch];
    [task waitUntilExit];
    
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/killall"];
    [task setArguments:@[@"Finder"]];
    [task launch];
    [task waitUntilExit];

    toggleItem.title = [self getToggleItemTitle];
}

@end
