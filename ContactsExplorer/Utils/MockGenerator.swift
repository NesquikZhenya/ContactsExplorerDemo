//
//  MockGenerator.swift
//  ContactsExplorer
//
//  Created by Shai Balassiano on 17/08/2026.
//

import UIKit

struct MockGenerator {
    private init() {}

    static func contact() -> Contact {
        Contact(
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
            thumbnailData: imageData(color: .systemIndigo)
        )
    }

    static func bareContact() -> Contact {
        Contact(
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
    }

    static func contacts() -> [Contact] {
        [
            contact(),
            Contact(
                id: "contact-james",
                givenName: "James",
                familyName: "Chen",
                fullName: "James Chen",
                organizationName: "",
                phoneNumbers: [Contact.LabeledValue(label: "mobile", value: "(212) 555-0187")],
                emails: [Contact.LabeledValue(label: "work", value: "james.chen@example.com")],
                birthday: date(year: 1990, month: 3, day: 14),
                thumbnailData: nil
            ),
            bareContact(),
            Contact(
                id: "contact-noah",
                givenName: "Noah",
                familyName: "Davis",
                fullName: "Noah Davis",
                organizationName: "",
                phoneNumbers: [],
                emails: [Contact.LabeledValue(label: "home", value: "noah.davis@example.com")],
                birthday: nil,
                thumbnailData: nil
            ),
            Contact(
                id: "contact-olivia",
                givenName: "Olivia",
                familyName: "",
                fullName: "Olivia",
                organizationName: "",
                phoneNumbers: [Contact.LabeledValue(label: "mobile", value: "052-876-5432")],
                emails: [],
                birthday: nil,
                thumbnailData: imageData(color: .systemTeal)
            ),
            Contact(
                id: "contact-pizza",
                givenName: "",
                familyName: "",
                fullName: "",
                organizationName: "Pizza Palace",
                phoneNumbers: [Contact.LabeledValue(label: "main", value: "09-765-4321")],
                emails: [],
                birthday: nil,
                thumbnailData: nil
            ),
            Contact(
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
        ]
    }

    static func store(
        contacts: [Contact] = MockGenerator.contacts(),
        state: ContactsStore.LoadState = .loaded,
        favoriteIDs: Set<String> = ["contact-emma"]
    ) -> ContactsStore {
        ContactsStore(contacts: contacts, state: state, favoriteIDs: favoriteIDs)
    }

    static func date(year: Int, month: Int, day: Int) -> Date? {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }

    static func imageData(color: UIColor) -> Data? {
        let size = CGSize(width: 240, height: 240)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData()
    }
}
