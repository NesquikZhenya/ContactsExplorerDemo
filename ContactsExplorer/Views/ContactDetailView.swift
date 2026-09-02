//
//  ContactDetailView.swift
//  ContactsExplorer
//
//  Created by Shai Balassiano on 17/08/2026.
//

import Contacts
import SwiftUI
import os

private let logger = Logger(subsystem: "com.shaibalassiano.ContactsExplorer", category: "ContactDetailView")

struct ContactDetailView: View {
    let contact: Contact
    @ObservedObject var store: ContactsStore
    @State private var fullImageData: Data?

    var body: some View {
        List {
            header
            details
            info
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                favoriteButton
            }
        }
        .task {
            await loadFullImage()
        }
    }

    private var header: some View {
        Section {
            VStack(spacing: 12) {
                ContactAvatarView(contact: contact, imageData: fullImageData, size: 120)
                Text(contact.displayName)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private var details: some View {
        if contact.phoneNumbers.isEmpty && contact.emails.isEmpty {
            Section {
                Text("This contact has no phone numbers or emails.")
                    .foregroundStyle(.secondary)
            }
        } else {
            if !contact.phoneNumbers.isEmpty {
                Section("Phone Numbers") {
                    ForEach(contact.phoneNumbers) { phoneNumber in
                        LabeledContent(phoneNumber.label, value: phoneNumber.value)
                    }
                }
            }
            if !contact.emails.isEmpty {
                Section("Emails") {
                    ForEach(contact.emails) { email in
                        LabeledContent(email.label, value: email.value)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var info: some View {
        if !contact.organizationName.isEmpty || contact.birthday != nil {
            Section {
                if !contact.organizationName.isEmpty {
                    infoRow(label: "Organization", value: contact.organizationName)
                }
                if let birthday = contact.birthday {
                    infoRow(label: "Birthday", value: birthday.formatted(date: .long, time: .omitted))
                }
            } header: {
                Text("Info")
                    .font(.subheadline)
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.callout)
    }

    private var favoriteButton: some View {
        FavoriteButton(isFavorite: store.isFavorite(contact), action: { store.toggleFavorite(contact) })
    }

    // TODO: consider moving this into a manager
    private func loadFullImage() async {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        guard status == .authorized || status == .limited else { return }
        do {
            let keysToFetch = [CNContactImageDataKey as CNKeyDescriptor]
            let cnContact = try CNContactStore().unifiedContact(withIdentifier: contact.id, keysToFetch: keysToFetch)
            fullImageData = cnContact.imageData
        } catch {
            logger.error("Loading contact image failed: \(String(describing: error))")
        }
    }
}

struct FavoritesManager {
    private enum Key: String {
        case favoriteContactIDs
    }

    private init() {}

    static func load() -> Set<String> {
        let ids = UserDefaults.standard.stringArray(forKey: Key.favoriteContactIDs.rawValue) ?? []
        return Set(ids)
    }

    static func save(_ ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: Key.favoriteContactIDs.rawValue)
    }
}
