[![Code Climate][code_climate_badge]][code_climate]

# Filestack Swift SDK
<a href="https://www.filestack.com"><img src="https://filestack.com/themes/filestack/assets/images/press-articles/color.svg" align="left" hspace="10" vspace="6"></a>
This is the official Swift SDK for Filestack - API and content management system that makes it easy to add powerful file uploading and transformation capabilities to any web or mobile application.

## Resources

* [Filestack](https://www.filestack.com)
* [Documentation](https://www.filestack.com/docs)
* [API Reference](https://filestack.github.io/filestack-swift/)

## Installing

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects. You can install it with the following command:

`$ gem install cocoapods`

To integrate FilestackSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'FilestackSDK', '~> 1.1'
end
```

Then, run the following command:

`$ pod install`

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```
$ brew update
$ brew install carthage
```

To integrate FilestackSDK into your Xcode project using Carthage, specify it in your `Cartfile`:

`github "filestack/filestack-swift" ~> 1.1`

Run `carthage update` to build the framework and drag the built `FilestackSDK.framework` into your Xcode project. Additionally, add `FilestackSDK.framework`, `Alamofire.framework` and `CryptoSwift.framework` to the embedded frameworks build phase of your app's target.

### Manually

#### Embedded Framework

Open up Terminal, cd into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

`$ git init`

Add FilestackSDK and its dependencies as git submodules by running the following commands:

```shell
$ git submodule add https://github.com/filestack/filestack-swift.git
$ git submodule add https://github.com/Alamofire/Alamofire.git
$ git submodule add https://github.com/krzyzanowskim/CryptoSwift.git
```

Open the new `filestack-swift` folder, and drag the `FilestackSDK.xcodeproj` into the Project Navigator of your application's Xcode project.

It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.
Select the `FilestackSDK.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.

Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.

In the tab bar at the top of that window, open the "General" panel.

Click on the + button under the "Embedded Binaries" section and choose the `FilestackSDK.framework` for iOS.

Repeat the same process for adding `Alamofire` and `CryptoSwift` dependent frameworks.

## Usage

### Integration into a Swift project

1. Import the framework into your code:

    ```swift
    import FilestackSDK
    ```

2. Instantiate a `Client` object by providing your API key and, optionally, a `Security` object:

    ```swift
    // Initialize a `Policy` with the expiry time and permissions you need.
    let oneDayInSeconds: TimeInterval = 60 * 60 * 24 // expires tomorrow
    let policy = Policy(// Set your expiry time (24 hours in our case)
                        expiry: Date(timeIntervalSinceNow: oneDayInSeconds),
                        // Set the permissions you want your policy to have
                        call: [.pick, .read, .store])

    // Initialize a `Security` object by providing a `Policy` object and your app secret.
    // You can find and/or enable your app secret in the Developer Portal.
    guard let security = try? Security(policy: policy, appSecret: "YOUR-APP-SECRET") else {
        return
    }

    // Initialize your `Client` object by passing a valid API key, and security options.
    let client = Client(apiKey: "YOUR-API-KEY", security: security)
    ```

### Integration into an Objective-C project

1. Import the framework into your code:

    ```objective-c
    @import FilestackSDK;
    ```

2. Instantiate a `FSClient` object by providing your API key and, optionally, a `FSSecurity` object:

    ```objective-c
    // Initialize a `FSPolicy` object with the expiry time and permissions you need.
    NSTimeInterval oneDayInSeconds = 60 * 60 * 24; // expires tomorrow
    NSDate *expiryDate = [[NSDate alloc] initWithTimeIntervalSinceNow:oneDayInSeconds];
    FSPolicyCall permissions = FSPolicyCallPick | FSPolicyCallRead | FSPolicyCallStore;

    FSPolicy *policy = [[FSPolicy alloc] initWithExpiry:expiryDate
                                                   call:permissions];

    NSError *error;

    // Initialize a `Security` object by providing a `FSPolicy` object and your app secret.
    // You can find and/or enable your app secret in the Developer Portal.
    FSSecurity *security = [[FSSecurity alloc] initWithPolicy:policy
                                                    appSecret:@"YOUR-APP-SECRET"
                                                        error:&error];

    if (error != nil) {
        NSLog(@"Error instantiating policy object: %@", error.localizedDescription);
        return;
    }

    // Initialize your `Client` object by passing a valid API key, and security options.
    FSClient *client = [[FSClient alloc] initWithApiKey:@"YOUR-API-KEY"
                                               security:security];
    ```

For more information, please consult our [API Reference](https://filestack.github.io/filestack-swift/).

### Uploading files directly to a storage location

Both regular and Intelligent Ingestion uploads use the same API function available in the `Client` class. However, if your account has Intelligent Ingestion support enabled and you prefer using the regular uploading mechanism, you could disable it by setting the `useIntelligentIngestionIfAvailable` argument to `false` (see the relevant examples below.)

#### Swift Example

```swift
// Initialize a `Policy` with the expiry time and permissions you need.
let oneDayInSeconds: TimeInterval = 60 * 60 * 24 // expires tomorrow
let policy = Policy(// Set your expiry time (24 hours in our case)
                    expiry: Date(timeIntervalSinceNow: oneDayInSeconds),
                    // Set the permissions you want your policy to have
                    call: [.pick, .read, .store])

// Initialize a `Security` object by providing a `Policy` object and your app secret.
// You can find and/or enable your app secret in the Developer Portal.
guard let security = try? Security(policy: policy, appSecret: "YOUR-APP-SECRET") else {
    return
}

// Get an URL pointing to the local file you would like to upload.
guard let localURL = Bundle.main.url(forResource: "YOUR-IMAGE", withExtension: "jpg") else {
    return
}

// Initialize your `Client` object by passing a valid API key, and security options.
let client = Client(apiKey: "YOUR-API-KEY", security: security)

let uploadProgress: (Progress) -> Void = { progress in
    // Here you may update the UI to reflect the upload progress.
	print("Progress: \(progress)")
}

// Store options
let storeOptions: StorageOptions = StorageOptions(// Store location (e.g. S3, Dropbox, Rackspace, Azure, Google Cloud Storage)
                                                  location: .s3,
                                                  // AWS Region for S3 (e.g. "us-east-1", "eu-west-1", "ap-northeast-1", etc.)
                                                  region: "us-east-1",
                                                  // The name of your S3 bucket
                                                  container: "YOUR-S3-BUCKET",
                                                  // Destination path in the store.
                                                  // You may use a path to a folder (e.g. /public/) or,
                                                  // alternatively a path containing a filename (e.g. /public/oncorhynchus.jpg).
                                                  // When using a path to a folder, the uploaded file will be stored at that folder using a
                                                  // filename derived from the original filename.
                                                  // When using a path to a filename, the uploaded file will be stored at the given path
                                                  // using the filename indicated in the path.
                                                  path: "/public/oncorhynchus.jpg",
                                                  // Access permissions (either public or private)
                                                  access: .public)

// Call the function in your `Client` instance that takes care of file uploading.
// Please notice that some of the parameters are optional and have default values.
let multiPartUpload = client.multiPartUpload(// Set the URL pointing to the local file you want to upload.
                                             from: localURL,
                                             // Set the destination storage location here.
                                             // If none given, S3 location with default options is assumed.
                                             storeOptions: storeOptions,
                                             // Set to `false` if you don't want to use
                                             // Intelligent Ingestion regardless of whether it is available
                                             // for you.
                                             useIntelligentIngestionIfAvailable: true,
                                             // Set the dispatch queue where you want your upload progress
                                             // and completion handlers to be called.
                                             // Remember that any UI updates should be performed on the
                                             // main queue.
                                             // You can omit this parameter, and the main queue will be
                                             // used by default.
                                             queue: .main,
                                             // Set your upload progress handler here (optional)
                                             uploadProgress: uploadProgress) { response in
    // Try to obtain Filestack handle
    if let json = response?.json, let handle = json["handle"] as? String {
        // Use Filestack handle
    } else if let error = response?.error {
        // Handle error
    }
}

// Cancelling ongoing multipart upload.
multipartUpload.cancel()
```

#### Objective-C Example

```objective-c
// Initialize a `FSPolicy` object with the expiry time and permissions you need.
NSTimeInterval oneDayInSeconds = 60 * 60 * 24; // expires tomorrow
NSDate *expiryDate = [[NSDate alloc] initWithTimeIntervalSinceNow:oneDayInSeconds];
FSPolicyCall permissions = FSPolicyCallPick | FSPolicyCallRead | FSPolicyCallStore;

FSPolicy *policy = [[FSPolicy alloc] initWithExpiry:expiryDate
                                               call:permissions];

NSError *error;

// Initialize a `Security` object by providing a `FSPolicy` object and your app secret.
// You can find and/or enable your app secret in the Developer Portal.
FSSecurity *security = [[FSSecurity alloc] initWithPolicy:policy
                                                appSecret:@"YOUR-APP-SECRET"
                                                    error:&error];

if (error != nil) {
    NSLog(@"Error instantiating policy object: %@", error.localizedDescription);
    return;
}

// Get an URL pointing to the local file you would like to upload.
NSURL *localURL = [[NSBundle mainBundle] URLForResource:@"YOUR-IMAGE"
                                          withExtension:@"jpg"];

// Initialize your `FSClient` object by passing a valid API key, and security options.
FSClient *client = [[FSClient alloc] initWithApiKey:@"YOUR-API-KEY"
                                           security:security];


void (^uploadProgress)(NSProgress *) = ^(NSProgress *progress) {
    // Here you may update the UI to reflect the upload progress.
    NSLog(@"Progress: %@", progress);
};

// Store options, initialized with a storage location (e.g. S3, Dropbox, Rackspace, Azure, Google Cloud Storage)
FSStorageOptions *storeOptions = [[FSStorageOptions alloc] initWithLocation:FSStorageLocationS3];
// AWS Region for S3 (e.g. "us-east-1", "eu-west-1", "ap-northeast-1", etc.)
storeOptions.region = @"us-east-1";
// The name of your S3 bucket
storeOptions.container = @"YOUR-S3-BUCKET";
// Destination path in the store.
// You may use a path to a folder (e.g. /public/) or,
// alternatively a path containing a filename (e.g. /public/oncorhynchus.jpg).
// When using a path to a folder, the uploaded file will be stored at that folder using a
// filename derived from the original filename.
// When using a path to a filename, the uploaded file will be stored at the given path
// using the filename indicated in the path.
storeOptions.path = @"/public/oncorhynchus.jpg";
// Access permissions (either public or private)
storeOptions.access = FSStorageAccessPublic;

// Call the function in your `FSClient` instance that takes care of file uploading.
// Please notice that some of the parameters are optional and have default values.
MultipartUpload *multipartUpload = [client multiPartUploadFrom:localURL
                                                  storeOptions: storeOptions,
                            useIntelligentIngestionIfAvailable:YES
                                                         queue:dispatch_get_main_queue()
                                                uploadProgress:uploadProgress
             completionHandler:^(FSNetworkJSONResponse * _Nullable response) {
                 NSDictionary *jsonResponse = response.json;
                 NSString *handle = jsonResponse[@"handle"];
                 NSError *error = response.error;

                 if (handle) {
                     // Use Filestack handle
                     NSLog(@"Handle is: %@", handle);
                 } else if (error) {
                     // Handle error
                     NSLog(@"Error is: %@", error);
                 }
             }
];

// Cancelling ongoing multipart upload.
[multipartUpload cancel];
```

## Versioning

Filestack Swift SDK follows the [Semantic Versioning](http://semver.org/).

## Issues

If you have problems, please create a [Github Issue](https://github.com/filestack/filestack-swift/issues).

## Contributing

Please see [CONTRIBUTING.md](https://github.com/filestack/filestack-swift/blob/master/CONTRIBUTING.md) for details.

## Credits

Thank you to all the [contributors](https://github.com/filestack/filestack-swift/graphs/contributors).

[code_climate]: https://codeclimate.com/github/filestack/filestack-swift
[code_climate_badge]: https://codeclimate.com/github/filestack/filestack-swift.png
