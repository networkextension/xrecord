//
//  capture.swift
//  xrecord
//
//  Created by Patrick Meenan on 2/26/15.
//  Copyright (c) 2015 WPO Foundation. All rights reserved.
//

import Foundation
import AVFoundation

class Capture: NSObject, AVCaptureFileOutputRecordingDelegate {

var session : AVCaptureSession!
var input : AVCaptureDeviceInput?
var output : AVCaptureMovieFileOutput!
var started : Bool = false
var finished : Bool = false

override init() {
    self.session = AVCaptureSession()
    self.session.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.high))

    // Enable screen capture devices in AV Foundation
    xRecord_Bridge.enableScreenCaptureDevices()
}
    
func listDevices() {
    let devices: NSArray = AVCaptureDevice.devices() as NSArray
    for object:AnyObject in devices as [AnyObject] {
        let device = object as! AVCaptureDevice
        let deviceID = device.uniqueID
        let deviceName = device.localizedName
        print("\(deviceID): \(deviceName)")
    }
}
  
func setQuality(_ quality: String!) {
  if (quality == "low") {
    self.session.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.low));
  } else if (quality == "medium") {
    self.session.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.medium));
  } else if (quality == "high") {
    self.session.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.high));
  } else if (quality == "photo") {
    self.session.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.photo));
  }
}

func setDeviceByName(_ name: String!) -> Bool {
    var found : Bool = false
    let devices: NSArray = AVCaptureDevice.devices() as NSArray
    for object:AnyObject in devices as [AnyObject] {
        let captureDevice = object as! AVCaptureDevice
        if captureDevice.localizedName == name {
            var err : NSError? = nil
            do {
                self.input = try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                err = error
                self.input = nil
            }
            if err == nil {
                found = true
            }
        }
    }
    return found
}
    
func setDeviceById(_ id: String!) -> Bool {
    var found : Bool = false
    let devices: NSArray = AVCaptureDevice.devices() as NSArray
    for object:AnyObject in devices as [AnyObject] {
        let captureDevice = object as! AVCaptureDevice
        if captureDevice.uniqueID == id {
            var err : NSError? = nil
            do {
                self.input = try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                err = error
                self.input = nil
            }
            if err == nil {
                found = true
            }
        }
    }
    return found
}
    
func start(_ file: String!) -> Bool {
    var started : Bool = false
    if self.session.canAddInput(self.input!) {
        self.session.addInput(self.input!)
        self.output = AVCaptureMovieFileOutput()
        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
            self.session.startRunning()
            self.output.startRecording(to: URL(fileURLWithPath: file), recordingDelegate: self)
            started = true
        }
    }
    return started
}
    
func stop() {
    self.output.stopRecording()
    self.session.stopRunning()
}

func fileOutput(_ captureOutput: AVCaptureFileOutput,
    didStartRecordingTo fileURL: URL,
    from connections: [AVCaptureConnection]) {
    NSLog("captureOutput Started callback");
    self.started = true
}
    
func fileOutput(_ captureOutput: AVCaptureFileOutput,
    didFinishRecordingTo outputFileURL: URL,
    from connections: [AVCaptureConnection],
    error: Error?) {
    NSLog("captureOutput Finished callback")
    self.finished = true
}

} // class Capture

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVCaptureSessionPreset(_ input: AVCaptureSession.Preset) -> String {
	return input.rawValue
}
