import Foundation

@objc
final class ScheduleValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let schedule = value as? Set<Weekday> else { return nil }
        return try? JSONEncoder().encode(schedule)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode(Set<Weekday>.self, from: data as Data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            ScheduleValueTransformer(),
            forName: NSValueTransformerName(String(describing: ScheduleValueTransformer.self))
        )
    }
    
}
