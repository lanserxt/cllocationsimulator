# cllocationsimulator

[![Swift Version](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-lightgrey.svg)](https://developer.apple.com)

**cllocationsimulator** is a Swift package that provides a convenient interface for simulating `CLLocation` objects. It allows you to simulate location data for iOS, macOS, tvOS, and watchOS applications during development and testing. This can be incredibly useful when you need to test location-based features in your app without physically moving to different locations.

## Features

- Simulate `CLLocation` objects with custom coordinates, altitude, course, speed, and more.
- Define routes with a sequence of locations for realistic movement simulation.
- Set up geofences and test how your app responds to location-based triggers.
- Easily switch between simulated and real location data during development.

## Requirements

- Swift 5.0+
- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+

## Installation

### Swift Package Manager

To integrate `cllocationsimulator` into your Xcode project using Swift Package Manager, follow these steps:

1. Open your project in Xcode.
2. Go to "File" > "Swift Packages" > "Add Package Dependency..."
3. Enter the package URL: `https://github.com/yourusername/cllocationsimulator.git` (replace `yourusername` with your GitHub username).
4. Follow the prompts to specify version, branch, or tag.
5. Click "Next" and then "Finish."

### Manual

You can also manually add `cllocationsimulator` to your project:

1. Clone or download the repository.
2. Drag the `cllocationsimulator` directory into your Xcode project.

## Usage

1. Import the `cllocationsimulator` module in your Swift file:

   ```swift
   import cllocationsimulator
   ```

2. Create an instance of `LocationSimulator`:

   ```swift
   let locationSimulator = LocationSimulator()
   ```

3. Simulate a single location:

   ```swift
   let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
   let location = CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5, course: 0, speed: 0, timestamp: Date())
   locationSimulator.simulateLocation(location)
   ```

4. Simulate a route:

   ```swift
   let route = [
       CLLocation(latitude: 37.7749, longitude: -122.4194),
       CLLocation(latitude: 34.0522, longitude: -118.2437),
       // Add more locations to the route
   ]
   locationSimulator.simulateRoute(route, timeInterval: 5.0)
   ```

5. Simulate geofence triggers:

   ```swift
   let geofence = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), radius: 100, identifier: "Geofence")
   locationSimulator.addGeofence(geofence)

   // Listen for geofence triggers
   NotificationCenter.default.addObserver(self, selector: #selector(geofenceTriggered(_:)), name: .CLLSGeofenceTriggered, object: nil)

   @objc func geofenceTriggered(_ notification: Notification) {
       if let region = notification.object as? CLRegion {
           print("Geofence triggered: \(region.identifier)")
       }
   }
   ```

6. Switch between real and simulated locations:

   ```swift
   // Enable simulated locations
   locationSimulator.enable()

   // Disable simulated locations and revert to real location updates
   locationSimulator.disable()
   ```

For more detailed usage instructions and examples, please refer to the documentation or examples provided in the repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the need for easy location simulation during app development.

## Contact

If you have any questions or suggestions, please feel free to [open an issue](https://github.com/yourusername/cllocationsimulator/issues) on GitHub.

---

**Note:** Replace `yourusername` with your GitHub username in the package URL and update the content of this README as needed to provide accurate and up-to-date information about your Swift package, including the installation process, usage instructions, and any additional features or details specific to your package.
