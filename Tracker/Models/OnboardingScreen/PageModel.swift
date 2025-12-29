import UIKit

struct PageModel {
    let image: UIImage?
    let text: String
}

extension PageModel {
    static let aboutTracking = PageModel(
        image: .onboarding1,
        text: "Отслеживайте только то, что хотите"
    )
    static let aboutWaterAndYoga = PageModel(
        image: .onboarding2,
        text: "Даже если это\nне литры воды и йога"
    )
}
