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
        // 按天分组
        self.journals_per_day = Dictionary(grouping: journals) { $0.transDate.string.prefix(10).description }
    }
    
    func filterJournals(by query: String) {
        log.debug("DEBUG: ViewModel.filterJournals(\(query))")

        var payeeIdOffer: Set<DataId> = []
        var categoryOffer: Set<DataId> = []

        if query.isEmpty {
            payeeIdOffer = Set(payeeList.order.readyValue ?? [])
            categoryOffer = Set(categoryList.order.readyValue ?? [])
        } else {
            for (id, payee) in payeeList.data.readyValue ?? [:] {
                if payee.name.localizedCaseInsensitiveContains(query) {
                    payeeIdOffer.insert(id)
                }
            }

            for (id, category) in categoryList.evalPath.readyValue ?? [:] {
                if category.localizedCaseInsensitiveContains(query) {
                    categoryOffer.insert(id)
                }
            }
        }

        let filteredJournals = query.isEmpty ? journals : journals.filter { journal in
            journal.notes.localizedCaseInsensitiveContains(query) ||
            journal.splits.contains { split in
                split.notes.localizedCaseInsensitiveContains(query)
                || categoryOffer.contains(split.categId)
            }
            || payeeIdOffer.contains(journal.payeeId)
            || categoryOffer.contains(journal.categId)
        }
        self.journals_per_day = Dictionary(grouping: filteredJournals) { journal in
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
