#iOS Helpers Framework

[![Build Status](https://travis-ci.org/ilk33r/IO-IOS-Helpers.svg?branch=master)](https://travis-ci.org/ilk33r/IO-IOS-Helpers)


###Common Functions

#####**IO_Helpers Class**

* *Static* bundleID -> *String*
* *Static* iOS10 -> *Bool*
* *Static* iOS9 -> *Bool*
* *Static* iOS8 -> *Bool*
* *Static* iOS7 -> *Bool*
* *Static* deviceUUID -> *String*
* *Static* applicationName -> *String*
* *Static* applicationVersion -> *String*
* *Static* deviceName -> *String*
* *Static* devicModel -> *String*
* *Static* deviceVersion -> *String*
* *Static* getErrorMessageFromCode(errorCode : Int) -> *(String?, String?, String?)*
* *Static* getMediaCacheDirectory -> *String?*
* *Static* getResolution() -> *(CGFloat, CGFloat)*
* *Static* generateRandomAlphanumeric(characterCount: Int) -> *String*
* *Static* randomInt(min: Int, max:Int) -> *Int*
* *Static* mathDegrees(radians : Double) -> *Double*
* *Static* mathRadians(degrees : Double) -> *Double*
* *Static* convertMilesToKilemoters(miles : Double) -> *Double*
* *Static* getSettingValue(settingKey: String) -> *String *


#####**String Extension**

* IO_isEmail() -> *Bool*
* IO_md5() -> *String*
* IO_condenseWhitespace() -> *String*


#####**UIViewController Extension**

* IO_presentViewControllerWithCustomAnimation(viewControllerToPresent: UIViewController!)
* IO_dismissViewControllerWithCustomAnimation()


#####**IO_Json Class**

* *Static* JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> *String*
* *Static* JSONParseArray(jsonString: String) -> *[AnyObject]*
* *Static* JSONParseDictionary(jsonString: String) -> *[String: AnyObject]*


#####**IO_Encryption Class**

* plainText -> *String!*
* encryptedText -> *String!*
* init(plainText: String!)
* init(encryptedText: String!)


#####**IO_DateTime Class**

* init(initWithNsDate date : NSDate!)
* init(initWithString date: String!)
* getDate() -> *NSDate!*
* getDateString() -> *String!*
* *Static* getCurrentGMTDate() -> *NSDate*
* getTimeAgoString() -> *String!*
* getUnixTimeStamp() -> *Int*


#####**IO_StreamReader File Reader Class**

* init? (pathUrl: NSURL!, chunkSize: UInt64 = 4096)
* getChunkData() -> *NSData?*
* rewind() -> *Void*
* close()


#####**IO_MediaCachingResponseHandler Type**

* (success : Bool, image : UIImage!) -> *Void*

#####**IO_MediaCaching Class**

* init(getMediaImage fileUrl : String!, completionHandler : IO_MediaCachingResponseHandler)
* *Static* convertUrlToFileName(fileUrl: String) -> *String*
* *Static* mediaExists(fileName : String) -> *Bool*
* *Static* getMediaImageForBase64Encoded(fileName : String) -> *String!*
* *Static* saveFileToCache(fileName: String!, fileContent: NSData!)
* *Static* removeFileFromCache(fileName: String!)
* *Static* clearCache(timeInterval: NSTimeInterval = -604800)


#####**IO_ServerSyncResponseHandler Type**

* (success : Bool, code : Int, data : String!, serverObject: AnyObject!) -> *Void*

#####**IO_HttpHeader Type**

* init(headerName: String, headerValue: String)

#####**IO_Reachability Class**

* *Static* isConnectedToNetwork() -> *Bool*

#####**IO_ServerSync Class**

* *Enum* RequestMethods -> *String*
* init(jsonRequest requestUrl : String, parameters : Dictionary<String, AnyObject>, method: RequestMethods, completitionHandler : IO_ServerSyncResponseHandler)
* init(jsonRequestWithHeaders requestUrl : String, parameters : Dictionary<String, AnyObject>, method: RequestMethods, headers: [IO_HttpHeader], completitionHandler : IO_ServerSyncResponseHandler)
* init (multipartFormDataRequest requestUrl : String, parameters : Dictionary<String, AnyObject>, completitionHandler : IO_ServerSyncResponseHandler)
* init (multipartFormDataRequestWithHeaders requestUrl : String, parameters : Dictionary<String, AnyObject>, headers: [IO_HttpHeader], completitionHandler : IO_ServerSyncResponseHandler)
* init(standartRequest requestUrl: String, requestBody: String!, method: RequestMethods, headers: [IO_HttpHeader]!, completitionHandler : IO_ServerSyncResponseHandler)


#####**IO_TimerResponseHandler Type**

* (elapsedSteps: Int) -> *Void*

#####**IO_Timer Class**

* init(withTimeInterval timerInterval: NSTimeInterval, completitionHandler: IO_TimerResponseHandler!)
* StopTimer()
* Update()

#####**IO_KeyboardListenerDelegate Type**

* IO_KeyboardListener(keyboardDidOpen keyboardHeight: CGFloat)
* IO_KeyboardListenerKeyboardWillDismiss()

#####**IO_KeyboardListener Class**

* init(withDelegate delegate: IO_KeyboardListenerDelegate!)


##iOS Core Data Helpers Framework

#####**IO_DataManagement Class**

* init(databaseName: String, databaseResourceName: String)
* SharedInstance: *IO_DataManagement*
* managedObjectModel: *NSManagedObjectModel*
* managedObjectContext: *NSManagedObjectContext?*
* saveContext()
* deleteSql()


##iOS Menu Framework

#####**IO_NavigationControllerWithMenu (UINavigationController) Class**

* leftMenuOpenPosX: *CGFloat!*
* isMenuViewLoaded: *Bool*
* leftMenuOpenStatus: *Bool*
* loadLeftMenu(rowCount: Int, rowHeight: CGFloat = 54, directionIsRight: Bool = false, gestureSensitive: CGFloat = 30)
* IO_LeftMenuToggle()
* closeLeftMenuImmediately()
* IO_LeftMenu(setMenuPosition currentFrameXDiff: CGFloat)
* *Required* IO_LeftMenu(clickeMenudButton sender: UIButton!)


#####**IO_LeftMenuView (UIView) Class**

* *@IBOutlet* menuTableView: UITableView!

- **View Nib Name:** IO_LeftMenuView
- **Cell buttons nib name:*** leftMenuBtn-1, leftMenuBtn-2, leftMenuBtn-3


#####**IO_LeftMenuTableViewCell (UITableViewCell) Class**

* *@IBOutlet* cellButton: UIButton!







