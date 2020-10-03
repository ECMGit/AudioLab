//
//  ViewController.swift
//  AudioLabSwift
//
//  Created by Eric Larson 
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit
import Metal


//let AUDIO_BUFFER_SIZE = 1024*4

let AUDIO_BUFFER_SIZE = 7350

class ViewController: UIViewController {

    @IBOutlet weak var loudest: UILabel!
    @IBOutlet weak var loudest2: UILabel!
    @IBOutlet weak var toneFreq: UILabel!
    
    let audio = AudioModel(buffer_size: AUDIO_BUFFER_SIZE)
    lazy var graph:MetalGraph? = {
        return MetalGraph(mainView: self.view)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // add in graphs for display
        graph?.addGraph(withName: "fft",
                        shouldNormalize: true,
                        numPointsInGraph: AUDIO_BUFFER_SIZE/2)
        
        graph?.addGraph(withName: "time",
            shouldNormalize: false,
            numPointsInGraph: AUDIO_BUFFER_SIZE)
        
        // just start up the audio model here
        audio.startMicrophoneProcessing(withFps: 10)
        //audio.startProcesingAudioFileForPlayback()
        audio.startProcessingSinewaveForPlayback(withFreq: 0) // TODO: TAKE OUT LATER WHEN SECOND VIEW CONTROLLER USES NEW AUDIOMODEL.
        audio.play()
        
        // run the loop for updating the graph peridocially
        Timer.scheduledTimer(timeInterval: 0.05, target: self,
            selector: #selector(self.updateGraph),
            userInfo: nil,
            repeats: true)
       
    }
    @IBAction func resetValue(_ sender: UIButton) {
        audio.analyzer.max_s = 0
        audio.analyzer.max_l = 0
        audio.analyzer.loudest_freq = 0
        audio.analyzer.loudest2_freq = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audio.audioPause()
        print("Exit, audio pause.")
    }
    
    @objc
    func updateGraph(){
        self.graph?.updateGraph(
            data: self.audio.fftData,
            forKey: "fft"
        )
        
        self.graph?.updateGraph(
            data: self.audio.timeData,
            forKey: "time"
        )
        loudest.text = String(audio.analyzer.loudest_freq)
        loudest2.text = String(audio.analyzer.loudest2_freq)
        toneFreq.text = String(audio.analyzer.f_peak)
        
    }
    
    

}

