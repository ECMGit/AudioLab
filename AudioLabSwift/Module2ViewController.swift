//
//  Module2ViewController.swift
//  Lab2
//
//  Created by Reid Russell on 9/24/20.
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit

class Module2ViewController: UIViewController {
    let audio = AudioModel(buffer_size: AUDIO_BUFFER_SIZE)
    var slider_freq = Float(15000.00)
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
        audio.startProcessingSinewaveForPlayback(withFreq: slider_freq)
        audio.play()
        
        // run the loop for updating the graph peridocially
        Timer.scheduledTimer(timeInterval: 0.05, target: self,
            selector: #selector(self.updateGraph),
            userInfo: nil,
            repeats: true)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func slider1(_ sender: UISlider) {

        slider_freq = sender.value
        audio.startProcessingSinewaveForPlayback(withFreq: slider_freq)
        audio.play()
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
        
    }

}
