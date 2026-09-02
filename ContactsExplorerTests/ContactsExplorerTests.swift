//
//  ContactsExplorerTests.swift
//  ContactsExplorerTests
//
//  Created by Shai Balassiano on 20/08/2026.
//

import Foundation
import Testing
@testable import ContactsExplorer

struct ContactsExplorerTests {
    @Test("Contact model stores all of its properties correctly")
    func contactStoresAllProperties() {
        let phoneNumber = Contact.LabeledValue(label: "mobile", value: "+972 54-123-4567")
        let email = Contact.LabeledValue(label: "work", value: "emma@example.com")
        let contact = Contact(
            id: "contact-1",
            givenName: "Emma",
            familyName: "Stone",
            fullName: "Emma Stone",
            organizationName: "Willow Studio",
            phoneNumbers: [phoneNumber],
            emails: [email],
            birthday: nil,
            thumbnailData: nil
        )

        #expect(contact.id == "contact-1")
        #expect(contact.givenName == "Emma")
        #expect(contact.familyName == "Stone")
        #expect(contact.fullName == "Emma Stone")
        #expect(contact.organizationName == "Willow Studio")
        #expect(contact.phoneNumbers == [phoneNumber])
        #expect(contact.emails == [email])
        #expect(contact.thumbnailData == nil)
    }
}
