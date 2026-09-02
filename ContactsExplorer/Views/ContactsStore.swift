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

// CHANGELOG:
// 2026-08-17: initial implementation
// 2026-08-18: added @concurrent so fetching doesn't block the main thread
// 2026-08-19: fixed missing formatter keys crash (code review feedback)
// 2026-08-20: refactored per developer request
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
        // Step 1: show the loading spinner
        if contacts.isEmpty {
            state = .loading
        }
        do {
            // Step 2: request permission from the user
            guard try await requestAccessIfNeeded() else {
                state = .permissionDenied
                return
            }
            // Step 3: fetch the contacts from the device
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
            // Step 4: update the UI state
            state = .loaded
        } catch {
            logger.error("Loading contacts failed: \(String(describing: error))")
            if contacts.isEmpty {
                state = .failed
            }
        }
    }

    // The developer requested from me to make the favorite status stay
    // consistent between the contacts list and the detail page, so I put the
    // toggle here in the shared store instead of duplicating it in each view.
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
