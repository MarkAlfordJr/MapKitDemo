//
//  ContentView.swift
//  MapRoutes
//
//  Created by Mark Alford on 7/25/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    //used as paramter value for MapView
    @State private var directions: [String] = []
    @State private var showDirections = false
    
    var body: some View {
        VStack{
            //6 load up Mapview
            MapView(directions: $directions)
            Button(action: {
                self.showDirections.toggle()
            }, label: {
                Text("show directions")
            })
            .disabled(directions.isEmpty)
            .padding()
            
        }//vstack
        //sheet shows the steps when button is pressed
        .sheet(isPresented: $showDirections, content: {
            VStack{
                Text("Directions")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Divider().background(Color.blue)
                
                //make list to display steps from directions array, WHICH COMES FROM MKDirections func
                List{
                    ForEach(0..<self.directions.count, id: \.self) { item in
                        Text(self.directions[item])
                            .padding()
                    }
                }
            }
        })
    }
}

//1 set mapView Rep
struct MapView: UIViewRepresentable {
    //2 make the mapView
    typealias UIViewType = MKMapView
    
    //when ever mapView is made, mae array of strings for directions
    @Binding var directions: [String]
    
    //make the coordinator func return the class
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    
    //3 makes the view to diplay
    func makeUIView(context: Context) -> MKMapView {
        
        //5 activate MapView
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        //7 make coordinates to start map in
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.71, longitude: -74), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
        //8 set the region of the map for coordinates to start in
        mapView.setRegion(region, animated: true)
        
        
        //MARK: - Map PlaceMarkers
        //make request, then directions, then calculate directions
        
        //placemark for new york
        let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.71, longitude: -74))
        
        
        //placment for boston
        let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.36, longitude: -71.05))
        
        
        //MARK: - Directions
        
        
        //make direction between 2 placemarks
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .automobile
        
        //Directions
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            
            //checks if route is good
            guard let route = response?.routes.first else { return }
            
            //adds annotation on map, for both placemarkers
            mapView.addAnnotations([p1, p2])
            mapView.addOverlay(route.polyline)
            //see entire line between the 2 placemarkers
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true) //20 padding for rect
                
            //get route steps, turn into array of instructions, filter out no string values
            self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
            
        }
        
        
        //return
        return mapView
    }
    
    //4 tracks and change
    func updateUIView(_ uiView: MKMapView, context: Context) {
        //
    }
    
    
    //MARK: - Map Delegate for direction line
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        
        //func for rendering line
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            let render = MKPolylineRenderer(overlay: overlay)
            render.strokeColor = .red
            render.lineWidth = 5
            
            return render
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
    
}
