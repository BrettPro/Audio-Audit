//
//  QuizHubViewController.swift
//  AudioAudit
//
//  Created by Leo Lei on 4/23/26.
//


import UIKit

final class QuizHubViewController: UIViewController {

    // MARK: - Data

    /// Stores raw quiz scores as (score, totalQuestions)
    private var quizHistory: [(score: Int, total: Int)] = []

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Friend Quiz"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Show us your knowledge of your friends' music taste!"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let statsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Stats"
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let quizzesTakenTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Quizzes Taken"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let quizzesTakenValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let averageScoreTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Avg Score (Last 10)"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let averageScoreValueLabel: UILabel = {
        let label = UILabel()
        label.text = "--"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let startQuizButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Start Quiz"
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        button.configuration = config
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Quiz"

        buildUI()
        wireActions()
        refreshStatsUI()
    }

    // MARK: - Setup

    private func buildUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(statsContainerView)
        view.addSubview(startQuizButton)

        statsContainerView.addSubview(statsTitleLabel)
        statsContainerView.addSubview(quizzesTakenTitleLabel)
        statsContainerView.addSubview(quizzesTakenValueLabel)
        statsContainerView.addSubview(averageScoreTitleLabel)
        statsContainerView.addSubview(averageScoreValueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            statsContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            statsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statsTitleLabel.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 20),
            statsTitleLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),
            statsTitleLabel.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -20),

            quizzesTakenTitleLabel.topAnchor.constraint(equalTo: statsTitleLabel.bottomAnchor, constant: 24),
            quizzesTakenTitleLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),

            quizzesTakenValueLabel.topAnchor.constraint(equalTo: quizzesTakenTitleLabel.bottomAnchor, constant: 6),
            quizzesTakenValueLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),

            averageScoreTitleLabel.topAnchor.constraint(equalTo: quizzesTakenValueLabel.bottomAnchor, constant: 24),
            averageScoreTitleLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),

            averageScoreValueLabel.topAnchor.constraint(equalTo: averageScoreTitleLabel.bottomAnchor, constant: 6),
            averageScoreValueLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),
            averageScoreValueLabel.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -24),

            startQuizButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            startQuizButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            startQuizButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28)
        ])
    }

    private func wireActions() {
        startQuizButton.addTarget(self, action: #selector(startQuizTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func startQuizTapped() {
        let quizVC = QuizViewController()

        quizVC.onQuizFinished = { [weak self] score, totalQuestions in
            guard let self else { return }

            self.quizHistory.append((score: score, total: totalQuestions))
            self.refreshStatsUI()
        }

        //navigationController?.pushViewController(quizVC, animated: true)
        quizVC.modalPresentationStyle = .fullScreen
        present(quizVC, animated: true)
    }

    // MARK: - Stats

    private func refreshStatsUI() {
        quizzesTakenValueLabel.text = "\(quizHistory.count)"
        averageScoreValueLabel.text = formattedAverageOfLast10()
    }

    private func formattedAverageOfLast10() -> String {
        guard !quizHistory.isEmpty else { return "--" }

        let lastTen = Array(quizHistory.suffix(10))

        let percentages: [Double] = lastTen.map { result in
            guard result.total > 0 else { return 0 }
            return (Double(result.score) / Double(result.total)) * 100.0
        }

        guard !percentages.isEmpty else { return "--" }

        let average = percentages.reduce(0, +) / Double(percentages.count)
        return String(format: "%.1f%%", average)
    }
}
