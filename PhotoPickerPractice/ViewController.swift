//
//  ViewController.swift
//  PhotoPickerPractice
//
//  Created by 坂本貴宏 on 2018/09/29.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices
import TLPhotoPicker
import Foundation

protocol TLPhotoLibraryDelegate: class {
    func loadCameraRollCollection(collection: TLAssetsCollection)
}

class ViewController: UIViewController, TLPhotosPickerViewControllerDelegate {
    
    open var doneButton: UIBarButtonItem!
    
    var assets:[UIImage] = [UIImage]()
    
    //var images:[UIImageView]!
    
    var imageView1:UIImageView!
    var imageView2:UIImageView!
    var imageView3:UIImageView!
    var imageView4:UIImageView!
    var imageView5:UIImageView!
    
    
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        for asset in withPHAssets {
            print(asset)
            let image = TLPhotoLibrary.fullResolutionImageData(asset: asset)!
            self.assets.append(image)
            
        }
        
        imageView1.image = self.assets[0]
        imageView2.image = self.assets[1]
        imageView3.image = self.assets[2]
        imageView4.image = self.assets[3]
        imageView5.image = self.assets[4]
        
    }
    
    
    
    var selectedAssets = [TLPHAsset]()
    var Array = ["Mikeneko", "Pug", "Chihuahua", "American Shorthair", "Munchkin"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(12345)
        
        // imageViewの作成
        imageView1 = makeImageView(x: 16, y: 133, named: Array[0])
        self.view.addSubview(imageView1)
        imageView2 = makeImageView(x: 142, y: 133, named: Array[1])
        self.view.addSubview(imageView2)
        imageView3 = makeImageView(x: 267, y: 133, named: Array[2])
        self.view.addSubview(imageView3)
        imageView4 = makeImageView(x: 81, y: 251, named: Array[3])
        self.view.addSubview(imageView4)
        imageView5 = makeImageView(x: 207, y: 251, named: Array[4])
        self.view.addSubview(imageView5)
        
        let button = makebutton()
        self.view.addSubview(button)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func makeImageView(x: Int, y:Int, named: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: x, y: y, width: 80, height: 80)
        imageView.image = UIImage(named: "\(named)")
        return imageView
        
    }
    func makebutton() -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 98, y: 480, width: 180, height: 80)
        button.setTitle("select", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "HirakakuPorN-W6", size: 15)
        button.addTarget(self, action: #selector(pickerButtonTap) , for: .touchUpInside)
        return button
    }
    @objc func pickerButtonTap() {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        var configure = TLPhotosPickerConfigure()
        self.present(viewController, animated: true, completion: nil)
    }


    
    
    
}


struct TLAssetsCollection {
    var phAssetCollection: PHAssetCollection? = nil
    var fetchResult: PHFetchResult<PHAsset>? = nil
    var useCameraButton: Bool = false
    var recentPosition: CGPoint = CGPoint.zero
    var title: String
    var localIdentifier: String
    var count: Int {
        get {
            guard let count = self.fetchResult?.count, count > 0 else { return self.useCameraButton ? 1 : 0 }
            return count + (self.useCameraButton ? 1 : 0)
        }
    }
    
    init(collection: PHAssetCollection) {
        self.phAssetCollection = collection
        self.title = collection.localizedTitle ?? ""
        self.localIdentifier = collection.localIdentifier
    }
//    
//    func getAsset(at index: Int) -> PHAsset? {
//        if self.useCameraButton && index == 0 { return nil }
//        let index = index - (self.useCameraButton ? 1 : 0)
//        guard let result = self.fetchResult, index < result.count else { return nil }
//        return result.object(at: max(index,0))
//    }
//    
//    func getTLAsset(at index: Int) -> TLPHAsset? {
//        if self.useCameraButton && index == 0 { return nil }
//        let index = index - (self.useCameraButton ? 1 : 0)
//        guard let result = self.fetchResult, index < result.count else { return nil }
//        return TLPHAsset(asset: result.object(at: max(index,0)))
//    }
//    
//    func getAssets(at range: CountableClosedRange<Int>) -> [PHAsset]? {
//        let lowerBound = range.lowerBound - (self.useCameraButton ? 1 : 0)
//        let upperBound = range.upperBound - (self.useCameraButton ? 1 : 0)
//        return self.fetchResult?.objects(at: IndexSet(integersIn: max(lowerBound,0)...min(upperBound,count)))
//    }
    
    static func ==(lhs: TLAssetsCollection, rhs: TLAssetsCollection) -> Bool {
        return lhs.localIdentifier == rhs.localIdentifier
    }
    
}
extension UIImage {
    func upOrientationImage() -> UIImage? {
        switch imageOrientation {
        case .up:
            return self
        default:
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(in: CGRect(origin: .zero, size: size))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        }
    }
}


class TLPhotoLibrary {
    
    weak var delegate: TLPhotoLibraryDelegate? = nil
    
    lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    deinit {
        //        print("deinit TLPhotoLibrary")
    }
    
    @discardableResult
    func livePhotoAsset(asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), progressBlock: Photos.PHAssetImageProgressHandler? = nil, completionBlock:@escaping (PHLivePhoto,Bool)-> Void ) -> PHImageRequestID {
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.progressHandler = progressBlock
        let scale = min(UIScreen.main.scale,2)
        let targetSize = CGSize(width: size.width*scale, height: size.height*scale)
        let requestId = self.imageManager.requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (livePhoto, info) in
            let complete = (info?["PHImageResultIsDegradedKey"] as? Bool) == false
            if let livePhoto = livePhoto {
                completionBlock(livePhoto,complete)
            }
        }
        return requestId
    }
    
    @discardableResult
    func videoAsset(asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), progressBlock: Photos.PHAssetImageProgressHandler? = nil, completionBlock:@escaping (AVPlayerItem?, [AnyHashable : Any]?) -> Void ) -> PHImageRequestID {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        options.progressHandler = progressBlock
        let requestId = self.imageManager.requestPlayerItem(forVideo: asset, options: options, resultHandler: { playerItem, info in
            completionBlock(playerItem,info)
        })
        return requestId
    }
    
    @discardableResult
    func imageAsset(asset: PHAsset, size: CGSize = CGSize(width: 160, height: 160), options: PHImageRequestOptions? = nil, completionBlock:@escaping (UIImage,Bool)-> Void ) -> PHImageRequestID {
        var options = options
        if options == nil {
            options = PHImageRequestOptions()
            options?.isSynchronous = false
            options?.resizeMode = .exact
            options?.deliveryMode = .opportunistic
            options?.isNetworkAccessAllowed = true
        }
        let scale = min(UIScreen.main.scale,2)
        let targetSize = CGSize(width: size.width*scale, height: size.height*scale)
        let requestId = self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, info in
            let complete = (info?["PHImageResultIsDegradedKey"] as? Bool) == false
            if let image = image {
                completionBlock(image,complete)
            }
        }
        return requestId
    }
    
    func cancelPHImageRequest(requestId: PHImageRequestID) {
        self.imageManager.cancelImageRequest(requestId)
    }
    
    @discardableResult
    class func cloudImageDownload(asset: PHAsset, size: CGSize = PHImageManagerMaximumSize, progressBlock: @escaping (Double) -> Void, completionBlock:@escaping (UIImage?)-> Void ) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        options.version = .current
        options.resizeMode = .exact
        options.progressHandler = { (progress,error,stop,info) in
            progressBlock(progress)
        }
        let requestId = PHCachingImageManager().requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
            if let data = imageData,let _ = info {
                completionBlock(UIImage(data: data))
            }else{
                completionBlock(nil)//error
            }
        }
        return requestId
    }
    
    @discardableResult
    class func fullResolutionImageData(asset: PHAsset) -> UIImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.isNetworkAccessAllowed = false
        options.version = .current
        var image: UIImage? = nil
        _ = PHCachingImageManager().requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
            if let data = imageData {
                image = UIImage(data: data)
            }
        }
        return image
    }
}

extension PHFetchOptions {
    func merge(predicate: NSPredicate) {
        if let storePredicate = self.predicate {
            self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [storePredicate, predicate])
        }else {
            self.predicate = predicate
        }
    }
}


public struct TLPHAsset {
    enum CloudDownloadState {
        case ready, progress, complete, failed
    }
    
    public enum AssetType {
        case photo, video, livePhoto
    }
    
    public enum ImageExtType: String {
        case png, jpg, gif, heic
    }
    
    var state = CloudDownloadState.ready
    public var phAsset: PHAsset? = nil
    public var selectedOrder: Int = 0
    public var type: AssetType {
        get {
            guard let phAsset = self.phAsset else { return .photo }
            if phAsset.mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            }else if phAsset.mediaType == .video {
                return .video
            }else {
                return .photo
            }
        }
    }
    
    public var fullResolutionImage: UIImage? {
        get {
            guard let phAsset = self.phAsset else { return nil }
            
            return TLPhotoLibrary.fullResolutionImageData(asset: phAsset)
        }
    }

}
