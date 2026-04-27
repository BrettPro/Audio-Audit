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
    private var annotations: [ActivityAnnotation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupMapView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFriendActivities()
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

    private func loadFriendActivities() {
        guard let currentUser = UserService.shared.currentUser else {
            print("MAP ERROR: No current user found")
            return
        }

        var friendIds = Set(currentUser.friends)
        
        var includeMeOnMap: Bool {
            UserDefaults.standard.bool(forKey: "showMap")
        }

        if includeMeOnMap {
            if let myId = UserService.shared.currentUserId {
                friendIds.insert(myId)
            }
        } else {
            if let myId = UserService.shared.currentUserId {
                friendIds.remove(myId)
            }
        }

        let finalFriendIds = Array(friendIds)

        Task {
            do {
                let activities = try await ActivityService.shared.fetchFriendsFeed(friendIds: finalFriendIds)
                let geoActivities = activities.filter { $0.latitude != nil && $0.longitude != nil }

                let uniqueUserIds = Set(geoActivities.map { $0.userId })
                let users = try await UserService.shared.fetchUsers(uids: Array(uniqueUserIds))

                let newAnnotations: [ActivityAnnotation] = geoActivities.compactMap { activity in
                    guard let lat = activity.latitude, let lon = activity.longitude else { return nil }
                    let username = users[activity.userId]?.name ?? "Unknown"
                    return ActivityAnnotation(
                        activity: activity,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        username: username
                    )
                }

                await MainActor.run {
                    self.mapView.removeAnnotations(self.annotations)
                    self.annotations = newAnnotations
                    self.mapView.addAnnotations(self.annotations)
                    self.centerMapOnPins()
                }
            } catch {
                print("Error loading map activities: \(error.localizedDescription)")
            }
        }
    }

    private func centerMapOnPins() {
        guard !annotations.isEmpty else { return }

        let latitudes = annotations.map { $0.coordinate.latitude }
        let longitudes = annotations.map { $0.coordinate.longitude }

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
        performSegue(withIdentifier: "MapToExpand", sender: annotation)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapToExpand" {
            let annotation = sender as! ActivityAnnotation
            let destinationVC = segue.destination as! ExpandReviewVC
            destinationVC.activity = annotation.activity
        }
    }
//
//    private func showActivityDetails(for annotation: ActivityAnnotation) {
//        let activity = annotation.activity
//
//        let alert = UIAlertController(
//            title: "\(activity.song) — \(activity.artist)",
//            message: """
//            User: \(annotation.username)
//            Type: \(activity.type.rawValue)
//            Rating: \(activity.rating.map(String.init) ?? "N/A")
//            Review: \(activity.review ?? "No review")
//            """,
//            preferredStyle: .alert
//        )
//
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
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
