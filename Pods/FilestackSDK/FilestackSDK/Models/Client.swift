//
//  Client.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a client that allows communicating with the 
    [Filestack REST API](https://www.filestack.com/docs/rest-api).
 */
@objc(FSClient) public class Client: NSObject {


    // MARK: - Properties

    /// An API key obtained from the [Developer Portal](http://dev.filestack.com).
    public let apiKey: String

    /// A `Security` object. `nil` by default.
    public let security: Security?

    /// A `StorageLocation` object. `nil` by default.
    public let storage: StorageLocation?


    // MARK: - Lifecyle Functions

    /**
        Default initializer.

        - SeeAlso: `Security`

        - Parameter apiKey: An API key obtained from the Developer Portal.
        - Parameter security: A `Security` object. `nil` by default.
     */
    @objc public init(apiKey: String, security: Security? = nil) {

        self.apiKey = apiKey
        self.security = security
        self.storage = nil

        super.init()
    }

    /**
         Initializer with security and storage location.

         - SeeAlso: `Security`

         - Parameter apiKey: An API key obtained from the Developer Portal.
         - Parameter security: A `Security` object. `nil` by default.
         - Parameter storage: A `StorageLocation` object.
     */
    @objc public init(apiKey: String, security: Security? = nil, storage: StorageLocation) {

        self.apiKey = apiKey
        self.security = security
        self.storage = storage

        super.init()
    }

    // MARK: - Public Functions

    /**
        A `FileLink` object for a given Filestack handle.

        - Parameter handle: A Filestack handle.
     */
    public func fileLink(`for` handle: String) -> FileLink {

        return FileLink(handle: handle, apiKey: apiKey, security: security)
    }

    /**
        An `Transformable` object for a Filestack handle.

        - SeeAlso: `Transformable`

        - Parameter handle: A Filestack handle.
     */
    public func transformable(handle: String) -> Transformable {

        return Transformable(handle: handle, apiKey: apiKey, security: security)
    }

    /**
        An `Transformable` object for an external URL.
     
        - SeeAlso: `Transformable`

        - Parameter externalURL: An external URL.
     */
    public func transformable(externalURL: URL) -> Transformable {

        return Transformable(externalURL: externalURL, apiKey: apiKey, security: security)
    }

    /**
        Uploads a file directly to a given storage location (currently only S3 is supported.)

        - Parameter localURL: The URL of the local file to be uploaded.
        - Parameter storeOptions: An object containing the store options (e.g. location, region, container, access, etc.)
            If none given, S3 location with default options is assumed.
        - Parameter useIntelligentIngestionIfAvailable: Attempts to use Intelligent Ingestion
            for file uploading. Defaults to `true`.
        - Parameter queue: The queue on which the upload progress and completion handlers are 
            dispatched.
        - Parameter startUploadImmediately: Whether the upload should start immediately. Defaults to true.
        - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
            of the upload process as data is uploaded to the server. `nil` by default.
        - Parameter completionHandler: Adds a handler to be called once the upload has finished.
     */
    @discardableResult public func multiPartUpload(from localURL: URL? = nil,
                                                   storeOptions: StorageOptions = StorageOptions(location: .s3),
                                                   useIntelligentIngestionIfAvailable: Bool = true,
                                                   queue: DispatchQueue = .main,
                                                   startUploadImmediately: Bool = true,
                                                   uploadProgress: ((Progress) -> Void)? = nil,
                                                   completionHandler: @escaping (NetworkJSONResponse?) -> Void) -> MultipartUpload {

        let mpu = MultipartUpload(at: localURL,
                                  queue: queue,
                                  uploadProgress: uploadProgress,
                                  completionHandler: completionHandler,
                                  partUploadConcurrency: 5,
                                  chunkUploadConcurrency: 8,
                                  apiKey: apiKey,
                                  storeOptions: storeOptions,
                                  security: security,
                                  useIntelligentIngestionIfAvailable: useIntelligentIngestionIfAvailable)

        if startUploadImmediately {
            mpu.uploadFile()
        }

        return mpu
    }
}


public extension Client {

    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    override var description: String {

        var components: [String] = []

        components.append("\(super.description)(")
        components.append("    apiKey: \(apiKey),")

        if let security = security {
            components.append("    security: \(attachedDescription(object: security))")
        }

        if let storage = storage {
            components.append("    storage: \(String(describing: storage))")
        }

        components.append(")")

        return components.joined(separator: "\n")
    }
}

