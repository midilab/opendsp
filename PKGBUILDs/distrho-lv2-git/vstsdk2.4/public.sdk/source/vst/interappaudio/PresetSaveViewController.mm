//-----------------------------------------------------------------------------
// Project     : VST SDK
// Version     : 3.6.5
//
// Category    : Helpers
// Filename    : public.sdk/source/vst/interappaudio/PresetSaveViewController.mm
// Created by  : Steinberg, 09/2013
// Description : VST 3 InterAppAudio
//
//-----------------------------------------------------------------------------
// LICENSE
// (c) 2015, Steinberg Media Technologies GmbH, All Rights Reserved
//-----------------------------------------------------------------------------
// This Software Development Kit may not be distributed in parts or its entirety
// without prior written agreement by Steinberg Media Technologies GmbH.
// This SDK must not be used to re-engineer or manipulate any technology used
// in any Steinberg or Third-party application or software module,
// unless permitted by law.
// Neither the name of the Steinberg Media Technologies nor the names of its
// contributors may be used to endorse or promote products derived from this
// software without specific prior written permission.
//
// THIS SDK IS PROVIDED BY STEINBERG MEDIA TECHNOLOGIES GMBH "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL STEINBERG MEDIA TECHNOLOGIES GMBH BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
// OF THE POSSIBILITY OF SUCH DAMAGE.
//-----------------------------------------------------------------------------

#import "PresetSaveViewController.h"
#import "pluginterfaces/base/funknown.h"

static NSTimeInterval kAnimationTime = 0.2;

//------------------------------------------------------------------------
@interface PresetSaveViewController ()
//------------------------------------------------------------------------
{
	IBOutlet UIView* containerView;
	IBOutlet UITextField* presetName;

	std::function<void (const char* presetPath)> callback;
	Steinberg::FUID uid;
}
@end

//------------------------------------------------------------------------
@implementation PresetSaveViewController
//------------------------------------------------------------------------

//------------------------------------------------------------------------
- (id)initWithCallback:(std::function<void (const char* presetPath)>)_callback
{
    self = [super initWithNibName:@"PresetSaveView" bundle:nil];
    if (self)
	{
		callback = _callback;

		self.view.alpha = 0.;
		
		UIViewController* rootViewController = [[UIApplication sharedApplication].windows[0] rootViewController];
		[rootViewController addChildViewController:self];
		[rootViewController.view addSubview:self.view];
		
		[UIView animateWithDuration:kAnimationTime animations:^{
			self.view.alpha = 1.;
		}  completion:^(BOOL finished) {
			[self showKeyboard];
		}];
    }
    return self;
}

//------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

	containerView.layer.shadowOpacity = 0.5;
	containerView.layer.shadowOffset = CGSizeMake (5, 5);
	containerView.layer.shadowRadius = 5;
}

//------------------------------------------------------------------------
- (void)showKeyboard
{
	[presetName becomeFirstResponder];
}

//------------------------------------------------------------------------
- (void)removeSelf
{
	[UIView animateWithDuration:kAnimationTime animations:^{
		self.view.alpha = 0.;
	} completion:^(BOOL finished) {
		[self.view removeFromSuperview];
		[self removeFromParentViewController];
	}];
}

//------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != alertView.cancelButtonIndex)
	{
		callback ([[[self presetURL] path] UTF8String]);
		[self removeSelf];
	}
}

//------------------------------------------------------------------------
- (NSURL*)presetURL
{
	NSFileManager* fs = [NSFileManager defaultManager];
	NSURL* documentsUrl = [fs URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:Nil create:YES error:NULL];
	if (documentsUrl)
	{
		NSURL* presetPath = [[documentsUrl URLByAppendingPathComponent:presetName.text] URLByAppendingPathExtension:@"vstpreset"];
		return presetPath;
	}
	return nil;
}

//------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField.text length] > 0)
	{
		[self save:textField];
		return YES;
	}
	return NO;
}

//------------------------------------------------------------------------
- (IBAction)save:(id)sender
{
	if (callback)
	{
		NSURL* presetPath = [self presetURL];
		NSFileManager* fs = [NSFileManager defaultManager];
		if ([fs fileExistsAtPath:[presetPath path]])
		{
			// alert for overwrite
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"A Preset with this name already exists" message:@"Save it anyway ?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
			[alert show];
			return;
		}
		callback ([[presetPath path] UTF8String]);
	}
	[self removeSelf];
}

//------------------------------------------------------------------------
- (IBAction)cancel:(id)sender
{
	if (callback)
	{
		callback (0);
	}
	[self removeSelf];
}

@end
