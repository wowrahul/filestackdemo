//
//  Transformable.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/10/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents an `Transformable` object.

    See [Image Transformations Overview](https://www.filestack.com/docs/image-transformations) for more information
    about image transformations.
 */
@objc(FSTransformable) public class Transformable: NSObject {


    // MARK: - Public Properties

    /// An API key obtained from the Developer Portal.
    public let apiKey: String

    /// A `Security` object. `nil` by default.
    public let security: Security?

    /// A Filestack Handle. `nil` by default.
    public let handle: String?

    /// An external URL. `nil` by default.
    public let externalURL: URL?

    /// An URL corresponding to this image transform.
    public var url: URL {

        return computeURL()
    }


    // MARK: - Private Properties

    private var transformationTasks: [Task] = [Task]()


    // MARK: - Lifecyle Functions

    internal init(handle: String, apiKey: String, security: Security? = nil) {

        self.handle = handle
        self.externalURL = nil
        self.apiKey = apiKey
        self.security = security

        super.init()
    }

    internal init(externalURL: URL, apiKey: String, security: Security? = nil) {

        self.handle = nil
        self.externalURL = externalURL
        self.apiKey = apiKey
        self.security = security

        super.init()
    }


    // MARK: - Public Functions

    /**
        Adds a new transformation to the transformation chain.
     
        - Parameter transform: The `Transform` to add.
     */
    @objc(add:) @discardableResult public func add(transform: Transform) -> Self {

        transformationTasks.append(transform.task)

        return self
    }

    /**
        Includes detailed information about the transformation request.
     */
    @discardableResult public func debug() -> Self {

        let task = Task(name: "debug", options: nil)

        transformationTasks.insert(task, at: 0)

        return self
    }

    /**
        Stores a copy of the transformation results to your preferred filestore.
     
        - Parameter fileName: Change or set the filename for the converted file.
        - Parameter location: An `StorageLocation` value.
        - Parameter path: Where to store the file in your designated container. For S3, this is 
            the key where the file will be stored at.
        - Parameter container: The name of the bucket or container to write files to.
        - Parameter region: S3 specific parameter. The name of the S3 region your bucket is located 
            in. All regions except for `eu-central-1` (Frankfurt), `ap-south-1` (Mumbai),
            and `ap-northeast-2` (Seoul) will work.
        - Parameter access: An `StorageAccess` value.
        - Parameter base64Decode: Specify that you want the data to be first decoded from base64 
            before being written to the file. For example, if you have base64 encoded image data, 
            you can use this flag to first decode the data before writing the image file.
        - Parameter queue: The queue on which the completion handler is dispatched.
        - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    @discardableResult public func store(fileName: String? = nil,
                                         location: StorageLocation,
                                         path: String? = nil,
                                         container: String? = nil,
                                         region: String? = nil,
                                         access: StorageAccess,
                                         base64Decode: Bool,
                                         queue: DispatchQueue? = .main,
                                         completionHandler: @escaping (FileLink?, NetworkJSONResponse) -> Void) -> Self {

        var options = [TaskOption]()

        if let fileName = fileName {
            options.append((key: "filename", value: fileName))
        }

        options.append((key: "location", value: location))

        if let path = path {
            options.append((key: "path", value: path))
        }

        if let container = container {
            options.append((key: "container", value: container))
        }

        if let region = region {
            options.append((key: "region", value: region))
        }

        options.append((key: "access", value: access))
        options.append((key: "base64decode", value: base64Decode))

        let task = Task(name: "store", options: options)

        transformationTasks.insert(task, at: 0)


        // Create and perform post request

        guard let request = processService.request(url: url, method: .post) else { return self }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseJSON(queue: queue ?? .main) { (response) in

            let jsonResponse = NetworkJSONResponse(with: response)
            var fileLink: FileLink?

            if let json = jsonResponse.json,
               let urlString = json["url"] as? String,
               let url = URL(string: urlString) {

                fileLink = FileLink(handle: url.lastPathComponent, apiKey: self.apiKey, security: self.security)
            }

            completionHandler(fileLink, jsonResponse)

            return
        }

        return self
    }


    // MARK: - Private Functions

    private func computeURL() -> URL {

        let tasks = tasksToURLFragment()

        if let handle = handle {
            return processService.buildURL(tasks: tasks, handle: handle, security: security)!
        } else {
            return processService.buildURL(tasks: tasks, externalURL: externalURL!, key: apiKey, security: security)!
        }
    }

    private func sanitize(string: String) -> String {

        let allowedCharacters = CharacterSet(charactersIn: ",").inverted

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
    }

    private func tasksToURLFragment() -> String {

        let tasks: [String] = transformationTasks.map {

            if let options = $0.options {
                let params: [String] = options.map {

                    switch $0.value {
                    case let array as [Any]:

                        return "\($0.key):[\((array.map { String(describing: $0) }).joined(separator: ","))]"

                    default:

                        if let value = $0.value as? String {
                            return "\($0.key):\(sanitize(string: value))"
                        } else if let value = $0.value {
                                return "\($0.key):\(value)"
                        } else {
                            return $0.key
                        }
                    }
                }

                if params.count > 0 {
                    return "\($0.name)=\(params.joined(separator: ","))"
                }
            }

            return $0.name
        }

        return tasks.joined(separator: "/")
    }
}
