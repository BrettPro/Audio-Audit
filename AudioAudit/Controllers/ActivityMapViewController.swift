//
//  ActivityMapViewController.swift
//  AudioAudit
//

import UIKit
import MapKit
import CoreLocation

final class ActivityAnnotation: NSObject, MKAnnotation {
    let activity: Activity
    let coordinate: CLLocationCoordinate2D
    let username: String

    var title: String? {
        activity.song
    }

    var subtitle: String? {
        "\(activity.artist) • \(username)"
    }

    init(activity: Activity, coordinate: CLLocationCoordinate2D, username: String) {
        self.activity = activity
        self.coordinate = coordinate
        self.username = username
        super.init()
    }
}

final class ActivityMapViewController: UIViewController {

    private let mapView = MKMapView()

    // Temporary sample data until Activity has latitude/longitude
    private var sampleAnnotations: [ActivityAnnotation] = []

    // Temporary username lookup until real user fetching exists
    private let userLookup: [String: String] = [
        "user_1": "Alex",
        "user_2": "Jordan",
        "user_3": "Taylor",
        "user_4": "Casey"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Activity Map"
        view.backgroundColor = .systemBackground

        setupMapView()
        loadSamplePins()
        addSamplePinsToMap()
        centerMapOnPins()
    }

    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.showsUserLocation = false

        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func loadSamplePins() {
        let sampleActivities: [(activity: Activity, coordinate: CLLocationCoordinate2D)] = [
            (
                activity: Activity(
                    id: "1",
                    userId: "user_1",
                    type: .review,
                    song: "Bohemian Rhapsody",
                    artist: "Queen",
                    rating: 5,
                    review: "Classic. Never gets old.",
                    timestamp: Date()
                ),
                coordinate: CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431)
            ),
            (
                activity: Activity(
                    id: "2",
                    userId: "user_2",
                    type: .review,
                    song: "Blinding Lights",
                    artist: "The Weeknd",
                    rating: 4,
                    review: "Great late-night song.",
                    timestamp: Date()
                ),
                coordinate: CLLocationCoordinate2D(latitude: 30.2705, longitude: -97.7500)
            ),
            (
                activity: Activity(
                    id: "3",
                    userId: "user_3",
                    type: .listen,
                    song: "Levitating",
                    artist: "Dua Lipa",
                    rating: nil,
                    review: nil,
                    timestamp: Date()
                ),
                coordinate: CLLocationCoordinate2D(latitude: 30.2625, longitude: -97.7360)
            ),
            (
                activity: Activity(
                    id: "4",
                    userId: "user_4",
                    type: .review,
                    song: "Bad Guy",
                    artist: "Billie Eilish",
                    rating: 3,
                    review: "Catchy but overplayed.",
                    timestamp: Date()
                ),
                coordinate: CLLocationCoordinate2D(latitude: 30.2740, longitude: -97.7420)
            )
        ]

        sampleAnnotations = sampleActivities.map { item in
            let username = userLookup[item.activity.userId] ?? "Unknown"
            return ActivityAnnotation(
                activity: item.activity,
                coordinate: item.coordinate,
                username: username
            )
        }
    }

    private func addSamplePinsToMap() {
        mapView.addAnnotations(sampleAnnotations)
    }

    private func centerMapOnPins() {
        guard !sampleAnnotations.isEmpty else { return }

        let latitudes = sampleAnnotations.map { $0.coordinate.latitude }
        let longitudes = sampleAnnotations.map { $0.coordinate.longitude }

        guard let minLat = latitudes.min(),
              let maxLat = latitudes.max(),
              let minLon = longitudes.min(),
              let maxLon = longitudes.max() else { return }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.8, 0.03),
            longitudeDelta: max((maxLon - minLon) * 1.8, 0.03)
        )

        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)
    }

    private func showActivityDetails(for annotation: ActivityAnnotation) {
        let activity = annotation.activity

        let alert = UIAlertController(
            title: "\(activity.song) — \(activity.artist)",
            message: """
            User: \(annotation.username)
            Type: \(activity.type.rawValue)
            Rating: \(activity.rating.map(String.init) ?? "N/A")
            Review: \(activity.review ?? "No review")

            TODO: fetch full activity by ID: \(activity.id ?? "nil")
            """,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension ActivityMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let activityAnnotation = annotation as? ActivityAnnotation else {
            return nil
        }

        let identifier = "ActivityPin"
        let view: MKMarkerAnnotationView

        if let reused = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            view = reused
            view.annotation = activityAnnotation
        } else {
            view = MKMarkerAnnotationView(annotation: activityAnnotation, reuseIdentifier: identifier)
        }

        view.canShowCallout = true
        view.isDraggable = false
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        view.titleVisibility = .hidden
        view.subtitleVisibility = .hidden

        switch activityAnnotation.activity.type {
        case .review:
            view.markerTintColor = .systemPink
            view.glyphImage = UIImage(systemName: "star.fill")
        case .listen:
            view.markerTintColor = .systemBlue
            view.glyphImage = UIImage(systemName: "music.note")
        }

        return view
    }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? ActivityAnnotation else { return }
        showActivityDetails(for: annotation)
    }
}
