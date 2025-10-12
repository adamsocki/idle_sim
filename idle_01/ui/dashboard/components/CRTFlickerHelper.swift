//
//  CRTFlickerHelper.swift
//  idle_01
//
//  Created by Adam Socki on 10/7/25.
//

import Foundation

func startCRTFlicker(crtFlicker: @escaping (Double) -> Void) {
    Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
        // Random flicker with varying intensity
        let randomFlicker = Double.random(in: 0.96...1.0)

        // Occasional stronger flicker (like a power surge)
        let strongFlicker = Double.random(in: 0.0...1.0) < 0.02 ? Double.random(in: 0.85...0.95) : 1.0

        crtFlicker(min(randomFlicker, strongFlicker))
    }
}
