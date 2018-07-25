//------------------------------------------------------------------------
// Project     : VST SDK
// Version     : 3.6.5
//
// Category    : Helpers
// Filename    : public.sdk/source/vst/auwrapper/ausdk.mm
// Created by  : Steinberg, 12/2007
// Description : VST 3 -> AU Wrapper
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
//----------------------------------------------------------------------------------

/// \cond ignore

#ifndef MAC_OS_X_VERSION_10_7
	#define MAC_OS_X_VERSION_10_7 1070
#endif

#import "PublicUtility/CAAudioChannelLayout.cpp"
#import "PublicUtility/CABundleLocker.cpp"
#import "PublicUtility/CAHostTimeBase.cpp"
#import "PublicUtility/CAStreamBasicDescription.cpp"
#import "PublicUtility/CAVectorUnit.cpp"
#import "PublicUtility/CAAUParameter.cpp"

#import "AUPublic/AUBase/ComponentBase.cpp"
#import "AUPublic/AUBase/AUScopeElement.cpp"
#import "AUPublic/AUBase/AUOutputElement.cpp"
#import "AUPublic/AUBase/AUInputElement.cpp"
#import "AUPublic/AUBase/AUBase.cpp"

#if !__LP64__
	#import "AUPublic/AUCarbonViewBase/AUCarbonViewBase.cpp"
	#import "AUPublic/AUCarbonViewBase/AUCarbonViewControl.cpp"
	#import "AUPublic/AUCarbonViewBase/AUCarbonViewDispatch.cpp"
	#import "AUPublic/AUCarbonViewBase/AUControlGroup.cpp"
	#import "AUPublic/AUCarbonViewBase/CarbonEventHandler.cpp"
#endif

#import "AUPublic/Utility/AUTimestampGenerator.cpp"
#import "AUPublic/Utility/AUBuffer.cpp"
#import "AUPublic/Utility/AUBaseHelper.cpp"

#if MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_7
	#import "AUPublic/OtherBases/AUMIDIEffectBase.cpp"
	#import "AUPublic/Utility/AUDebugDispatcher.cpp"
#else
	#import "AUPublic/AUBase/AUPlugInDispatch.cpp"
#endif

#if !CA_USE_AUDIO_PLUGIN_ONLY
	#import "AUPublic/AUBase/AUDispatch.cpp"
	#import "AUPublic/OtherBases/MusicDeviceBase.cpp"
	#import "AUPublic/OtherBases/AUMIDIBase.cpp"
	#import "AUPublic/OtherBases/AUEffectBase.cpp"
#endif

/// \endcond
