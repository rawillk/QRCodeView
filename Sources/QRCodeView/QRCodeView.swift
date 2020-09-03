

import UIKit
import AVFoundation


public class QRCodeView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    public var found: (String) -> Bool = {_ in false}
    fileprivate let session = AVCaptureSession()
    
    public init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override class var layerClass: AnyClass  {
        return AVCaptureVideoPreviewLayer.self
    }
    
    public override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
    
    public func startScan() {
        guard session.isRunning == false  else { return }
        session.startRunning()
    }
    
    public func stopScan() {
        guard session.isRunning else { return }
        session.stopRunning()
    }
    
    fileprivate func setup() {
        guard let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input) else {
                return
        }
        session.addInput(input)
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr, .dataMatrix]
        } else {
            return
        }
        
        layer.session = session
        self.layer.videoGravity = .resizeAspectFill
        session.startRunning()
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for meta in metadataObjects {
            guard let readableObject = meta as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue else { continue }
            if found(stringValue) {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }
}

public extension QRCodeView {
    struct Decoder<T> {
        public let decode: (String) -> T?
        
        public static func json<T: Decodable>() -> Decoder<T> {
            .init { (value) -> T? in
                guard let data = value.data(using: .utf8) else {
                    print("Not valid uft8 data for QR code", value)
                    return nil
                }
                return try? JSONDecoder().decode(T.self, from: data)
            }
        }
        
        public static func url() -> Decoder<URL> { .init(decode: URL.init) }
    }
}

