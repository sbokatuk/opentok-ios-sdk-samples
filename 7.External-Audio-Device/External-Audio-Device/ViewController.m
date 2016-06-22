//
//  ViewController.m
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import "ViewController.h"
#import <OpenTok/OpenTok.h>
#import "OTDefaultAudioDevice.h"

@interface ViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>

@end

BOOL isMuted;
BOOL isPublisher2 = FALSE;

@implementation ViewController {
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    OTDefaultAudioDevice* _myAudioDevice;
}
static double widgetHeight = 200;
static double widgetWidth = 300;

// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"45610182";
// Replace with your generated session ID
static NSString* const kSessionId = @"1_MX40NTYxMDE4Mn5-MTQ2NjUwNzc3ODE1MH5sbHZvSklxdGFHNDB1bFk5Rm42YnMxM2R-fg";
// Replace with your generated token
static NSString* const kToken = @"T1==cGFydG5lcl9pZD00NTYxMDE4MiZzaWc9NDlhZjRiMTNmOGIyM2M5OWYxN2JmMTkyMmJmYjdjY2VmZWRlNTgxMTpzZXNzaW9uX2lkPTFfTVg0ME5UWXhNREU0TW41LU1UUTJOalV3TnpjM09ERTFNSDVzYkhadlNrbHhkR0ZITkRCMWJGazVSbTQyWW5NeE0yUi1mZyZjcmVhdGVfdGltZT0xNDY2NTA3ODQzJm5vbmNlPTAuNTg5ODIxOTQxNjg0OTMxNSZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNDY5MDk5ODQz";
static NSString* const kToken2 = @"T1==cGFydG5lcl9pZD00NTYxMDE4MiZzaWc9M2Q3YWI5ZTUwNjMyY2IyNTI3OGRkZTQ3MjAwOGE3YTg0ZGYzYTAwYjpzZXNzaW9uX2lkPTFfTVg0ME5UWXhNREU0TW41LU1UUTJOalV3TnpjM09ERTFNSDVzYkhadlNrbHhkR0ZITkRCMWJGazVSbTQyWW5NeE0yUi1mZyZjcmVhdGVfdGltZT0xNDY2NTE0NzU3Jm5vbmNlPTAuMjEwMTI4ODA5NTU4MjI3NjYmcm9sZT1wdWJsaXNoZXImZXhwaXJlX3RpbWU9MTQ2OTEwNjc1Ng==";

// Change to NO to subscribe to streams other than your own.
static bool subscribeToSelf = NO;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    //_myAudioDevice = [[OTDefaultAudioDevice alloc] init];
    //[OTAudioDeviceManager setAudioDevice:_myAudioDevice];
    
    // Step 1: As the view comes into the foreground, initialize a new instance
    // of OTSession and begin the connection process.
    
    
    UIButton *but= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [but addTarget:self action:@selector(speakerClicked:) forControlEvents:UIControlEventTouchUpInside];
    [but setFrame:CGRectMake(1, 431, 110, 20)];
    [but setTitle:@"Toggle Speaker" forState:UIControlStateNormal];
    [but setExclusiveTouch:YES];
    [self.view addSubview:but];
    
    UIButton *but2= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [but2 addTarget:self action:@selector(micClicked:) forControlEvents:UIControlEventTouchUpInside];
    [but2 setFrame:CGRectMake(110, 431, 100, 20)];
    [but2 setTitle:@"Toggle Mic" forState:UIControlStateNormal];
    [but2 setExclusiveTouch:YES];
    [self.view addSubview:but2];
    
    UIButton *pub1= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pub1 addTarget:self action:@selector(publisher1Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [pub1 setFrame:CGRectMake(1, 21, 100, 20)];
    [pub1 setTitle:@"Publisher 1" forState:UIControlStateNormal];
    [pub1 setExclusiveTouch:YES];
    [self.view addSubview:pub1];
    
    UIButton *pub2= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pub2 addTarget:self action:@selector(publisher2Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [pub2 setFrame:CGRectMake(100, 21, 100, 20)];
    [pub2 setTitle:@"Publisher 2" forState:UIControlStateNormal];
    [pub2 setExclusiveTouch:YES];
    [self.view addSubview:pub2];
    
    
    isMuted = FALSE;

}

-(void) micClicked:(UIButton*)sender
{
    NSLog(@"you clicked on button Toggle Mic");
    
    isMuted = !isMuted;
    _publisher.publishAudio = !isMuted;
}

-(void) speakerClicked:(UIButton*)sender
{
    NSLog(@"you clicked on button Toggle Speaker");
    
    [_myAudioDevice switchAudio];
}

-(void) publisher1Clicked:(UIButton*)sender
{
    NSLog(@"you clicked on button Publisher 1");
    isPublisher2 = FALSE;
    [self doCreateSession];
    [self doConnect];
}

-(void) publisher2Clicked:(UIButton*)sender
{
    NSLog(@"you clicked on button Publisher 2");
    isPublisher2 = true;
    [self doCreateSession];
    [self doConnect];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice]
                                      userInterfaceIdiom])
    {
        return NO;
    } else {
        return YES;
    }
}
#pragma mark - OpenTok methods

/**
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect
{
    OTError *error = nil;
    if(isPublisher2)
    {
        [_session connectWithToken:kToken2 error:&error];
    }
    else
    {
        [_session connectWithToken:kToken error:&error];
    }
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

- (void)doCreateSession
{
    _session = [[OTSession alloc] initWithApiKey:kApiKey
                                       sessionId:kSessionId
                                        delegate:self];
}

/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{
    _publisher =
    [[OTPublisher alloc] initWithDelegate:self
                                     name:[[UIDevice currentDevice] name]];
    
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    
    [self.view addSubview:_publisher.view];
    [_publisher.view setFrame:CGRectMake(0, 0, widgetWidth, widgetHeight)];
}

/**
 * Cleans up the publisher and its view. At this point, the publisher should not
 * be attached to the session any more.
 */
- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}

/**
 * Instantiates a subscriber for the given stream and asynchronously begins the
 * process to begin receiving A/V content for this stream. Unlike doPublish,
 * this method does not add the subscriber to the view hierarchy. Instead, we
 * add the subscriber only after it has connected and begins receiving data.
 */
- (void)doSubscribe:(OTStream*)stream
{
    _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    
    OTError *error = nil;
    [_session subscribe:_subscriber error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Cleans the subscriber from the view hierarchy, if any.
 * NB: You do *not* have to call unsubscribe in your controller in response to
 * a streamDestroyed event. Any subscribers (or the publisher) for a stream will
 * be automatically removed from the session during cleanup of the stream.
 */
- (void)cleanupSubscriber
{
    [_subscriber.view removeFromSuperview];
    _subscriber = nil;
}

# pragma mark - OTSession delegate callbacks

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    
    // Step 2: We have successfully connected, now instantiate a publisher and
    // begin pushing A/V streams into OpenTok.
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
}


- (void)session:(OTSession*)mySession
  streamCreated:(OTStream *)stream
{
    NSLog(@"session streamCreated (%@)", stream.streamId);
    
    // Step 3a: (if NO == subscribeToSelf): Begin subscribing to a stream we
    // have seen on the OpenTok session.
    if (nil == _subscriber && !subscribeToSelf)
    {
        [self doSubscribe:stream];
    }
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream *)stream
{
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
}

- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
}

- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
    if ([_subscriber.stream.connection.connectionId
         isEqualToString:connection.connectionId])
    {
        [self cleanupSubscriber];
    }
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
}

# pragma mark - OTSubscriber delegate callbacks

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
    assert(_subscriber == subscriber);
    [_subscriber.view setFrame:CGRectMake(0, widgetHeight, widgetWidth,
                                          widgetHeight)];
    [self.view addSubview:_subscriber.view];
}

- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}

- (void)subscriberDidDisconnectFromStream:(OTSubscriberKit *)subscriber
{
    NSLog(@"subscriberDidDisconnectFromStream %@", subscriber);
    [self cleanupSubscriber];
}

# pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
{
    NSLog(@"publisher %@ streamCreated %@", publisher, stream);
    // Step 3b: (if YES == subscribeToSelf): Our own publisher is now visible to
    // all participants in the OpenTok session. We will attempt to subscribe to
    // our own stream. Expect to see a slight delay in the subscriber video and
    // an echo of the audio coming from the device microphone.
    if (nil == _subscriber && subscribeToSelf)
    {
        [self doSubscribe:stream];
    }
    
}

- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
    NSLog(@"publisher %@ streamDestroyed %@", publisher, stream);
    
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
    
    [self cleanupPublisher];
}

- (void)publisher:(OTPublisherKit*)publisher
 didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
}

- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
	dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OTError"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] ;
        [alert show];
    });
}

@end
