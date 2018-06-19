//
//  ViewController.swift
//  fileStackDemo
//
//  Created by Rahul Joshi on 6/18/18.
//  Copyright © 2018 Fieldwire. All rights reserved.
//

import UIKit
import Filestack
import FilestackSDK

struct Constants {
    static let APIKey = "APIKEY"
    static let AppURLScheme = "fielstackdemo"
    static let S3Bucket = "S3Key"
    static let S3ObjectKey = "S3ObjectKey"
}

class ViewController: UIViewController {
    @IBOutlet weak var addFile: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showFilePicker() {
        let config = Filestack.Config()
        config.appURLScheme = Constants.AppURLScheme
        config.availableCloudSources = [CloudSource.box, CloudSource.dropbox, CloudSource.googleDrive]
        config.availableLocalSources = [.documents]
        config.documentPickerAllowedUTIs = ["public.item"]
        
        
        let client = Client(apiKey: Constants.APIKey, security: nil, config: config)
        let storeOptions = StorageOptions.init(location: StorageLocation.s3,
                                               region: "us-east-1",
                                               container: Constants.S3Bucket,
                                               path: Constants.S3ObjectKey + UUID.init().uuidString,
                                               filename: nil,
                                               access: StorageAccess.public)
        
        let picker = client.picker(storeOptions: storeOptions)
        picker.pickerDelegate = self
        picker.modalPresentationStyle = UIModalPresentationStyle.popover
    
        
        picker.popoverPresentationController?.sourceView = view
        picker.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        present(picker,
                animated: true,
                completion: nil)
    }
}

extension ViewController: PickerNavigationControllerDelegate {
    
    func pickerStoredFile(picker: PickerNavigationController, response: StoreResponse) {
        
        if let contents = response.contents {
            // Our cloud file was stored into the destination location.
            print("Stored file response: \(contents)")
        } else if let error = response.error {
            // The store operation failed.
            print("Error storing file: \(error)")
        }
    }
    
    func pickerUploadedFile(picker: PickerNavigationController, response: NetworkJSONResponse?) {
        
        if let contents = response?.json {
            // Our local file was stored into the destination location.
            print("Uploaded file response: \(contents)")
        } else if let error = response?.error {
            // The upload operation failed.
            print("Error uploading file: \(error)")
        }
    }
}

