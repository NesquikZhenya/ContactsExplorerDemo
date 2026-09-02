//
//  Contact.swift
//  ContactsExplorer
//
//  Created by Shai Balassiano on 17/08/2026.
//

import Contacts
import Foundation

nonisolated struct Contact: Identifiable, Hashable {
    struct LabeledValue: Identifiable, Hashable {
        let id = UUID()
        let label: String
        let value: String
    }

    let id: String
    let givenName: String
    let familyName: String
    let fullName: String
    let organizationName: String
    let phoneNumbers: [LabeledValue]
    let emails: [LabeledValue]
    let birthday: Date?
    let thumbnailData: Data?

    var displayName: String {
        if !fullName.isEmpty {
            return fullName
        }
        if !organizationName.isEmpty {
            return organizationName
        }
        return phoneNumbers.first?.value ?? emails.first?.value ?? "No Name"
    }

    var initials: String {
        let nameInitials = [givenName.first, familyName.first].compactMap { $0 }
        if !nameInitials.isEmpty {
            return String(nameInitials).uppercased()
        }
        if let organizationInitial = organizationName.first {
            return String(organizationInitial).uppercased()
        }
        return "#"
    }
}

nonisolated extension Contact {
    init(_ cnContact: CNContact) {
        id = cnContact.identifier
        givenName = cnContact.givenName
        familyName = cnContact.familyName
        fullName = CNContactFormatter.string(from: cnContact, style: .fullName) ?? ""
        organizationName = cnContact.organizationName
        phoneNumbers = cnContact.phoneNumbers.map { phoneNumber in
            LabeledValue(
                label: phoneNumber.label.map { CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: $0) } ?? "phone",
                value: phoneNumber.value.stringValue
            )
        }
        emails = cnContact.emailAddresses.map { email in
            LabeledValue(
                label: email.label.map { CNLabeledValue<NSString>.localizedString(forLabel: $0) } ?? "email",
                value: email.value as String
            )
        }
        birthday = cnContact.birthday.flatMap { Calendar.current.date(from: $0) }
        thumbnailData = cnContact.thumbnailImageData
    }
}
