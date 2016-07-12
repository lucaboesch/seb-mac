//
//  SEBiOSConfigFileController.m
//  SafeExamBrowser
//
//  Created by Daniel R. Schneider on 15/12/15.
//
//


#import <Availability.h>

#import "SEBiOSConfigFileController.h"

@implementation SEBiOSConfigFileController
{
    BOOL alertViewHasBeenDismissed;

}

-(id) init
{
    self = [super init];
    if (self) {
        
        [super setDelegate:self];
}
    return self;
}


- (void) willReconfigureTemporary {
    // Release preferences window so bindings get synchronized properly with the new loaded values
//    [self.sebController.preferencesController releasePreferencesWindow];
    
}


- (void) didReconfigureTemporaryForEditing:(BOOL)forEditing sebFileCredentials:(SEBConfigFileCredentials *)sebFileCrentials {
    // Reset SEB, close third party applications
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
//    PreferencesController *prefsController = self.sebController.preferencesController;
    
    // If editing mode or opening the preferences window is allowed
    if (forEditing || [preferences secureBoolForKey:@"org_safeexambrowser_SEB_allowPreferencesWindow"]) {
        // we store the .seb file password/hash and/or certificate/identity
//        [prefsController setCurrentConfigPassword:sebFileCrentials.password];
//        [prefsController setCurrentConfigPasswordIsHash:sebFileCrentials.passwordIsHash];
//        [prefsController setCurrentConfigKeyRef:sebFileCrentials.keyRef];
    }
    
//    [prefsController initPreferencesWindow];
}


- (void) didReconfigurePermanentlyForceConfiguringClient:(BOOL)forceConfiguringClient sebFileCredentials:(SEBConfigFileCredentials *)sebFileCrentials {
    if (!forceConfiguringClient) {

        if ([[MyGlobals sharedMyGlobals] finishedInitializing]) {
            
            if (_sebViewController.alertController) {
                [_sebViewController.alertController dismissViewControllerAnimated:NO completion:nil];
            }
            _sebViewController.alertController = [UIAlertController  alertControllerWithTitle:NSLocalizedString(@"SEB Re-Configured", nil)
                                                                        message:NSLocalizedString(@"Local settings of this SEB client have been reconfigured.", nil)
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            [_sebViewController.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil)
                                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                                               [_sebViewController.alertController dismissViewControllerAnimated:NO completion:nil];
                                                                               
                                                                               // Inform callback that storing new settings was successful
                                                                               [super storeNewSEBSettingsSuccessful:true];
                                                                           }]];
            
            [_sebViewController presentViewController:_sebViewController.alertController animated:YES completion:nil];

        } else {
            // Set the flag to eventually display the dialog later
            [MyGlobals sharedMyGlobals].reconfiguredWhileStarting = YES;
            
            // Inform callback that storing new settings was successful
            [super storeNewSEBSettingsSuccessful:true];
        }
        
    }
    
//    PreferencesController *prefsController = self.sebController.preferencesController;
//
//    // If opening the preferences window is allowed
//    if ([preferences secureBoolForKey:@"org_safeexambrowser_SEB_allowPreferencesWindow"]) {
//        // we store the .seb file password/hash and/or certificate/identity
//        [prefsController setCurrentConfigPassword:sebFileCrentials.password];
//        [prefsController setCurrentConfigPasswordIsHash:sebFileCrentials.passwordIsHash];
//        [prefsController setCurrentConfigKeyRef:sebFileCrentials.keyRef];
//    }
    
//    [prefsController initPreferencesWindow];
}


// Ask the user to enter a password for loading settings using the message text and then call the callback selector with the password as parameter
- (void) promptPasswordWithMessageText:(NSString *)messageText callback:(id)callback selector:(SEL)selector;
{
    [self promptPasswordWithMessageText:messageText title:NSLocalizedString(@"Loading Settings",nil) callback:callback selector:selector];
}


// Ask the user to enter a password using the message text and then call the callback selector with the password as parameter
- (void) promptPasswordWithMessageText:(NSString *)messageText title:(NSString *)titleString callback:(id)callback selector:(SEL)selector;
{
    if (_sebViewController.alertController) {
        [_sebViewController.alertController dismissViewControllerAnimated:NO completion:nil];
    }
    _sebViewController.alertController = [UIAlertController alertControllerWithTitle:titleString
                                                                message:messageText
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [_sebViewController.alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Password", nil);
         textField.secureTextEntry = YES;
     }];
    
    [_sebViewController.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                                 NSString *password = _sebViewController.alertController.textFields.firstObject.text;
                                                                 if (!password) {
                                                                     password = @"";
                                                                 }
                                                                 IMP imp = [callback methodForSelector:selector];
                                                                 void (*func)(id, SEL, NSString*) = (void *)imp;
                                                                 func(callback, selector, password);
                                                             }]];
    
    [_sebViewController.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                             style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                                 // Return nil to callback method to indicate that cancel was pressed
                                                                 IMP imp = [callback methodForSelector:selector];
                                                                 void (*func)(id, SEL, NSString*) = (void *)imp;
                                                                 func(callback, selector, nil);
                                                             }]];
    
    [_sebViewController presentViewController:_sebViewController.alertController animated:YES completion:nil];
}


- (void) showAlertWrongPassword {
    NSString *title = NSLocalizedString(@"Cannot Decrypt Settings", nil);
    NSString *informativeText = NSLocalizedString(@"You either entered the wrong password or these settings were saved with an incompatible SEB version.", nil);
    [self showAlertWithTitle:title andText:informativeText];
}

- (void) showAlertCorruptedSettings {
    NSString *title = NSLocalizedString(@"Opening New Settings Failed!", nil);
    NSString *informativeText = NSLocalizedString(@"These settings cannot be used. They may have been created by an incompatible version of SEB or are corrupted.", nil);
    [self showAlertWithTitle:title andText:informativeText];
}


- (void) showAlertWithTitle:(NSString *)title andText:(NSString *)informativeText
{
    if (_sebViewController.alertController) {
        [_sebViewController.alertController dismissViewControllerAnimated:NO completion:nil];
    }
    _sebViewController.alertController = [UIAlertController  alertControllerWithTitle:title
                                                                message:informativeText
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [_sebViewController.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                                 [_sebViewController.alertController dismissViewControllerAnimated:NO completion:nil];
                                                             }]];
    
    [_sebViewController presentViewController:_sebViewController.alertController animated:YES completion:nil];
}


- (NSInteger) showAlertWithTitle:(NSString *)title text:(NSString *)informativeText cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_AVAILABLE(10_6, 4_0)
{
//    __block NSInteger pressedButtonIndex;
//    __block dispatch_semaphore_t generateNotificationsSemaphore;
//        UIAlertViewBlock *alertViewBlock = [[UIAlertViewBlock alloc] initWithTitle:title message:informativeText block:^(NSInteger buttonIndex)
//                               {
//                                   pressedButtonIndex = buttonIndex;
//                                   if (buttonIndex == alertViewBlock.cancelButtonIndex) {
//                                       NSLog(@"Cancel pressed");
//                                   }
//                                   else {
//                                       NSLog(@"Button with index %ld pressed", (long)buttonIndex);
//                                   }
//                                   
//                                   dispatch_semaphore_signal(generateNotificationsSemaphore);
//                               }
//                                                    cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
//        
//        [alertViewBlock show];
//        
//    
//    return pressedButtonIndex;
    
    return 0;
    
//    self.alertController = [UIAlertController  alertControllerWithTitle:title
//                                                                message:informativeText
//                                                         preferredStyle:UIAlertControllerStyleAlert];
//    [self.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
//                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                                                                 [self.alertController dismissViewControllerAnimated:NO completion:nil];
//                                                             }]];
//    
//    [self.sebViewController presentViewController:self.alertController animated:YES completion:nil];
}


- (BOOL) saveSettingsUnencrypted {
    __block BOOL saveSettingsUnencrypted;
    
    if (_sebViewController.alertController) {
        [_sebViewController.alertController dismissViewControllerAnimated:NO completion:nil];
    }
    _sebViewController.alertController = [UIAlertController  alertControllerWithTitle:NSLocalizedString(@"No Encryption Credentials Chosen", nil)
                                                                message:NSLocalizedString(@"You should either enter a password or choose a cryptographic identity to encrypt the SEB settings file.\n\nYou can save an unencrypted settings file, but this is not recommended for use in exams.", nil)
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [_sebViewController.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                                 [_sebViewController.alertController dismissViewControllerAnimated:NO completion:nil];

                                                                 // Post a notification to switch to the Config File prefs pane
                                                                 [[NSNotificationCenter defaultCenter]
                                                                  postNotificationName:@"switchToConfigFilePane" object:self];
                                                                 // don't save the config data
                                                                 saveSettingsUnencrypted = false;
                                                             }]];
    
    [_sebViewController.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save unencrypted", nil)
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                                 [_sebViewController.alertController dismissViewControllerAnimated:NO completion:nil];

                                                                 // save .seb config data unencrypted
                                                                 saveSettingsUnencrypted = true;
                                                             }]];
    
    [_sebViewController presentViewController:_sebViewController.alertController animated:YES completion:nil];

    return saveSettingsUnencrypted;
}


- (void) presentErrorAlert:(NSError *)error {
//    [NSApp presentError:error];
}


@end
