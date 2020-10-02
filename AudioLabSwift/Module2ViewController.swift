//
//  Module2ViewController.swift
//  Lab2
//
//  Created by Reid Russell on 9/24/20.
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit

class Module2ViewController: UIViewController {
    var zoom = 0
    let audio = AudioModel(buffer_size: AUDIO_BUFFER_SIZE)
    var slider_freq = Float(15000.00)
    var zoom_index = Int(AUDIO_BUFFER_SIZE*15000/44100)/2 + 155
    var zoom_array = [Float](repeating: 0, count: 100)
    @IBOutlet var Mod2Freq: UILabel!
    @IBOutlet var move_label: UILabel!
    lazy var graph:MetalGraph? = {
        return MetalGraph(mainView: self.view)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add in graphs for display
        graph?.addGraph(withName: "fft",
                        shouldNormalize: true,
                        numPointsInGraph: 100)
        
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
        zoom_index = Int((AUDIO_BUFFER_SIZE/2*Int(slider_freq)/44100) + 155)
        NSLog("%d", zoom_index)
        Mod2Freq.text = String(slider_freq)
        audio.startProcessingSinewaveForPlayback(withFreq: slider_freq)
        audio.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audio.audioPause()
        print("Exit, audio pause.")
    }
    
    @IBAction func zoom_toggle(_ sender: Any) {
        if zoom == 0{
            zoom = 1
        }
        else{
            zoom = 0
        }
        NSLog("%d",zoom)
    }
    @objc
    func updateGraph(){
        NSLog("%d", zoom_index)
        zoom_array = Array(self.audio.fftData[zoom_index-50...zoom_index+50])
        if zoom == 1{
            self.graph?.updateGraph(
                data: zoom_array,
                forKey: "fft"
            )
        }
        else{
            self.graph?.updateGraph(
                data: self.audio.fftData,
                forKey: "fft"
            )
        }
        
        
        self.graph?.updateGraph(
            data: self.audio.timeData,
            forKey: "time"
        )
        
    }
    
}
