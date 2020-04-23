//
//  Record21.swift
//  Cser21
//
//  Created by Hung-Catalina on 4/22/20.
//  Copyright © 2020 High Sierra. All rights reserved.
//

import Foundation
import AVFoundation


class Record21 {
    
    
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var result: Result? = nil
    var app21: App21? = nil
    var audioFilename:URL? = nil
    
    
   
    
    func _PERMISSION(callback: @escaping () -> ())  {
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        callback()
                    } else {
                        self._error(Error21.runtimeError("permission_denied"))
                    }
                }
            }
        } catch {
            self._error(Error21.runtimeError("permission_error"))
        }
    }
    
    func startRecording()
    {
        audioFilename = DownloadFileTask().filenameFrom(suffix: "RECORD_AUDIO.mp3")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename!, settings: settings)
            audioRecorder.delegate = app21?.caller
            audioRecorder.record()
            self._success()
            
        } catch {
            self._error(error)
        }
        
    }
    
    func stopRecording() {
        finishRecording()
    }
    
    
    func finishRecording() {
        if(audioRecorder != nil){
            audioRecorder.stop()
        }
        audioRecorder = nil
    }
    func _error(_ error: Error?) {
        result?.success = false
        if(error != nil){
            result?.error = error?.localizedDescription
        }
        app21?.App21Result(result: result!)
    }
    func _success() {
        result?.success = true;
        app21?.App21Result(result: result!)
    }
    func RecordAudio(result: Result,app21: App21) -> Void{
        do
        {
            self.app21 = app21
            self.result = result
            
            let parser = JSON.parse(RecordInfo.self, from: result.params!)
            if parser.1 != nil{
                
                self.result!.error = parser.1
                
                _error(nil)
                return
            }
            
            let recordInfo: RecordInfo = parser.0!
            
            switch recordInfo.action {
            case "record":
                _PERMISSION {
                    self.startRecording()
                   
                }
                //
                break;
            case "record_stop":
                stopRecording()
               _success()
                //
                break;
            case "play":
                
                _error(Error21.runtimeError("IOS_not_support_playAction"))
                //
                break;
            case "play_stop":
               _error(Error21.runtimeError("IOS_not_support_playStopAction"))           //
                break;
            default:
                //
            break;
            }
            
            
        }catch{
            _error(error)
        }
    }
}
class RecordInfo : Decodable{
    var action: String = "";
    var filename: String? = nil;
}
