//
//  LocationFileParser.swift
//  LocationSimulator
//
//  Created by Anton Gubarenko on 28.08.2023.
//

import Foundation
import MapKit

protocol CodableLocation: Codable {
    var location: CLLocation {get}
}

struct LocationData: Codable {
    let t: Double
    let c: Double
    let ha: Double
    let alt: Double
    let va: Double
    let lon: Double
    let sa: Double
    let lat: Double
    let s: Double
}

extension LocationData: CodableLocation {
    var location: CLLocation {
        .init(coordinate: CLLocationCoordinate2DMake(lat, lon), altitude: alt, horizontalAccuracy: ha, verticalAccuracy: va, course: c, courseAccuracy: 1.0, speed: s, speedAccuracy: sa, timestamp: Date(timeIntervalSince1970: t))
    }
}

struct  LocationFileParser {    
    func parseJSONFromFile<T: CodableLocation>(named fileName: String) -> [T]? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "data") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                let locations = try decoder.decode([T].self, from: data)
                return locations
            } catch {
                print("Error parsing JSON: \(error)")
            }
        } else {
            print("File not found")
        }
        return nil
    }
}
