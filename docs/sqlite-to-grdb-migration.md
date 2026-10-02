# SQLite.swift to GRDB.swift Migration Plan

This document records the preparation work and migration sequence for replacing SQLite.swift with GRDB.swift. It is based on the current source tree and GRDB's official documentation, reviewed on 2026-10-02. It does not change the database driver or on-disk format.

## Current application shape

- `MMEX/App/MMEXDatabase.swift` owns opening and closing the database, security-scoped document access, bookmarks, file coordination, attached read-only databases, in-memory creation, and connection-level pragmas.
- `MMEX/App/SQLite3MC.swift` extends SQLite.swift `Connection` with SQLite3MultipleCiphers configuration, key verification, rekeying, and encrypted export helpers. The app currently tries SQLCipher and AES-128-CBC cipher configurations when opening a password-protected file.
- `MMEX/Repository/RepositoryProtocol.swift` is the main coupling point. It exposes SQLite.swift `Connection`, `Table`, `Expression`, `Row`, and `Setter` in its contract and implements common query and write operations using SQLite.swift's query DSL.
- Domain repositories build on that protocol. Data value types also import SQLite.swift, and page/application ViewModels pass `Connection` through to repositories. In the current tree, SQLite.swift types or imports appear in roughly 110 Swift files.
- `MMEX/Resources/tables.sql` creates the MMEX-compatible schema for new databases. `MMEXDatabase.swift` sets `user_version` to 21 for new files. Preserve this established schema and file compatibility; do not treat adopting GRDB as a schema rewrite.
- The project currently points to a local SQLite.swift package at `../SQLite.swift`. Deployment targets are iOS 16/17.6 and the project sets Swift language version 5.

## Main migration risks

### Encryption and SQLite build

GRDB's documented SQLCipher setup uses a SQLite build with SQLCipher support and configures each connection before database access, for example with `Configuration.prepareDatabase`. This project uses SQLite3MultipleCiphers-specific C functions and supports cipher modes beyond SQLCipher. GRDB's SQLCipher integration does not establish compatibility with SQLite3MultipleCiphers or with the app's AES-128-CBC files.

Before converting repositories, prove that the chosen GRDB package/build can link against the intended SQLite3MultipleCiphers implementation and invoke the required cipher initialization/key APIs before the first schema read. On copies of representative existing files, verify both supported cipher modes and the unencrypted path, then verify reads, writes, reopen, rekey, and export/import. Never use production user files for this compatibility spike.

### Connection ownership and concurrency

SQLite.swift repositories currently retain a `Connection`. GRDB repositories normally execute work through a `DatabaseReader`/`DatabaseWriter` (`DatabaseQueue` or `DatabasePool`) closure, which controls connection access and transaction lifetime. A mechanical type alias from `Connection` to a GRDB type would not preserve these semantics. Choose queue versus pool only after auditing concurrent reads, writes, long operations, file coordination, and the current journal-mode behavior.

### Repository/query conversion

The common protocol is coupled to SQLite.swift's query-builder types, not just its connection type. GRDB offers its own SQL execution and query interface, but neither is source-compatible with `SQLite.Table`/`Expression`/`Row`/`Setter`. SQL-heavy reporting and specialized filters also need explicit migration and result-shape review. Keep the app's `DataProtocol` values independent of GRDB record types unless a concrete use case justifies changing that boundary.

### Database lifecycle and MMEX compatibility

Preserve document-provider access, security-scoped URL lifetime, cloud-file coordination, bookmarks, attached read-only import, in-memory sample database creation, `user_version`, pragmas, and MMEX SQL conventions. GRDB's `DatabaseMigrator` is a possible future tool for app-owned incremental schema changes, but it must not accidentally rewrite or take ownership of the externally shared MMEX schema. Establish how its migration ledger can coexist with desktop/Android-produced files before adopting it.

## Recommended sequence

1. **Freeze behavior and inventory.** Record the existing schema version, cipher variants, supported file types, repository behaviors, transaction boundaries, and important raw SQL/report queries. Add representative database fixtures or sanitized copies for validation.
2. **Resolve SQLite3MultipleCiphers compatibility.** Build a minimal GRDB open/key/query spike using the same SQLite implementation as production. Confirm cipher initialization order and encrypted-file interoperability. This is a go/no-go gate; if the package cannot share the required SQLite implementation cleanly, evaluate a maintained GRDB package/build integration before porting app code.
3. **Define a driver-neutral session boundary.** Move database lifecycle and access ownership out of the shared ViewModel into an application/persistence session. Expose read/write operations and app-level errors, not `Connection`, `DatabaseQueue`, `Row`, or SQL-builder types. Keep security-scoped and file-coordination behavior at the lifecycle boundary.
4. **Port a small vertical slice.** Choose a low-dependency repository (for example a settings/infotable read/write) and convert its query, mapping, error handling, and transaction behavior end to end. Compare results against the current implementation on the same fixture. Use this slice to validate conventions before generalizing.
5. **Migrate repository families.** Convert simple lookup repositories, then transactions and their splits/links, then reports and complex raw SQL. Keep data value types as the stable boundary. Avoid having one generic abstraction expose either driver's query DSL.
6. **Switch application lifecycle.** Convert open/create/close, encrypted open/rekey/export, attachment/import, database observation, and queue/pool policy. Remove SQLite.swift only when no source or build setting depends on it.
7. **Validate release readiness.** Compare schema/version, representative query results, CRUD, rollback, import/export, encrypted and unencrypted round-trips, and open existing MMEX files. Build and run the regression suite before release; keep a reversible migration path until compatibility is established.

## First implementation decisions

- Prefer GRDB's closure-based `DatabaseReader`/`DatabaseWriter` access as the persistence boundary; do not expose its raw `Database` past a read/write closure.
- Start with `DatabaseQueue` if serialized access best matches the current app, and move to `DatabasePool` only when measured read concurrency and WAL behavior justify it. GRDB pools use WAL behavior, which must be reconciled with the current in-memory journal configuration and cloud document semantics.
- Keep existing `Data` structs as repository inputs/outputs. Introduce private GRDB record or row-mapping types only where they reduce duplication without changing the MMEX data contract.
- Keep schema compatibility work separate from the driver port. Preserve the existing `tables.sql` initialization path initially; evaluate `DatabaseMigrator` only for app-owned, versioned changes.
- Do not add GRDB as a second production driver until its SQLite binary and encryption path are selected. A parallel dependency without a working cipher integration could compile while making encrypted user files inaccessible.

## Official GRDB references

- [GRDB.swift README and installation](https://github.com/groue/GRDB.swift)
- [Database configuration and connection preparation](https://github.com/groue/GRDB.swift/blob/master/GRDB/Core/Configuration.swift)
- [GRDB migrations](https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md)
- [GRDB 7 migration guide and toolchain requirements](https://github.com/groue/GRDB.swift/blob/master/Documentation/GRDB7MigrationGuide.md)
- [GRDB SQLCipher configuration discussion](https://github.com/groue/GRDB.swift/discussions/1517)

GRDB documents SQLCipher configuration through connection preparation, and GRDB 7 currently documents a Swift 6 compiler requirement. Applicability to this project—especially SQLite3MultipleCiphers linkage and cipher compatibility—is an open engineering question, not an established fact.
