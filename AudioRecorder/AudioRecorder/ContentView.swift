//
//  ContentView.swift
//  AudioRecorder
//
//  Created by Hiroki Ichikura on 2022/07/27.
//

import SwiftUI

struct ContentView: View {
    let audioRecorder: AudioRecorder = AudioRecorder()
    @State var isRecording = false
    
    var body: some View {
        VStack {
            Button("Record Start") {
                self.audioRecorder.record()
            }
            .padding(.bottom, 10.0)
            
            Button("Record Stop") {
                _ = self.audioRecorder.recordStop()
            }
            .padding(.bottom, 10.0)
                    Button("Play Start") {
                        self.audioRecorder.play()
                    }
                    .padding(.bottom, 10.0)
                    Button("Play Stop") {
                        self.audioRecorder.playStop()
                    }
                }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
