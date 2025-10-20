//
//  VisualizationEngine.swift
//  idle_01
//
//  ASCII visualization system that reacts to narrative events
//  Abstract patterns that pulse, rotate, and evolve with the story
//

import Foundation
import SwiftUI
import Observation

/// Manages ASCII visualization patterns that respond to narrative
@Observable
@MainActor
final class VisualizationEngine {

    // MARK: - Properties

    var currentPattern: ASCIIPattern = .idle
    var animationState: AnimationState = .stopped
    var intensity: Double = 0.5

    // Animation timing
    private var animationTimer: Timer?
    private var animationFrame: Int = 0

    // MARK: - Initialization

    init() {
        self.currentPattern = .idle
        self.animationState = .stopped
    }

    // MARK: - Pattern Triggering

    /// Triggers visualization for a revealed moment
    func triggerForMoment(_ moment: CityMoment) {
        let pattern = patternForMomentType(moment.type)
        let intensity = intensityForMomentType(moment.type)

        startAnimation(pattern: pattern, intensity: intensity)
    }

    /// Triggers visualization for a player choice
    func triggerForChoice(_ pattern: ChoicePattern) {
        let asciiPattern = patternForChoice(pattern)
        let intensity = intensityForChoice(pattern)

        startAnimation(pattern: asciiPattern, intensity: intensity)
    }

    /// Updates visualization for act transitions
    func updateForAct(_ act: Int) {
        let pattern = patternForAct(act)
        startAnimation(pattern: pattern, intensity: 0.6)
    }

    /// Triggers decay animation (when moments are destroyed)
    func triggerDecay() {
        startAnimation(
            pattern: .decay,
            intensity: GameBalanceConfig.Visualization.decayIntensity
        )
    }

    // MARK: - Pattern Selection

    private func patternForMomentType(_ type: MomentType) -> ASCIIPattern {
        switch type {
        case .dailyRitual:
            return .pulse(intensity: 0.5)

        case .nearMiss:
            return .flash(duration: 0.5)

        case .smallRebellion:
            return .pulse(intensity: 0.8)

        case .invisibleConnection:
            return .weave

        case .temporalGhost:
            return .fade

        case .question:
            return .rotate(speed: 1.0)

        case .momentOfBecoming:
            return .emerge

        case .weightOfSmallThings:
            return .shimmer
        }
    }

    private func intensityForMomentType(_ type: MomentType) -> Double {
        switch type {
        case .dailyRitual:
            return 0.5
        case .nearMiss:
            return 0.9
        case .smallRebellion:
            return 0.8
        case .invisibleConnection:
            return 0.6
        case .temporalGhost:
            return 0.4
        case .question:
            return 0.7
        case .momentOfBecoming:
            return 0.85
        case .weightOfSmallThings:
            return 0.3
        }
    }

    private func patternForChoice(_ pattern: ChoicePattern) -> ASCIIPattern {
        switch pattern {
        case .story:
            return .pulse(intensity: GameBalanceConfig.Visualization.storyChoiceIntensity)

        case .efficiency:
            return .sharp

        case .autonomy:
            return .expand

        case .control:
            return .contract
        }
    }

    private func intensityForChoice(_ pattern: ChoicePattern) -> Double {
        switch pattern {
        case .story:
            return GameBalanceConfig.Visualization.storyChoiceIntensity
        case .efficiency:
            return GameBalanceConfig.Visualization.efficiencyChoiceIntensity
        case .autonomy:
            return 0.7
        case .control:
            return 0.8
        }
    }

    private func patternForAct(_ act: Int) -> ASCIIPattern {
        switch act {
        case 1:
            return .emerge
        case 2:
            return .weave
        case 3:
            return .pulse(intensity: 0.7)
        case 4:
            return .transcend
        default:
            return .idle
        }
    }

    // MARK: - Animation Control

    private func startAnimation(pattern: ASCIIPattern, intensity: Double) {
        self.currentPattern = pattern
        self.intensity = intensity
        self.animationState = .playing
        self.animationFrame = 0

        // Stop existing timer
        animationTimer?.invalidate()

        // Start new animation timer
        let duration = pattern.duration
        let frameRate = 1.0 / 30.0 // 30 fps

        animationTimer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.animationFrame += 1

            let elapsed = Double(self.animationFrame) * frameRate
            if elapsed >= duration {
                self.stopAnimation()
            }
        }
    }

    func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        animationState = .stopped
        currentPattern = .idle
        animationFrame = 0
    }

    // MARK: - Pattern Rendering

    /// Returns the current ASCII art as a string
    func renderCurrentFrame() -> String {
        let progress = animationProgress()
        return currentPattern.render(frame: animationFrame, progress: progress, intensity: intensity)
    }

    private func animationProgress() -> Double {
        let duration = currentPattern.duration
        let elapsed = Double(animationFrame) / 30.0 // 30 fps
        return min(1.0, elapsed / duration)
    }
}

// MARK: - ASCII Pattern Enum

enum ASCIIPattern {
    case idle
    case pulse(intensity: Double)
    case rotate(speed: Double)
    case flash(duration: Double)
    case decay
    case emerge
    case weave
    case fade
    case shimmer
    case sharp
    case expand
    case contract
    case transcend

    /// Duration of the animation in seconds
    var duration: Double {
        switch self {
        case .idle:
            return .infinity
        case .pulse:
            return GameBalanceConfig.Visualization.pulseDuration
        case .rotate:
            return GameBalanceConfig.Visualization.rotationDuration
        case .flash:
            return 0.5
        case .decay:
            return 2.5
        case .emerge:
            return 3.0
        case .weave:
            return 2.5
        case .fade:
            return 2.0
        case .shimmer:
            return 1.5
        case .sharp:
            return 1.0
        case .expand:
            return 2.0
        case .contract:
            return 1.5
        case .transcend:
            return 4.0
        }
    }

    /// Renders the pattern for the given frame
    func render(frame: Int, progress: Double, intensity: Double) -> String {
        switch self {
        case .idle:
            return renderIdle()

        case .pulse(let pulseIntensity):
            return renderPulse(progress: progress, intensity: pulseIntensity * intensity)

        case .rotate(let speed):
            return renderRotate(frame: frame, speed: speed)

        case .flash:
            return renderFlash(progress: progress, intensity: intensity)

        case .decay:
            return renderDecay(progress: progress)

        case .emerge:
            return renderEmerge(progress: progress)

        case .weave:
            return renderWeave(progress: progress)

        case .fade:
            return renderFade(progress: progress)

        case .shimmer:
            return renderShimmer(frame: frame)

        case .sharp:
            return renderSharp(progress: progress, intensity: intensity)

        case .expand:
            return renderExpand(progress: progress)

        case .contract:
            return renderContract(progress: progress)

        case .transcend:
            return renderTranscend(progress: progress)
        }
    }

    // MARK: - Pattern Implementations

    private func renderIdle() -> String {
        return """
        ◦ ◦ ◦
        ◦ ◉ ◦
        ◦ ◦ ◦
        """
    }

    private func renderPulse(progress: Double, intensity: Double) -> String {
        let phase = sin(progress * .pi * 2) * intensity
        let size = 1.0 + phase * 0.5

        if size > 1.3 {
            return """
            ◦ ◦ ◦ ◦ ◦
            ◦ ◉ ◉ ◉ ◦
            ◦ ◉ ● ◉ ◦
            ◦ ◉ ◉ ◉ ◦
            ◦ ◦ ◦ ◦ ◦
            """
        } else if size > 1.1 {
            return """
            ◦ ◦ ◦
            ◦ ● ◦
            ◦ ◦ ◦
            """
        } else {
            return """
            ◦ ◦ ◦
            ◦ ◉ ◦
            ◦ ◦ ◦
            """
        }
    }

    private func renderRotate(frame: Int, speed: Double) -> String {
        let rotations = ["╱", "│", "╲", "─"]
        let index = Int(Double(frame) * speed / 5) % rotations.count

        return """
        ◦ \(rotations[index]) ◦
        \(rotations[(index + 2) % 4]) ◉ \(rotations[index])
        ◦ \(rotations[(index + 2) % 4]) ◦
        """
    }

    private func renderFlash(progress: Double, intensity: Double) -> String {
        if progress < 0.3 {
            return """
            ● ● ●
            ● ● ●
            ● ● ●
            """
        } else if progress < 0.6 {
            return """
            ◉ ◉ ◉
            ◉ ● ◉
            ◉ ◉ ◉
            """
        } else {
            return """
            ◦ ◦ ◦
            ◦ ◉ ◦
            ◦ ◦ ◦
            """
        }
    }

    private func renderDecay(progress: Double) -> String {
        if progress < 0.25 {
            return """
            ◉ ◉ ◉
            ◉ ● ◉
            ◉ ◉ ◉
            """
        } else if progress < 0.5 {
            return """
            ◦ ◉ ◦
            ◉ ● ◉
            ◦ ◉ ◦
            """
        } else if progress < 0.75 {
            return """
            ◦ ◦ ◦
            ◦ ◉ ◦
            ◦ ◦ ◦
            """
        } else {
            return """
            ◦ ◦ ◦
            ◦ ◦ ◦
            ◦ ◦ ◦
            """
        }
    }

    private func renderEmerge(progress: Double) -> String {
        if progress < 0.3 {
            return """
            ◦ ◦ ◦
            ◦ · ◦
            ◦ ◦ ◦
            """
        } else if progress < 0.6 {
            return """
            ◦ ◦ ◦
            ◦ ◉ ◦
            ◦ ◦ ◦
            """
        } else {
            return """
            ◦ ◉ ◦
            ◉ ● ◉
            ◦ ◉ ◦
            """
        }
    }

    private func renderWeave(progress: Double) -> String {
        let frame = Int(progress * 8)

        switch frame {
        case 0, 1:
            return """
            ╱ ◦ ◦
            ◦ ◉ ◦
            ◦ ◦ ╲
            """
        case 2, 3:
            return """
            ◦ ╱ ◦
            ╲ ◉ ╱
            ◦ ╲ ◦
            """
        case 4, 5:
            return """
            ◦ ◦ ╲
            ◦ ◉ ◦
            ╱ ◦ ◦
            """
        default:
            return """
            ◦ ╲ ◦
            ╱ ◉ ╲
            ◦ ╱ ◦
            """
        }
    }

    private func renderFade(progress: Double) -> String {
        if progress < 0.3 {
            return """
            ◉ ◉ ◉
            ◉ ● ◉
            ◉ ◉ ◉
            """
        } else if progress < 0.7 {
            return """
            ◦ ◉ ◦
            ◉ ◉ ◉
            ◦ ◉ ◦
            """
        } else {
            return """
            ◦ ◦ ◦
            ◦ ◉ ◦
            ◦ ◦ ◦
            """
        }
    }

    private func renderShimmer(frame: Int) -> String {
        let shimmer = (frame % 4) < 2

        if shimmer {
            return """
            · ◉ ·
            ◉ ◦ ◉
            · ◉ ·
            """
        } else {
            return """
            ◉ · ◉
            · ◦ ·
            ◉ · ◉
            """
        }
    }

    private func renderSharp(progress: Double, intensity: Double) -> String {
        if progress < 0.5 {
            return """
            ◢ ▲ ◣
            ◀ ● ▶
            ◥ ▼ ◤
            """
        } else {
            return """
            ╱ │ ╲
            ─ ◉ ─
            ╲ │ ╱
            """
        }
    }

    private func renderExpand(progress: Double) -> String {
        if progress < 0.25 {
            return """
            ◦ ◦ ◦
            ◦ ● ◦
            ◦ ◦ ◦
            """
        } else if progress < 0.5 {
            return """
            ◦ ◦ ◦
            ◦ ◉ ◦
            ◦ ◦ ◦
            """
        } else if progress < 0.75 {
            return """
            ◦ ◉ ◦
            ◉ ◉ ◉
            ◦ ◉ ◦
            """
        } else {
            return """
            ◉ ◉ ◉
            ◉ ● ◉
            ◉ ◉ ◉
            """
        }
    }

    private func renderContract(progress: Double) -> String {
        if progress < 0.33 {
            return """
            ◉ ◉ ◉
            ◉ ● ◉
            ◉ ◉ ◉
            """
        } else if progress < 0.66 {
            return """
            ◦ ◉ ◦
            ◉ ● ◉
            ◦ ◉ ◦
            """
        } else {
            return """
            ◦ ◦ ◦
            ◦ ● ◦
            ◦ ◦ ◦
            """
        }
    }

    private func renderTranscend(progress: Double) -> String {
        let frame = Int(progress * 12)

        switch frame {
        case 0...2:
            return """
            ◦ ◉ ◦
            ◉ ● ◉
            ◦ ◉ ◦
            """
        case 3...5:
            return """
            ◉ ◦ ◉
            ◦ ● ◦
            ◉ ◦ ◉
            """
        case 6...8:
            return """
            · ◉ ·
            ◉ ◦ ◉
            · ◉ ·
            """
        default:
            return """
            ◦ · ◦
            · ◦ ·
            ◦ · ◦
            """
        }
    }
}

// MARK: - Animation State

enum AnimationState {
    case stopped
    case playing
    case paused
}

// MARK: - SwiftUI Integration

extension VisualizationEngine {
    /// Returns a SwiftUI Text view with the current pattern
    func asText() -> some View {
        Text(renderCurrentFrame())
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.white)
            .opacity(animationState == .playing ? 1.0 : 0.5)
    }

    /// Returns a formatted string for terminal display
    func forTerminal() -> String {
        guard animationState == .playing else {
            return ""
        }

        return """

        ┌─────────┐
        │ \(renderCurrentFrame().replacingOccurrences(of: "\n", with: " │\n│ ")) │
        └─────────┘

        """
    }
}
