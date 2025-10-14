# Terminal Command Implementation Guide

Purpose
- Reference for adding new terminal commands to the project.
- Lists required code locations, patterns, and verification steps.

## Quick overview
- Add a case to `TerminalCommand` (enum).
- Parse the input in `TerminalCommandParser`.
- Implement handling in `TerminalCommandExecutor`.
- Add help text + autocomplete suggestions.
- Add unit tests and any needed UI/Model updates.
- Validate, persist, and log appropriately.

## Files you will typically touch
- `idle_01/ui/terminal/TerminalCommandParser.swift`
- `idle_01/ui/terminal/TerminalCommandExecutor.swift`
- `idle_01/ui/terminal/TerminalInputView.swift` (or other autocomplete UI)
- `idle_01/ui/terminal/TerminalHelpView.swift`
- `idle_01/ui/terminal/TerminalSettingsView.swift` (if command changes settings)
- Tests: `Tests/TerminalCommandTests.swift` (or appropriate test target)
- Models if command affects data: `idle_01/game/*.swift` or SwiftData model files
- Optional: add `@AppStorage` keys in code that needs persistence

## Step-by-step implementation

### 1) Design the command
- Decide canonical technical syntax and optional poetic aliases.
- Decide parameters and flags (positional vs flags like `--name=...`).
- Decide side effects: UI only, model mutation, settings change, simulation change.
- Determine validation rules (ranges, types, required/optional).

### 2) Add enum case
- Add case to `TerminalCommand` (include associated values for parsed params).
Example:
```swift
// add to TerminalCommand enum
case spawnCity(name: String?, template: String?)
```

### 3) Parse input
- Update `TerminalCommandParser.parse(_:)` to detect verbs/aliases and flags.
- Use existing flag extraction helpers (e.g., `extractFlag(from:flag:)`) to keep consistency.
- Return the new enum case with validated/normalized parameters.
Example parsing pattern:
```swift
if verb == "spawn" || verb == "birth" {
    let name = extractFlag(from: components, flag: "--name")
    let template = extractFlag(from: components, flag: "--template")
    return .spawnCity(name: name, template: template)
}
```

### 4) Implement executor handler
- Add a handler in `TerminalCommandExecutor.handle(_:)` or switch in `handleCommand()`.
- Keep side-effect logic in small private functions; return a `CommandOutput` (or project-specific output type).
- Use `ModelContext`/SwiftData for persistence; use `@AppStorage` or `UserDefaults` for settings.
- Provide poetic + technical feedback strings consistently.
- Validate inputs and return clear error outputs on failure.
Example handler skeleton:
```swift
case .spawnCity(let name, let template):
    return handleSpawnCity(name: name, template: template)

private func handleSpawnCity(name: String?, template: String?) -> CommandOutput {
    // validation, model create, save context
    // return success or error output
}
```

### 5) Help text and documentation
- Add command usage, description, examples to `TerminalHelpView.swift` or the help provider.
- Include any poetic aliases and available flags.
- Update central help generation if it is programmatic.

### 6) Autocomplete and suggestions
- Add the verb and aliases to the suggestions/autocomplete list in `TerminalInputView` (or autocomplete provider).
- If the command supports flags, include flag suggestions and dynamic parameter suggestions (e.g., existing city names).

### 7) UI / Settings / Model
- If the command changes UI-visible state, ensure the UI observes the same storage (prefer `@AppStorage` keys used elsewhere).
- If it introduces new persistent data, add/modify SwiftData models and migrations if required.
- If it adds a settings key, define a consistent `@AppStorage` key string and default.

### 8) Validation, security, and safety
- Validate numeric ranges and string lengths; return friendly errors.
- Sanitize strings that will be used in file or shell operations.
- Avoid long-running work on the main thread. Use async Tasks for heavy operations.

### 9) Testing
- Unit tests for parser: inputs -> expected `TerminalCommand`.
- Unit tests for executor: simulate context and assert output and model state.
- UI tests (optional): ensure autocomplete and help include the new command.
- Add tests for edge cases and invalid input.

### 10) Logging & telemetry
- Use existing verbose/debug logging channels (e.g., debug/verbose) for detailed logs.
- Emit consistent debugging strings for failures and success events.

### 11) Accessibility & localization
- Keep output concise and clear.
- If localization is planned, wrap user-facing strings for future extraction.

## Example end-to-end checklist
- [ ] Enum case added
- [ ] Parser returns case for technical and poetic inputs
- [ ] Executor handles case and returns CommandOutput
- [ ] Help text updated with usage/examples
- [ ] Autocomplete suggestions updated
- [ ] Any `@AppStorage` keys declared and defaulted
- [ ] Unit tests for parser and executor added/updated
- [ ] UI updates performed and tested (if needed)
- [ ] Logging added where helpful
- [ ] Validation and error messages implemented
- [ ] Manual QA: run through typical and edge-case scenarios

## Stylistic rules & conventions
- Prefer small, single-responsibility functions in executor.
- Use poetic feedback strings to match project tone but keep machine-readable codes (e.g., `SPAWN_SUCCESS: ...`) for parsing and tests.
- Reuse existing helper utilities (flag extraction, boolean parsing, range validators).
- Keep keys and strings consistent (e.g., use "terminal.crtEffect" exactly where required).

## Troubleshooting tips
- If command isn't recognized: `rg` search for verb/alias in parser and suggestions.
- If UI doesn't update after settings command: confirm `@AppStorage` key names and that UI reads the same key.
- If parser returns wrong case: add unit tests to lock behavior and inspect tokenization logic.

## Minimal example for a new setting command
- Add `case setCustomSpeed(Double)` to enum.
- Parse `set speed 1.5` -> `.setCustomSpeed(1.5)`.
- Executor stores `UserDefaults.standard.set(1.5, forKey: "simulation.speed")`.
- Add `@AppStorage("simulation.speed") var simulationSpeed` in `SimulationEngine`.
- Update help and suggestions, add unit tests.

## Contact points in repo (quick mapping)
- Parser: `idle_01/ui/terminal/TerminalCommandParser.swift`
- Executor: `idle_01/ui/terminal/TerminalCommandExecutor.swift`
- Input UI / Autocomplete: `idle_01/ui/terminal/TerminalInputView.swift`
- Help: `idle_01/ui/terminal/TerminalHelpView.swift`
- Settings UI: `idle_01/ui/terminal/TerminalSettingsView.swift`
- Simulation hooks: `idle_01/game/SimulationEngine.swift`
- Debug overlay: `idle_01/ui/terminal/DebugStatsOverlay.swift`

Keep changes small and test often. Follow the checklist above before merging.
