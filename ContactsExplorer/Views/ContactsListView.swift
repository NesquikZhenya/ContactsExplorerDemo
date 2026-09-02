//
//  ContactsListView.swift
//  ContactsExplorer
//
//  Created by Shai Balassiano on 17/08/2026.
//

import SwiftUI
import UIKit

struct ContactsListView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var store: ContactsStore
    @State private var path: [Contact] = []
    @State private var searchText = ""

    init(store: ContactsStore = ContactsStore()) {
        _store = StateObject(wrappedValue: store)
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle("Contacts")
                .navigationDestination(for: Contact.self) { contact in
                    ContactDetailView(contact: contact, store: store)
                }
        }
        .task {
            guard store.state == .idle else { return }
            await store.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch store.state {
        case .idle, .loading:
            ProgressView("Loading Contacts…")
        case .permissionDenied:
            permissionDeniedView
        case .failed:
            failedView
        case .loaded:
            contactsList
        }
    }

    private var contactsList: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Name or phone number", text: $searchText)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            List(filteredContacts) { contact in
                Button {
                    path.append(contact)
                } label: {
                    ContactRow(
                        contact: contact,
                        isFavorite: store.isFavorite(contact),
                        onToggleFavorite: { store.toggleFavorite(contact) }
                    )
                }
                .buttonStyle(.plain)
            }
            .overlay {
                if hasNoSearchResults {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .refreshable {
                await store.load()
            }
        }
    }

    // MARK: - Search Logic

    private var filteredContacts: [Contact] {
        let query = trimmedSearchText
        guard !query.isEmpty else { return store.contacts }
        return store.contacts.filter { matches(contact: $0, query: query) }
    }

    private var hasNoSearchResults: Bool {
        !trimmedSearchText.isEmpty && filteredContacts.isEmpty
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    private func matches(contact: Contact, query: String) -> Bool {
        if contact.displayName.localizedCaseInsensitiveContains(query) {
            return true
        }
        guard isPhoneNumber(query: query) else {
            return false
        }
        let queryDigits = query.filter(\.isWholeNumber)
        return contact.phoneNumbers.contains { $0.value.filter(\.isWholeNumber).contains(queryDigits) }
    }

    private func isPhoneNumber(query: String) -> Bool {
        query.contains(where: \.isWholeNumber) &&
            query.allSatisfy { $0.isWholeNumber || "+-(). ".contains($0) }
    }

    private var permissionDeniedView: some View {
        ContentUnavailableView {
            Label("No Access to Contacts", systemImage: "lock")
        } description: {
            Text("Allow access to your contacts in Settings to see them here.")
        } actions: {
            Button("Open Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                openURL(url)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var failedView: some View {
        ContentUnavailableView {
            Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text("Your contacts could not be loaded. Please try again.")
        } actions: {
            Button("Try Again") {
                Task { await store.load() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ContactRow: View {
    let contact: Contact
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ContactAvatarView(contact: contact, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.displayName)
                if let phoneNumber = contact.phoneNumbers.first {
                    Text(phoneNumber.value)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            FavoriteButton(isFavorite: isFavorite, action: onToggleFavorite)
                .buttonStyle(.borderless)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(.rect)
    }
}

struct ContactAvatarView: View {
    let contact: Contact
    var imageData: Data? = nil
    let size: CGFloat

    var body: some View {
        Group {
            if let data = imageData ?? contact.thumbnailData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                initialsAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(.circle)
    }

    private var initialsAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.gray.gradient)
            Text(contact.initials)
                .font(.system(size: size * 0.4, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
        }
    }

}

struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundStyle(isFavorite ? .yellow : .secondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .accessibilityLabel(isFavorite ? "Remove from Favorites" : "Add to Favorites")
    }
}
