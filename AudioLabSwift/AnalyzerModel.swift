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
    
}
