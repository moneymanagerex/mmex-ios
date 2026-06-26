//
//  JournalViewModel.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/23.
//

import Foundation

extension ViewModel {
    func loadJournals(accountId: DataId? = nil, startDate: Date? = nil, endDate: Date? = nil, includeScheduled: Bool = true) {
        guard let repo = JournalRepository(db) else { return }
        let journals = repo.loadJournals(accountId: accountId, startDate: startDate, endDate: endDate, includeScheduled: includeScheduled)
        self.journals = journals
    }
    
    func groupJournals(searchQuery: String, typeFilter: JournalType? = nil) -> [String: [JournalData]] {
        var result = journals

        if let type = typeFilter {
            result = result.filter { $0.type == type }
        }

        if !searchQuery.isEmpty {
            result = result.filter { journal in
                // Payee
                let payeeMatch = payeeList.data.readyValue?[journal.payeeId]?.name
                    .localizedCaseInsensitiveContains(searchQuery) ?? false
                // Notes
                let notesMatch = journal.notes.localizedCaseInsensitiveContains(searchQuery)
                // Category
                let categoryMatch = categoryList.evalPath.readyValue?[journal.categId]?
                    .localizedCaseInsensitiveContains(searchQuery) ?? false
                // Splits
                let splitMatch = journal.splits.contains { split in
                    split.notes.localizedCaseInsensitiveContains(searchQuery) ||
                    categoryList.evalPath.readyValue?[split.categId]?
                        .localizedCaseInsensitiveContains(searchQuery) ?? false
                }
                return payeeMatch || notesMatch || categoryMatch || splitMatch
            }
        }

        return Dictionary(grouping: result) { journal in
            String(journal.transDate.string.prefix(10))
        }
    }

    func saveJournal(_ journal: inout JournalData) -> Bool {
        guard let repo = JournalRepository(db) else { return false }
        return repo.saveJournal(&journal)
    }

    func deleteJournal(_ journal: JournalData) -> Bool {
        guard let repo = JournalRepository(db) else { return false }
        return repo.deleteJournal(journal)
    }
}
