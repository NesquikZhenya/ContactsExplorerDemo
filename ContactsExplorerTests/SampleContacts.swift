//
//  SampleContacts.swift
//  ContactsExplorerTests
//

import UIKit
@testable import ContactsExplorer

nonisolated enum SampleContacts {

    /// Everything populated: two phone numbers, two emails, a birthday and a photo.
    static let complete = Contact(
        id: "contact-emma",
        givenName: "Emma",
        familyName: "Stone",
        fullName: "Emma Stone",
        organizationName: "",
        phoneNumbers: [
            Contact.LabeledValue(label: "mobile", value: "+972 54-123-4567"),
            Contact.LabeledValue(label: "work", value: "03-612-3456")
        ],
        emails: [
            Contact.LabeledValue(label: "home", value: "emma@example.com"),
            Contact.LabeledValue(label: "work", value: "emma.stone@example.com")
        ],
        birthday: date(year: 1988, month: 11, day: 6),
        thumbnailData: swatch(color: .systemIndigo)
    )

    /// The common case: a full name, one number, one email, no photo.
    static let typical = Contact(
        id: "contact-james",
        givenName: "James",
        familyName: "Chen",
        fullName: "James Chen",
        organizationName: "",
        phoneNumbers: [Contact.LabeledValue(label: "mobile", value: "(212) 555-0187")],
        emails: [Contact.LabeledValue(label: "work", value: "james.chen@example.com")],
        birthday: date(year: 1990, month: 3, day: 14),
        thumbnailData: nil
    )

    /// No phone numbers and no emails — drives the detail screen's empty branch.
    static let withoutPhoneOrEmail = Contact(
        id: "contact-maya",
        givenName: "Maya",
        familyName: "Levi",
        fullName: "Maya Levi",
        organizationName: "",
        phoneNumbers: [],
        emails: [],
        birthday: nil,
        thumbnailData: nil
    )

    /// Reachable by email only, so the list row has no subtitle.
    static let emailOnly = Contact(
        id: "contact-noah",
        givenName: "Noah",
        familyName: "Davis",
        fullName: "Noah Davis",
        organizationName: "",
        phoneNumbers: [],
        emails: [Contact.LabeledValue(label: "home", value: "noah.davis@example.com")],
        birthday: nil,
        thumbnailData: nil
    )

    /// A given name with no family name, so the initials collapse to one letter.
    static let givenNameOnly = Contact(
        id: "contact-olivia",
        givenName: "Olivia",
        familyName: "",
        fullName: "Olivia",
        organizationName: "",
        phoneNumbers: [Contact.LabeledValue(label: "mobile", value: "052-876-5432")],
        emails: [],
        birthday: nil,
        thumbnailData: swatch(color: .systemTeal)
    )

    /// A business: no personal name at all, so `displayName` falls back to the organization.
    static let organizationOnly = Contact(
        id: "contact-pizza",
        givenName: "",
        familyName: "",
        fullName: "",
        organizationName: "Pizza Palace",
        phoneNumbers: [Contact.LabeledValue(label: "main", value: "09-765-4321")],
        emails: [],
        birthday: nil,
        thumbnailData: nil
    )

    /// Neither name nor organization, so `displayName` falls back to the phone number.
    static let nameless = Contact(
        id: "contact-unknown",
        givenName: "",
        familyName: "",
        fullName: "",
        organizationName: "",
        phoneNumbers: [Contact.LabeledValue(label: "mobile", value: "058-112-2334")],
        emails: [],
        birthday: nil,
        thumbnailData: nil
    )

    /// Every fixture above, in the order a list would show them.
    static let all: [Contact] = [
        complete,
        typical,
        withoutPhoneOrEmail,
        emailOnly,
        givenNameOnly,
        organizationOnly,
        nameless
    ]

    // MARK: - Helpers

    private static func date(year: Int, month: Int, day: Int) -> Date? {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }

    /// A flat square of colour, standing in for a contact photo.
    private static func swatch(color: UIColor) -> Data? {
        let size = CGSize(width: 240, height: 240)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData()
    }
}
