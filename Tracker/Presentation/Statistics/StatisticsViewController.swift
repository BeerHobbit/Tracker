import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var recordsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.text = "0"
        return label
    }()
    
    private lazy var recordsCountSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.text = "statistics.records_count_subtitle".localized
        return label
    }()
    
    private lazy var recordsCountStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            recordsCountLabel,
            recordsCountSubtitleLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var recordsCountCardView: UIView = {
        let view = UIView()
        view.addSubview(recordsCountStackView)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emtyStatisticsImageView: UIImageView = {
        let imageView = UIImageView(image: .emptyStatistics)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyStatisticsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.text = "statistics.empty_statistics".localized
        return label
    }()
    
    private lazy var emptyStatisticsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emtyStatisticsImageView,
            emptyStatisticsLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Private Properties
    
    private let trackerRecordStore: RecordsCountProtocol
    private var recordsCount: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Initializer
    
    convenience init() {
        let store = TrackerRecordStore()
        self.init(trackerRecordStore: store)
    }
    
    init(trackerRecordStore: RecordsCountProtocol) {
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("❌init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setupUI()
        updateUI()
    }
    
    // MARK: - Overrides
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recordsCountCardView.applyGradientBorder(
            colors: [
                .gradientBlue,
                .gradientGreen,
                .gradientRed
            ],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5),
            lineWidth: 1,
            cornerRadius: recordsCountCardView.layer.cornerRadius
        )
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        trackerRecordStore.recordsCountDelegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviews([
            recordsCountCardView,
            emptyStatisticsStackView
        ])
        
        setupConstraints()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navigationItem.title = "statistics.navigation_title".localized
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            recordsCountCardView.heightAnchor.constraint(equalToConstant: 90),
            recordsCountCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            recordsCountCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recordsCountCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            recordsCountStackView.topAnchor.constraint(equalTo: recordsCountCardView.topAnchor, constant: 12),
            recordsCountStackView.leadingAnchor.constraint(equalTo: recordsCountCardView.leadingAnchor, constant: 12),
            recordsCountStackView.trailingAnchor.constraint(equalTo: recordsCountCardView.trailingAnchor, constant: -12),
            recordsCountStackView.bottomAnchor.constraint(equalTo: recordsCountCardView.bottomAnchor, constant: -12),
            
            emtyStatisticsImageView.heightAnchor.constraint(equalToConstant: 80),
            emtyStatisticsImageView.widthAnchor.constraint(equalTo: emtyStatisticsImageView.heightAnchor),
            
            emptyStatisticsStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStatisticsStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        recordsCountLabel.text = String(recordsCount)
        if recordsCount == 0 {
            recordsCountCardView.isHidden = true
            emptyStatisticsStackView.isHidden = false
        } else {
            recordsCountCardView.isHidden = false
            emptyStatisticsStackView.isHidden = true
        }
    }
    
}

extension StatisticsViewController: RecordsCountDelegate {
    func didUpdateRecordsCount(_ count: Int) {
        recordsCount = count
    }
}
