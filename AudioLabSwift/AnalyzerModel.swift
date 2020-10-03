//
//  File.swift
//  Lab2
//
//  Created by MSLC on 10/2/20.
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import Foundation
import Accelerate

class AnalyzerModel{
    private var BUFFER_SIZE:Int
    
    var max_l:Float // loudest decibel
    var max_s:Float // second loudest decibel
    var loudest_freq:Int
    var loudest2_freq:Int
    var f_peak:Int // current freq
    var f2:Int
    var f1:Int
    
    init(buffer_size:Int){
        BUFFER_SIZE = buffer_size
        // anything not lazily instatntiated should be allocated here
        max_s = 0
        max_l = 0
        loudest_freq = 0
        loudest2_freq = 0
        f1 = 0
        f2 = 0
        f_peak = 0
    }
    
    
    public func getMaxFrequencies(fftData:Array<Float>){
        
        var max_array:UnsafeMutablePointer<Float>
        let window_len = 80
        let N = BUFFER_SIZE/2 - window_len + 1
        max_array = UnsafeMutablePointer.allocate(capacity: BUFFER_SIZE/2 - window_len + 1)
        vDSP_vswmax(fftData, 1, max_array, 1, UInt(N), UInt(window_len))
        var m1 = Float(-9999.0)
        var m2 = Float(-9999.0)
        var m3 = Float(-9999.0)
        for i in 0..<N {
            m2 = max(max_array[i], m2)
        }
                    
        for i in 0..<fftData.count{
            // peak interpolation
            if(fftData[i] == m2 && i < fftData.count - 1 && i > 0){
                 f2 = i
                 m1 = fftData[i - 1]
                 m3 = fftData[i + 1]
            }
            if(fftData[i] == m1){f1 = i}
        }
                    
        let delta_f = 44100/Float(BUFFER_SIZE)
        var temp = (m1 - m3)/(m3 - 2*m2 + m1) * (delta_f/2)

        let frequency = Float(f2*2) / Float(BUFFER_SIZE) * 44100
        //print("f2", f2," detected frequency:", frequency, " quadratic approximation", temp)
        if temp.isNaN{
             temp = 1
        }
        f_peak = Int(frequency/1.11485 + temp) // current frequency
                    
        if(m2 > max_l){
             max_s = max_l
             loudest2_freq = loudest_freq
             loudest_freq = f_peak
             max_l = m2
        }
        
    }
    
    public func freq2Tone(fq:Int)->String{
        var s = ""
        if(fq < 114 && fq >= 106){
            s = "A2"
        }else if(fq >= 114 && fq <= 120){
            s = "A#2"
        }else if(fq > 120 && fq <= 127){
            s = "B2"
        }else if(fq > 127 && fq <= 135){
            s = "C3"
        }else if(fq > 135 && fq <= 143){
            s = "C#3"
        }else if(fq > 143 && fq <= 151){
            s = "D3"
        }else if(fq > 151 && fq <= 160){
            s = "D#3"
        }else if(fq > 160 && fq <= 170){
            s = "E3"
        }else if(fq > 170 && fq <= 180){
            s = "F3"
        }else if(fq > 180 && fq <= 190){
            s = "F#3"
        }else if(fq > 190 && fq <= 202){
            s = "G3"
        }else if(fq > 202 && fq <= 214){
            s = "G#3"
        }else if(fq > 214 && fq <= 226){
            s = "A3"
        }else if(fq > 226 && fq <= 240){
            s = "A#3"
        }else if(fq > 240 && fq <= 254){
            s = "B3"
        }else if(fq > 254 && fq <= 270){
            s = "C4"
        }else if(fq > 270 && fq <= 285){
            s = "C#4"
        }else if(fq > 285 && fq <= 302){
            s = "D4"
        }else if(fq > 305 && fq <= 317){
            s = "D#4"
        }else if(fq > 320 && fq <= 340){
            s = "E4"
        }else if(fq > 340 && fq <= 360){
            s = "F4"
        }else if(fq > 360 && fq <= 380){
            s = "F#4"
        }else if(fq > 385 && fq <= 400){
            s = "G4"
        }else if(fq > 405 && fq <= 425){
            s = "G#4"
        }else if(fq > 430 && fq <= 450){
            s = "A4"
        }else if(fq > 460 && fq <= 475){
            s = "A#4"
        }else if(fq > 485 && fq <= 505){
            s = "B4"
        }else if(fq > 513 && fq <= 535){
            s = "C5"
        }else if(fq > 540 && fq <= 565){
            s = "C#5"
        }else if(fq > 577 && fq <= 597){
            s = "D5"
        }else if(fq > 615 && fq <= 632){
            s = "D#5"
        }else if(fq > 650 && fq <= 670){
            s = "E5"
        }else if(fq > 690 && fq <= 710){
            s = "F5"
        }else if(fq > 730 && fq <= 750){
            s = "F#5"
        }else if(fq > 775 && fq <= 795){
            s = "G5"
        }else if(fq > 820 && fq <= 841){
            s = "G#5"
        }else if(fq > 865 && fq <= 895){
            s = "A5"
        }else if(fq > 895){
            s = "too high"
        }else if(fq < 106){
            s = "too low"
        }else{
            s = "too low or too high"
        }
        return s
    }
    
}
