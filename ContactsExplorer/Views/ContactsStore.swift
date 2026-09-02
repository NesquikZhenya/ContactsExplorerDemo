//
//  ContactsStore.swift
//  ContactsExplorer
//
//  Created by Shai Balassiano on 17/08/2026.
//

import Combine
import Contacts
import Foundation
import os

private let logger = Logger(subsystem: "com.shaibalassiano.ContactsExplorer", category: "ContactsStore")

final class ContactsStore: ObservableObject {
    enum LoadState {
        case idle
        case loading
        case loaded
        case permissionDenied
        case failed
    }

    @Published private(set) var contacts: [Contact]
    @Published private(set) var state: LoadState
    @Published private(set) var favoriteIDs: Set<String>

    init(
        contacts: [Contact] = [],
        state: LoadState = .idle,
        favoriteIDs: Set<String> = FavoritesManager.load()
    ) {
        self.contacts = contacts
        self.state = state
        self.favoriteIDs = favoriteIDs
    }

    func load() async {
        if contacts.isEmpty {
            state = .loading
        }
        do {
            guard try await requestAccessIfNeeded() else {
                state = .permissionDenied
                return
            }
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor
            ]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            request.sortOrder = .userDefault
            var fetchedContacts: [Contact] = []
            try CNContactStore().enumerateContacts(with: request) { cnContact, _ in
                fetchedContacts.append(Contact(cnContact))
            }
            contacts = fetchedContacts
            state = .loaded
        } catch {
            logger.error("Loading contacts failed: \(String(describing: error))")
            if contacts.isEmpty {
                state = .failed
            }
        }
    }

    func toggleFavorite(_ contact: Contact) {
        if favoriteIDs.contains(contact.id) {
            favoriteIDs.remove(contact.id)
        } else {
            favoriteIDs.insert(contact.id)
        }
        FavoritesManager.save(favoriteIDs)
    }

    func isFavorite(_ contact: Contact) -> Bool {
        favoriteIDs.contains(contact.id)
    }

    private func requestAccessIfNeeded() async throws -> Bool {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized, .limited:
            true
        case .notDetermined:
            try await CNContactStore().requestAccess(for: .contacts)
        case .denied, .restricted:
            false
        @unknown default:
            false
        }
    }
}
