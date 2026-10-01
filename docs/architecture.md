# Architecture and MVVM Refactoring Roadmap

This document describes the current architecture, the page boundaries already in place, and the next refactoring steps. The goal is to give new code clear ownership while gradually reducing the responsibilities of the shared application model. Shared data should not be copied into each page merely to make the architecture look more strictly layered.

## Current layers

SwiftUI Views → Page ViewModels → Repositories / Query Loaders → SQLite

Data value types represent database records. Preference and AppContext provide user preferences and cross-page selection context.

### Presentation

- MMEX/View/ contains SwiftUI screens and reusable components. Short-lived presentation state, such as sheet visibility, focus, and temporary selections, can remain in a View's @State.
- Views use @EnvironmentObject for shared application data. A page owns its ViewModel with @StateObject.
- Reusable charts and display components should prefer immutable inputs. Use Binding when a component truly needs to edit state owned by its caller.

### ViewModels and application data

- MMEX/ViewModel/ contains presentation state, page coordination, loading and refresh behavior, and user-action orchestration.
- ViewModel is the current shared application object. It owns database connection state and cross-page Repository lists, groups, and load states. Accounts, currencies, categories, and payees are used by several screens and validation flows, so they remain shared for now.
- OverviewViewModel, InsightsViewModel, JournalViewModel, SettingsViewModel, and ScheduledOverviewViewModel own state and interaction logic for clearer page boundaries.
- TransactionLoader provides reusable transaction reads without attaching stateless query behavior to a ViewModel instance.
- The ViewModel implementation is divided across List/, Group/, Search/, Reload/, and Validation/. These extensions make the code easier to navigate, but they still share one object's state. Future work should move independently owned behavior out of that object.

### Data and persistence

- MMEX/Data/ maps database records to Swift value types.
- MMEX/Repository/ encapsulates SQLite queries and writes. Views should not build SQL or access SQLite.swift directly.
- The existing SQLite layer handles database compatibility and encryption. Page ViewModels may coordinate Repositories, but database implementation details should not leak into Views.

### Application dependencies

- MMEXApp creates app-lifetime objects and injects them through the SwiftUI Environment.
- Preference manages user preferences. AppContext manages cross-page context such as the selected account and date range.
- Page ViewModels should receive the data or capabilities they need through initializers or method parameters. Avoid adding new long-lived singleton dependencies.

## Page boundaries in place

| Page area | ViewModel responsibilities | Still provided by the shared application object |
| --- | --- | --- |
| Overview | Current and previous period transactions, KPIs, account balances, cancellable refresh work | Database connection, account list, base currency, and display formatting |
| Insights | Date range, trend transactions, account flows, and base currency | Account and currency lists, and database connection |
| Journal / Transaction | Journal list, search grouping, save, and delete | Database connection and account/category/payee lookup data |
| Settings | Setting selections, option lists, error presentation, and refresh coordination | Setting persistence validation, shared list caches, and cache invalidation/reloading |
| Scheduled Overview | Date grouping, sorting, and due-date actions | Scheduled list/split caches, database connection, and display lookup data |

These boundaries are an intermediate stage of an incremental migration. A page ViewModel can read shared Repository caches without putting its own presentation state back into the shared object.

## Recommended data flow

1. A View sends a user action or filter change to its page ViewModel.
2. The ViewModel reads shared cached data or calls a Repository or query loader.
3. The Repository accesses SQLite and returns Data values.
4. The ViewModel publishes presentation state, which the View renders.

Views render state and forward user intent. ViewModels handle filtering, display models, asynchronous work, and operation results. Repositories handle persistence. Data that must be shared across pages stays in the application layer, with explicit reload and invalidation behavior.

## Future TODOs

Work from lower-dependency areas toward higher-dependency areas. Preserve behavior and keep the project buildable at each stage.

### 1. Audit and reduce the shared ViewModel

- [ ] Inventory the shared ViewModel's public properties, extension methods, and actual View dependencies. Map cross-domain reads and writes.
- [ ] Move stateless formatting, naming, sorting, and filtering into pure functions or domain-specific types instead of continuing to grow the app-level object.
- [ ] Move feature-specific validation and command orchestration into feature ViewModels or use cases. Keep the application layer focused on shared data and session capabilities.
- [ ] Define clear ownership for shared account, currency, category, payee, transaction, and budget caches. Start with lower-dependency domains before highly connected domains such as categories and accounts.
- [ ] Converge the shared ViewModel into a clearly named AppDataStore/database-session coordinator, or split it into domain stores based on the dependency audit. Avoid a repository-wide mechanical rename before the responsibilities are decided.

### 2. Standardize database concurrency and loading

- [ ] Define thread or actor ownership for SQLite Connection; do not share a connection across concurrent tasks without a clear policy.
- [ ] Replace ad hoc DispatchQueue and main-thread callbacks with structured concurrency, consistent cancellation, error handling, and stale-result protection.
- [ ] Standardize Repository error results and list LoadState. An empty array should not represent both “no data” and “query failed.”
- [ ] Define load-task lifecycles so work is cancelled or replaced when a page disappears, the database changes, or filters change.

### 3. Clarify dependency injection and View interfaces

- [ ] Review dependencies on AppContext.shared, static Preview objects, and app-wide EnvironmentObjects. Prefer protocol-based or initializer injection for business services.
- [ ] Gradually make Views receive read-only display values and user-intent callbacks instead of calling business methods on the large application object.
- [ ] Review the generic Repository management forms and clarify responsibilities across View, ViewModel, Validation, and Repository while preserving genuinely reusable components.

### 4. Add regression coverage

- [ ] Add pure-logic tests for date ranges, KPIs, trend grouping, Journal search/grouping, settings validation, and scheduled due-date rules.
- [ ] Add in-memory database integration tests for Repository inserts, updates, deletes, splits, and failure paths.
- [ ] Build the iOS Simulator target after each structural migration. Require tests for high-risk cache invalidation and database-write changes before applying the pattern to more domains.

## Refactoring principles

1. Do not duplicate cross-page data to avoid shared dependencies. Every shared state value should have one clear owner.
2. A ViewModel should expose only the state and actions its page needs. New Views should not receive Repositories, SQLite queries, or the entire application object without a clear reason.
3. Prefer value types for inputs and outputs. Use mutable bindings only for real two-way editing.
4. Async results must remain associated with the filter and database state that produced them; stale results must not overwrite newer state.
5. Migrate one reviewable vertical slice at a time, preserve existing behavior, and build before completing each change.
