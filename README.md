# CLLocationSimulator SPM 📦

[![Swift Version](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-lightgrey.svg)](https://developer.apple.com)

**cllocationsimulator** is a Swift package that provides a convenient interface for simulating `CLLocation` objects. It allows you to simulate location data for iOS, macOS, tvOS, and watchOS applications during development and testing. This can be incredibly useful when you need to test location-based features in your app without physically moving to different locations.

## Features

- Simulate `CLLocation` objects with custom coordinates, altitude, course, speed, and more 🌎
- Define routes with a sequence of locations for realistic movement simulation 🚏
- Easily switch between simulated and real location data during development
- Supports 2️⃣ modes for simulation: based on selected interval or original location timestamp

## Requirements

- Swift 5.0+
- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+

## Installation

### Swift Package Manager

To integrate `CLLocationSimulator` into your Xcode project using Swift Package Manager, follow these steps:

1. Open your project in Xcode.
2. Go to "File" > "Swift Packages" > "Add Package Dependency..."
3. Enter the package URL: `https://github.com/yourusername/cllocationsimulator.git` (replace `yourusername` with your GitHub username).
4. Follow the prompts to specify version, branch, or tag.
5. Click "Next" and then "Finish."

### Manual

You can also manually add `CLLocationSimulator` to your project:

1. Clone or download the repository.
2. Drag the `CLLocationSimulator` directory into your Xcode project.

## Usage

1. Import the `CLLocationSimulator` module in your Swift file:

   ```swift
   import CLLocationSimulator
   ```

2. Create an instance of `LocationSimulator`:

   ```swift
   let locationsToSimulate: [CLLocation] = []
   let locationSimulator = CLLocationBaseSimulator(locations: locationsToSimulate)
   ```

   In [Example](Example/LocationSimulatorExample/FileParser/) you can check how to parse JSON GPS data to CLLocation and pass it to location simulator constructor

3. Track changes of needed parameters:

   ```swift
   /// Change of simulation status
   /// - Parameter value: is active
   func activeStateChanged(value: Bool) {}
    
   /// Change of progress of simulation
   /// - Parameter value: new progress
   func progressChanged(value: Double) {}
    
   /// Change of locations
   /// - Parameter value: new locations
   func locationsChanged(value: [CLLocation]) {}
   ```

5. You can use CLLocationBaseSimulator as a raw locations provider but there are 3 common implementation which you already can use. They are also available in SPM.
   
### CLLocationCombineSimulator

Combine implementation to track only needed properties. If redrawing performance in SwiftUI, in example, is critical.

```swift
/// Publisher for Locations update
public var locationsPublisher: AnyPublisher<[CLLocation], Never>
    
/// Publisher for Progress update
public var progressPublisher: AnyPublisher<Double, Never>

/// Publisher for Status update
public var isActivePublisher: AnyPublisher<Bool, Never>
```

### CLLocationPublisherSimulator

Combine implementation also but change of any property triggers whole view update for SwiftUI. If performance is not so critical.

```swift
/// Publisher for Locations update
public var locationsPublisher: AnyPublisher<[CLLocation], Never>
    
/// Publisher for Progress update
public var progressPublisher: AnyPublisher<Double, Never>

/// Publisher for Status update
public var isActivePublisher: AnyPublisher<Bool, Never>
   ```

### CLLocationObservableSimulator

New SwiftUI implementation for iOS 17. Same syntax-sugar as ObservableObject but changes of only tracked properties are causing the redraw. [More info here](https://developer.apple.com/documentation/observation).

```swift
@Observable
public final class CLLocationObservableSimulator: CLLocationBaseSimulator {
    
/// Actual locations Publisher
public var locations: [CLLocation] = []
    
/// Actual progress Publisher
public var progress: Double = 0.0
    
/// Actual active status Publisher
public var isActive: Bool = false
```

5. Start initial location emit. First point of locations passed to constructor will be sent.

```swift
locationSimulator.initialLocationEmit()
```

6. Switch between modes. By default, emit on interval is set.

```swift
locationSimulator.simulationMode = .emitOnInterval(1.0)
//or
locationSimulator.simulationMode = .emitOnTimestamp
```

7. To control simuation you can use plain interface.

```swift
func start()

func pause()

func reset()
```

For more detailed usage instructions and examples, please refer to the  [Example](Example/LocationSimulatorExample) provided in the repository.

## Example App

Simple SwiftUI app to track progress and changes + for iOS 17 new Map features (pin, path, scale)

<img src="/Images/Combine.png" alt="Combine App" width="200"/> <img src="/Images/Publisher.png" alt="Publisher App" width="200"/> <img src="/Images/Observed.png" alt="Observed App" width="200"/>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the need for easy location simulation during app development.

## Contact

<div id="badges">
  <a href="https://www.linkedin.com/in/antongubarenko">
    <img src="https://img.shields.io/badge/LinkedIn-blue?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn Badge"/>
  </a>
  <a href="https://twitter.com/AntonGubarenko">
    <img src="https://img.shields.io/badge/Twitter-blue?style=for-the-badge&logo=twitter&logoColor=white" alt="Twitter Badge"/>
  </a>
</div>

If you have any questions or suggestions, please feel free to [open an issue](https://github.com/yourusername/cllocationsimulator/issues) on GitHub.

---
