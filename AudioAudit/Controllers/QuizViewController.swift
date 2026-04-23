import UIKit

final class QuizViewController: UIViewController {

    // callback

    var onQuizFinished: ((Int, Int) -> Void)?

    struct QuizQuestion {
        let friendName: String
        let prompt: String
        let options: [String]
        let correctOptionIndex: Int
    }

    enum QuestionType: CaseIterable {
        case rating
        case title
        case artist
    }

    // Data

    private var activities: [Activity] = []
    private var userNamesById: [String: String] = [:]

    private var questions: [QuizQuestion] = []
    private var currentQuestionIndex = 0
    private var score = 0

    // timer

    private let secondsPerQuestion = 10
    private let totalQuestionCount = 5
    private var remainingSeconds = 10
    private var timer: Timer?
    private var hasAnsweredCurrentQuestion = false

    // UI

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "Question 1 of 5"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .right
        label.text = "10s"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.progress = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let friendNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading quiz..."
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private lazy var optionButtons: [UIButton] = (0..<5).map { _ in
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.baseBackgroundColor = .audioRed
        config.baseForegroundColor = .white
        config.titleAlignment = .center
        button.configuration = config
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 62).isActive = true
        button.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        return button
    }

    private let optionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Not enough rated review activities to generate a quiz."
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Quiz"
        buildUI()
        showLoadingState()
        loadQuizData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }

    deinit {
        stopTimer()
    }

    private func buildUI() {
        optionButtons.forEach { optionsStack.addArrangedSubview($0) }

        view.addSubview(progressLabel)
        view.addSubview(timerLabel)
        view.addSubview(progressView)
        view.addSubview(friendNameLabel)
        view.addSubview(questionLabel)
        view.addSubview(feedbackLabel)
        view.addSubview(optionsStack)
        view.addSubview(emptyStateLabel)
        view.addSubview(loadingLabel)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            timerLabel.centerYAnchor.constraint(equalTo: progressLabel.centerYAnchor),
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            progressView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 12),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            friendNameLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 36),
            friendNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            friendNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            questionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),

            feedbackLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            feedbackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            feedbackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            optionsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            optionsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            optionsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 12),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // Data Loading

    private func loadQuizData() {
        guard let currentUser = UserService.shared.currentUser else {
            print("QUIZ ERROR: No current user found")
            showEmptyState(message: "Could not load your user data.")
            return
        }

        var friendIds = currentUser.friends
        if let myId = UserService.shared.currentUserId {
            friendIds.append(myId)
        }

        Task {
            do {
                let fetchedActivities = try await ActivityService.shared.fetchFriendsFeed(friendIds: friendIds)

                let uniqueUserIds = Set(fetchedActivities.map { $0.userId })
                let users = try await UserService.shared.fetchUsers(uids: Array(uniqueUserIds))

                let fetchedNames: [String: String] = uniqueUserIds.reduce(into: [:]) { result, uid in
                    result[uid] = users[uid]?.name ?? "Unknown"
                }

                let generatedQuestions = generateQuiz(
                    from: fetchedActivities,
                    userNames: fetchedNames,
                    questionCount: totalQuestionCount
                )

                await MainActor.run {
                    self.activities = fetchedActivities
                    self.userNamesById = fetchedNames
                    self.questions = generatedQuestions

                    guard !self.questions.isEmpty else {
                        self.showEmptyState(
                            message: "Not enough rated review activities from you and your friends to generate a quiz."
                        )
                        return
                    }

                    self.currentQuestionIndex = 0
                    self.score = 0
                    self.showQuizUI()
                    self.showQuestion()
                }
            } catch {
                await MainActor.run {
                    print("QUIZ ERROR loading activities: \(error.localizedDescription)")
                    self.showEmptyState(message: "Failed to load quiz activities.")
                }
            }
        }
    }

    // quiz generation

    func generateQuiz(
        from activities: [Activity],
        userNames: [String: String],
        questionCount: Int = 5
    ) -> [QuizQuestion] {

        let eligibleActivities = activities.filter { activity in
            guard activity.type == .review,
                  let rating = activity.rating,
                  (1...5).contains(rating),
                  !activity.song.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !activity.artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return false
            }
            return true
        }

        guard !eligibleActivities.isEmpty else { return [] }

        let selectedActivities = Array(eligibleActivities.shuffled().prefix(questionCount))
        let allTitles = Array(Set(eligibleActivities.map { $0.song }))
        let allArtists = Array(Set(eligibleActivities.map { $0.artist }))

        var generatedQuestions: [QuizQuestion] = []

        for activity in selectedActivities {
            guard let rating = activity.rating else { continue }

            let friendName = userNames[activity.userId] ?? "Your friend"
            let shuffledTypes = QuestionType.allCases.shuffled()

            var builtQuestion: QuizQuestion?

            for questionType in shuffledTypes {
                switch questionType {
                case .rating:
                    builtQuestion = buildRatingQuestion(
                        activity: activity,
                        friendName: friendName,
                        rating: rating
                    )

                case .title:
                    builtQuestion = buildTitleQuestion(
                        activity: activity,
                        friendName: friendName,
                        rating: rating,
                        allTitles: allTitles
                    )

                case .artist:
                    builtQuestion = buildArtistQuestion(
                        activity: activity,
                        friendName: friendName,
                        rating: rating,
                        allArtists: allArtists
                    )
                }

                if builtQuestion != nil { break }
            }

            if let builtQuestion {
                generatedQuestions.append(builtQuestion)
            }
        }

        return generatedQuestions
    }

    private func buildRatingQuestion(
        activity: Activity,
        friendName: String,
        rating: Int
    ) -> QuizQuestion {
        let prompt = "\(friendName) rated “\(activity.song)” by \(activity.artist) with what rating?"
        let options = ["1 ★", "2 ★", "3 ★", "4 ★", "5 ★"]

        return QuizQuestion(
            friendName: friendName,
            prompt: prompt,
            options: options,
            correctOptionIndex: rating - 1
        )
    }

    private func buildTitleQuestion(
        activity: Activity,
        friendName: String,
        rating: Int,
        allTitles: [String]
    ) -> QuizQuestion? {
        let correctTitle = activity.song

        let wrongTitles = allTitles
            .filter { $0 != correctTitle }
            .shuffled()
            .prefix(4)

        guard wrongTitles.count == 4 else { return nil }

        var options = Array(wrongTitles)
        options.append(correctTitle)
        options.shuffle()

        guard let correctIndex = options.firstIndex(of: correctTitle) else { return nil }

        let prompt = "\(friendName) gave a rating of \(rating) ★ to which song/album?"

        return QuizQuestion(
            friendName: friendName,
            prompt: prompt,
            options: options,
            correctOptionIndex: correctIndex
        )
    }

    private func buildArtistQuestion(
        activity: Activity,
        friendName: String,
        rating: Int,
        allArtists: [String]
    ) -> QuizQuestion? {
        let correctArtist = activity.artist

        let wrongArtists = allArtists
            .filter { $0 != correctArtist }
            .shuffled()
            .prefix(4)

        guard wrongArtists.count == 4 else { return nil }

        var options = Array(wrongArtists)
        options.append(correctArtist)
        options.shuffle()

        guard let correctIndex = options.firstIndex(of: correctArtist) else { return nil }

        let prompt = "\(friendName) rated “\(activity.song)” with \(rating) ★. Who is the artist?"

        return QuizQuestion(
            friendName: friendName,
            prompt: prompt,
            options: options,
            correctOptionIndex: correctIndex
        )
    }

    //Question Flow

    private func showQuestion() {
        guard currentQuestionIndex < questions.count else {
            finishQuiz()
            return
        }

        hasAnsweredCurrentQuestion = false
        feedbackLabel.text = ""

        let question = questions[currentQuestionIndex]

        progressLabel.text = "Question \(currentQuestionIndex + 1) of \(questions.count)"
        friendNameLabel.text = question.friendName
        questionLabel.text = question.prompt

        for (index, button) in optionButtons.enumerated() {
            button.tag = index
            button.isEnabled = true
            button.isHidden = index >= question.options.count

            if index < question.options.count {
                updateButton(button, title: question.options[index], color: .audioRed)
            }
        }

        startTimer()
    }

    @objc private func answerTapped(_ sender: UIButton) {
        guard !hasAnsweredCurrentQuestion else { return }
        hasAnsweredCurrentQuestion = true

        stopTimer()

        let selectedIndex = sender.tag
        let correctIndex = questions[currentQuestionIndex].correctOptionIndex

        optionButtons.forEach { $0.isEnabled = false }

        if selectedIndex == correctIndex {
            score += 1
            feedbackLabel.text = "Correct"
            updateButton(
                sender,
                title: questions[currentQuestionIndex].options[selectedIndex],
                color: .systemGreen
            )
        } else {
            feedbackLabel.text = "Incorrect"
            updateButton(
                sender,
                title: questions[currentQuestionIndex].options[selectedIndex],
                color: .systemRed
            )

            if correctIndex < optionButtons.count {
                let correctButton = optionButtons[correctIndex]
                updateButton(
                    correctButton,
                    title: questions[currentQuestionIndex].options[correctIndex],
                    color: .systemGreen
                )
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.goToNextQuestion()
        }
    }

    private func handleTimeExpired() {
        guard !hasAnsweredCurrentQuestion else { return }
        hasAnsweredCurrentQuestion = true

        stopTimer()
        optionButtons.forEach { $0.isEnabled = false }
        feedbackLabel.text = "Time’s up"

        let correctIndex = questions[currentQuestionIndex].correctOptionIndex
        if correctIndex < optionButtons.count {
            let correctButton = optionButtons[correctIndex]
            updateButton(
                correctButton,
                title: questions[currentQuestionIndex].options[correctIndex],
                color: .systemGreen
            )
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.goToNextQuestion()
        }
    }

    private func goToNextQuestion() {
        currentQuestionIndex += 1
        showQuestion()
    }

    //Timer

    private func startTimer() {
        stopTimer()
        remainingSeconds = secondsPerQuestion
        updateTimerUI()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { return }

            self.remainingSeconds -= 1
            self.updateTimerUI()

            if self.remainingSeconds <= 0 {
                timer.invalidate()
                self.handleTimeExpired()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateTimerUI() {
        timerLabel.text = "\(remainingSeconds)s"
        progressView.progress = Float(remainingSeconds) / Float(secondsPerQuestion)
    }

    //Finish

    private func finishQuiz() {
        stopTimer()
        onQuizFinished?(score, questions.count)
        dismissOrPop()
    }

    // UI States

    private func showLoadingState() {
        progressLabel.isHidden = true
        timerLabel.isHidden = true
        progressView.isHidden = true
        friendNameLabel.isHidden = true
        questionLabel.isHidden = true
        feedbackLabel.isHidden = true
        optionsStack.isHidden = true
        emptyStateLabel.isHidden = true

        activityIndicator.startAnimating()
        loadingLabel.isHidden = false
    }

    private func showEmptyState(message: String) {
        stopTimer()

        progressLabel.isHidden = true
        timerLabel.isHidden = true
        progressView.isHidden = true
        friendNameLabel.isHidden = true
        questionLabel.isHidden = true
        feedbackLabel.isHidden = true
        optionsStack.isHidden = true

        activityIndicator.stopAnimating()
        loadingLabel.isHidden = true

        emptyStateLabel.text = message
        emptyStateLabel.isHidden = false
    }

    private func showQuizUI() {
        activityIndicator.stopAnimating()
        loadingLabel.isHidden = true
        emptyStateLabel.isHidden = true

        progressLabel.isHidden = false
        timerLabel.isHidden = false
        progressView.isHidden = false
        friendNameLabel.isHidden = false
        questionLabel.isHidden = false
        feedbackLabel.isHidden = false
        optionsStack.isHidden = false
    }

    private func dismissOrPop() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Button Helpers

    private func updateButton(_ button: UIButton, title: String, color: UIColor) {
        var config = button.configuration ?? UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = color
        config.baseForegroundColor = .white
        button.configuration = config
    }
}
