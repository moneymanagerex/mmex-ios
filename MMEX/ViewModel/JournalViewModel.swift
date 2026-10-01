//
//  JournalViewModel.swift
//  MMEX
//

import SwiftUI
@preconcurrency import SQLite

@MainActor
final class JournalViewModel: ObservableObject {
    @Published var journals: [JournalData] = []

    func load(
        from db: SQLite.Connection?,
        accountId: DataId? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        includeScheduled: Bool = true
    ) {
        guard let repository = JournalRepository(db) else { return }
        journals = repository.loadJournals(
            accountId: accountId,
            startDate: startDate,
            endDate: endDate,
            includeScheduled: includeScheduled
        )
    }

    func grouped(
        searchQuery: String,
        typeFilter: JournalType? = nil,
        payeeNames: [DataId: String],
        categoryPaths: [DataId: String]
    ) -> [String: [JournalData]] {
        var result = journals

        if let typeFilter {
            result = result.filter { $0.type == typeFilter }
        }
        if !searchQuery.isEmpty {
            result = result.filter { journal in
                let payeeMatch = payeeNames[journal.payeeId]?.localizedCaseInsensitiveContains(searchQuery) ?? false
                let notesMatch = journal.notes.localizedCaseInsensitiveContains(searchQuery)
                let categoryMatch = categoryPaths[journal.categId]?.localizedCaseInsensitiveContains(searchQuery) ?? false
                let splitMatch = journal.splits.contains { split in
                    split.notes.localizedCaseInsensitiveContains(searchQuery) ||
                    (categoryPaths[split.categId]?.localizedCaseInsensitiveContains(searchQuery) ?? false)
                }
                return payeeMatch || notesMatch || categoryMatch || splitMatch
            }
        }

        return Dictionary(grouping: result) { String($0.transDate.string.prefix(10)) }
    }

    func save(_ journal: inout JournalData, to db: SQLite.Connection?) -> Bool {
        guard let repository = JournalRepository(db) else { return false }
        return repository.saveJournal(&journal)
    }

    func delete(_ journal: JournalData, from db: SQLite.Connection?) -> Bool {
        guard let repository = JournalRepository(db) else { return false }
        return repository.deleteJournal(journal)
    }
}
