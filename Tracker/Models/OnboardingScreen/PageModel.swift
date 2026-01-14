import UIKit

struct PageModel {
    let image: UIImage?
    let text: String
}

extension PageModel {
    static let aboutTracking = PageModel(
        image: .onboarding1,
        text: "onboarding_page.about_tracking".localized
    )
    static let aboutWaterAndYoga = PageModel(
        image: .onboarding2,
        text: "onboarding_page.about_water_and_yoga".localized
    )
}
