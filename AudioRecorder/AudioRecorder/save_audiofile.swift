//
//  save_audiofile.swift
//  AudioRecorder
//
//  Created by Hiroki Ichikura on 2022/09/06.
//

import Foundation
import AVFoundation

class AudioDataClass{
    //object for audio file
    var audioFile:AVAudioFile!

    //buffer for PCM data 便宜上AVAudioPCMBuffer型の変数を用意
    //クラス外から実際にバイナリデータにアクセスする際はbufferプロパティを使う。
    var PCMBuffer:AVAudioPCMBuffer!

    // audio file address
    var address:String

    //オーディオのバイナリデータを格納するためのbuffer, マルチチャンネルに対応するため、二次元配列になっています。
    var buffer:[[Float]]! = Array<Array<Float>>()

    // define audio data
    var samplingRate:Double?
    var nChannel:Int?
    var nframe:Int?

    //initializer
    init(address:String){
        self.address = address
    }
    
    func readAudioData(){
        
        // create AVAudioFile
        //error handling　do catch
        do{
            // load and store audioFile of data
            self.audioFile = try AVAudioFile(forReading: URL(fileURLWithPath: self.address))
            // get samplingRate
            self.samplingRate = self.audioFile.fileFormat.sampleRate
            //get channel
            self.nChannel = Int(self.audioFile.fileFormat.channelCount)
        }catch{
            //misstale to load file
            print("Error : loading audio file\(self.address) failed.")
        }
        
        // If audio file can load, it is gotten by binary data
        if(self.audioFile != nil){
            // get frame length
            self.nframe = Int(self.audioFile.length)
            
            // allocate
            self.PCMBuffer = AVAudioPCMBuffer(PCMFormat: self.audioFile.processingFormat, frameCapacity: AVAudioFrameCount(self.nframe!))

            //error handling
            do {
                // get binary data to PCMBuffer from audio File
                try self.audioFile.read(into: self.PCMBuffer)
                
                //各チャンネル毎にバイナリデータをbufferに追加する
                for i in 0..<self.nChannel!{
                    let buf:[Float] = Array(UnsafeMutableBufferPointer(start:self.PCMBuffer.floatChannelData[i], count:self.nframe!))

                    self.buffer.append(buf)
            }
        }
        
    }
    
    func writeAudioData(data:[[Float]],address:String,format:AVAudioFormat?)->Bool{

        //バイナリデータフォーマットを格納する
        var audioformat:AVAudioFormat?


        let nChannel:Int = data.count
        let nframe:Int = data[0].count

        //フレーム数が0の場合、dataは空。
        if(nframe == 0){print("Error : no data."); return false}

        //チャンネル数が0であれば、dataは空
        if(nChannel > 0){

            //読み込んだオーディオファイルと同じフバイナリフォーマットで書き出す場合
            if(format == nil){ // we follow loaded audio file format

                //サンプリングレートの設定がなければ、デフォルトの44100hzを採用
                if(self.samplingRate == nil){self.samplingRate = 44100;}

                if(self.audioFile != nil){

                    //setup audio format
                    audioformat = AVAudioFormat(standardFormatWithSampleRate: self.samplingRate!, channels: AVAudioChannelCount(nChannel))
                }

            }else{// we use new audio file format
                audioformat = format
            }
        }else{
            return false
        }

        //make PCMBuffer
        let buffer = AVAudioPCMBuffer(pcmFormat:audioformat!, frameCapacity: AVAudioFrameCount(nframe))
        //update frameLength which is the actual size of the file to be written in a disk
    buffer?.frameLength = AVAudioFrameCount(nframe)

        //copy input data to PCMBuffer

        for i in 0..<nChannel{
            for j in 0..<nframe{
                buffer?.floatChannelData?[i][j] = data[i][j]
            }
        }
        //make an audio file for writing
        var writeAudioFile:AVAudioFile?

        do{
            //書き出すオーディオファイルのフォーマット
            writeAudioFile = try AVAudioFile(forWriting: URL(fileURLWithPath: address), settings: [
                AVFormatIDKey:Int(kAudioFormatLinearPCM), // file format
                AVSampleRateKey:audioformat!.sampleRate,
                AVNumberOfChannelsKey:nChannel,
                AVEncoderBitRatePerChannelKey:16 // 16bit
                ])

        }catch{
            print("Error : making audio file failed.")
            return false
        }

        //export an audio file
        do{
            //書き出し
            try writeAudioFile!.writeFromBuffer(buffer ?? <#default value#>!)
            print("\(nframe) samples are written in \(address)")

        }catch{
            print("Error : Could not export audio file")
            return false
        }

        return true
    }

}
