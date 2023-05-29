import SwiftUI
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var userLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
        locationManager.requestWhenInUseAuthorization()
    }
    
    func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
    
    func bearing(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> CLLocationDirection {
        let lat1 = source.latitude.toRadians()
        let lon1 = source.longitude.toRadians()
        let lat2 = destination.latitude.toRadians()
        let lon2 = destination.longitude.toRadians()
        
        let y = sin(lon2 - lon1) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1)
        let bearing = atan2(y, x).toDegrees()
        
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        userLocation = location
    }
}

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180
    }
    
    func toDegrees() -> Double {
        return self * 180 / .pi
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var qiblaDirection: CLLocationDirection = 0.0
    
    var body: some View {
        VStack {
            Text("Qibla Finder")
                .font(.largeTitle)
                .padding()
            
            Image("Kaabah") 
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Text("Qibla Direction: \(Int(qiblaDirection))°")
                .font(.title)
            
            Button("Find Qibla") {
                findQiblaDirection()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            locationManager.startUpdatingHeading()
        }
        .onDisappear {
            locationManager.stopUpdatingHeading()
        }
    }
    
    func findQiblaDirection() {
        guard let userLocation = locationManager.userLocation else {
            return
        }
        
        let qiblaCoordinates = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
        let qiblaDirection = locationManager.bearing(from: userLocation.coordinate, to: qiblaCoordinates)
        self.qiblaDirection = qiblaDirection
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


