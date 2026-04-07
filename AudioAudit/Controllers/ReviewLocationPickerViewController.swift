//
//  ReviewLocationPickerViewController.swift
//  AudioAudit
//
//  Created by Leo Lei on 3/30/26.
//

import UIKit
import MapKit
import CoreLocation

final class ReviewLocationPickerViewController: UIViewController {

    var onConfirm: ((CLLocationCoordinate2D) -> Void)?
    var onCancel: (() -> Void)?

    private let mapView = MKMapView()
    private let confirmButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    private var pinAnnotation: DraggablePointAnnotation?

    // to start somewhere specific
    var initialCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ReviewLocationPickerViewController loaded")

        title = "Pick Listening Location"
        view.backgroundColor = .systemBackground

        setupMapView()
        setupButtons()
        layoutUI()
        placeInitialPin()
    }

    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        view.addSubview(mapView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }

    private func setupButtons() {
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        confirmButton.setTitle("Confirm", for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)

        confirmButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)

        confirmButton.backgroundColor = .systemPink
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 12

        cancelButton.backgroundColor = .secondarySystemBackground
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.layer.cornerRadius = 12

        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        view.addSubview(confirmButton)
        view.addSubview(cancelButton)
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -16),

            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -12),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func placeInitialPin() {
        let fallback = CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431) // Austin
        let start = initialCoordinate ?? fallback

        let annotation = DraggablePointAnnotation(coordinate: start)
        pinAnnotation = annotation
        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(
            center: start,
            latitudinalMeters: 3000,
            longitudinalMeters: 3000
        )
        mapView.setRegion(region, animated: false)
    }

    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

        if let pinAnnotation {
            pinAnnotation.coordinate = coordinate
        }
    }

    @objc private func confirmTapped() {
        let coordinate = pinAnnotation?.coordinate
        dismiss(animated: true) { [weak self] in
            guard let coordinate else { return }
            print("ENTERING ONCONFIRM")
            self?.onConfirm?(coordinate)
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onCancel?()
        }
    }
}

// MARK: - MKMapViewDelegate

extension ReviewLocationPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = "ListeningPin"
        let view: MKMarkerAnnotationView

        if let reused = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            view = reused
            view.annotation = annotation
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }

        view.isDraggable = true
        view.canShowCallout = false
        view.markerTintColor = .systemPink
        view.glyphImage = UIImage(systemName: "music.note")

        return view
    }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState) {
        if newState == .ending || newState == .canceling {
            view.dragState = .none
        }
    }
}

// MARK: - DraggablePointAnnotation

final class DraggablePointAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
