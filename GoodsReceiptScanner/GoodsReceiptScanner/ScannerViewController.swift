//
//  ViewController.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/10/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.

//  Source: https://www.hackingwithswift.com/example-code/media/how-to-scan-a-barcode
//

import AVFoundation
import UIKit

enum ScannerMessages: String, CustomStringConvertible {
    
    var description: String {
        switch self {
        case .scannerNotSupported: return "Your device does not support scanning a code from an item. Please use a device with a camera."
        }
    }
    
    case scannerNotSupported = "Scanning not supported"
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var purchaseOrder: PurchaseOrder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    
    }
    
    func failed() {
        let ac = UIAlertController(title: ScannerMessages.scannerNotSupported.rawValue,
                                   message: ScannerMessages.scannerNotSupported.description,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: ControllerMessages.ok.rawValue, style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    func presentMessage(_ error: GoodsReceiptApiMessages) {
        let alertController = UIAlertController(title: ControllerMessages.sapMessage.rawValue, message: error.description, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: ControllerMessages.ok.rawValue, style: .default) { action in
            self.captureSession.startRunning()
        }
        alertController.addAction(OKAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func found(purchaseOrderNumber poNumber: PurchaseOrderNumber, completion: @escaping (PurchaseOrder) -> Void) {
        
        GoodsReceiptApi.shared.getPurchaseOrder(purchaseOrderNumber: poNumber) { (result: Result<PurchaseOrder, GoodsReceiptApiMessages>) in
            
            switch result {
            case .success(let purchaseOrder):
                completion(purchaseOrder)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentMessage(error)
                }
            
            }
        
        }
            
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SeguesIdentifier.showPO.rawValue {
            
            if let vc = segue.destination as? PurchaseOrderTableViewController
            {
                vc.purchaseOrder = self.purchaseOrder
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            let activityIndicator = UIActivityIndicatorView(style: .white)
            activityIndicator.frame = self.view.bounds
            self.view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            
            found(purchaseOrderNumber: stringValue) { (po:PurchaseOrder) in
                
                self.purchaseOrder = po
                DispatchQueue.main.async {
                    activityIndicator.removeFromSuperview()
                    self.performSegue(withIdentifier: SeguesIdentifier.showPO.rawValue, sender: nil)
                }
            }
            
        }
        
        dismiss(animated: true)
    }
}

enum SeguesIdentifier: String {
    case showPO = "showPO"
}
