# App Store Release Assets

This document prepares the core App Store marketing assets for the current iOS release of Money Manager Ex.

It is based on the current app capabilities described in [README](../README.md), the existing app icon in `MMEX/Assets.xcassets/AppIcon.appiconset/`, and the current screenshots in `Screenshots/`.

## Apple guidance used for this pack

The recommendations below align with current Apple guidance:

- App subtitle: up to 30 characters.
- Promotional text: up to 170 characters.
- Keywords: up to 100 characters, comma-separated.
- App previews: up to 3 per language, each up to 30 seconds.
- Screenshots: up to 10 per locale/device class.
- When no app preview is shown, the first 1 to 3 screenshots may appear in search results, so the opening sequence matters most.
- Avoid prices, dated copy, misleading UI, and off-device footage.

## Current asset inventory in this repository

### Existing assets

- App icon: `MMEX/Assets.xcassets/AppIcon.appiconset/mmex_green.png` (`1024x1024`)
- Fresh simulator raw captures:
  - `Screenshots/2026-refresh/raw/overview.png`
  - `Screenshots/2026-refresh/raw/enter.png`
  - `Screenshots/2026-refresh/raw/journal.png`
  - `Screenshots/2026-refresh/raw/insights.png`
  - `Screenshots/2026-refresh/raw/manage.png`
  - `Screenshots/2026-refresh/raw/settings.png`
  - `Screenshots/2026-refresh/raw/start.png`
- Large-display simulator captures:
  - `Screenshots/2026-refresh/raw/iphone-17-pro-max/`
- Generated marketing screenshots:
  - `docs/assets/app-store/01-overview.png`
  - `docs/assets/app-store/02-journal.png`
  - `docs/assets/app-store/03-insights.png`
  - `docs/assets/app-store/04-entry.png`
  - `docs/assets/app-store/05-manage.png`
  - `docs/assets/app-store/06-start.png`
  - `docs/assets/app-store/07-settings.png`
  - Large-display versions in `docs/assets/app-store/6.9-inch/`
- Dated sample database used for the current capture:
  - `Screenshots/2026-refresh/MMEX-Sample-2026-11-01.mmb`
- China mainland localized search screenshots:
  - `docs/assets/app-store/cn-01-overview.png`
  - `docs/assets/app-store/cn-02-journal.png`
  - `docs/assets/app-store/cn-03-insights.png`
- Screenshot generator:
  - `scripts/generate_app_store_screenshots.py`
- Header and Search Results creative assets:
  - `docs/assets/app-store/creative-assets/en/`
  - `docs/assets/app-store/creative-assets/zh-Hans/`
  - Generated from the dated iPhone 17 Pro Max sample-data captures by `scripts/generate_app_store_creative_assets.py`.

### Available screenshot sizes

- **Medium display:** `1206x2622` portrait, captured on iPhone 17. These are the root-level exports in `docs/assets/app-store/`.
- **Large display:** `1320x2868` portrait, captured on iPhone 17 Pro Max. These are in `docs/assets/app-store/6.9-inch/`.

Both sizes are accepted iPhone screenshot sizes in [Apple's current specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/). In App Store Connect, upload each set to the matching display-size slot. For a 6.9-inch slot, use the `6.9-inch/` files; the root-level iPhone 17 captures are medium-display files.

## Header and Search Results

These are the assets and copy most likely to influence App Store search performance and first impressions.

### Header and Search Results creative assets

The wide creative assets below are separate from the portrait screenshots. They use actual MMEX sample-data screens and are exported as opaque RGB PNGs at Apple's supported dimensions:

- **Product page header:** `5244x2950` or `3840x1646`.
- **Search results:** `5244x2950`, `3840x2560`, or `1920x1280`.

Each size is available in English and Simplified Chinese. Upload the `header-*` files to the product-page header slot and the `search-*` files to the search-results slot:

- English: [`creative-assets/en/`](assets/app-store/creative-assets/en/)
- China mainland (`zh-Hans`): [`creative-assets/zh-Hans/`](assets/app-store/creative-assets/zh-Hans/)

To regenerate these designs from the iPhone 17 Pro Max captures and app icon, run `scripts/generate_app_store_creative_assets.py` in the Pillow-enabled screenshot environment.

### App name

**Money Manager Ex**

### Subtitle

**Private finance tracker**

- Character count: `23 / 30`
- Rationale: concise, value-focused, and avoids repeating the app name.

### Promotional text

**Track spending, net worth, and MMEX databases on iPhone. Keep data local with optional AES-256 encryption, charts, multi-account support, and a Files-based workflow.**

- Character count: `165 / 170`

### Keywords

**budget,expense tracker,finance,money manager,offline,encrypted,net worth,sqlite,mmex,ledger**

- Character count: `91 / 100`

### Search-result positioning notes

To optimize search results and product-page scanning:

1. Put the strongest value proposition in the subtitle, not in the app name.
2. Keep the first screenshot focused on a recognizable finance overview.
3. Use the next two screenshots for transaction history and useful insights.
4. Follow with transaction entry; the first three images should not depend on an empty form or an onscreen keyboard.

Use the China mainland localized metadata and screenshot overlays below for the zh-Hans storefront instead of reusing the US App Store link or English search copy.

### Search screenshot sets

The first three screenshots are designed as a search-results story: **overview → transaction history → insights**. Each size folder contains the full English product-page sequence; China mainland uses the matching `cn-01` through `cn-03` localized search images.

- Medium iPhone: `docs/assets/app-store/01-overview.png` through `03-insights.png`; mainland: `cn-01-overview.png` through `cn-03-insights.png`.
- Large iPhone: `docs/assets/app-store/6.9-inch/01-overview.png` through `03-insights.png`; mainland: `6.9-inch/cn-01-overview.png` through `cn-03-insights.png`.

## Product page description

Use the first sentence to explain the app clearly before the fold.

> Money Manager Ex for iPhone helps you track spending, monitor balances, and manage personal finances in your own MMEX database.
>
> Built for people who want ownership of their financial records, the app works with MMEX databases and fits naturally into a file-based workflow across mobile and desktop. Use it to review account balances, record income and expenses, manage categories and payees, and explore charts that help you understand how your money moves.
>
> Features:
> - Local finance tracking with optional AES-256 database encryption
> - MMEX database compatibility for mobile and desktop workflows
> - Fast entry for income, expense, transfer, and split transactions
> - Accounts, categories, payees, budgets, tags, reports, and attachments
> - Charts and trends for balances, income, and expense analysis
> - Customizable settings for currency, defaults, privacy, and theme
> - Multi-language support and Files-based document handling

## App Previews and Screenshots

### Screenshot organization strategy

Per Apple’s current asset best practices, the screenshot set should:

- lead with the core value proposition,
- use short overlay text that enhances the visual instead of describing it,
- keep a consistent visual system across the full set,
- keep the first 3 screenshots strong enough to stand on their own in search results.

That means the screenshot sequence should be organized by **user value story**, not by internal app menu order.

### Current status

The repository now has:

- a **fresh simulator-captured raw set** taken from the current app build with sample data, and
- a **generated marketing set** derived from those fresh captures.

This is a much better baseline than the older screenshots, but final App Store submission still needs a human review for content polish, localization, and exact device-size compliance.

### Recommended slot plan

| Slot | Story goal | Preferred screen | What should be visible | Why it belongs here |
|---|---|---|---|---|
| 1 | Immediate value | Overview / dashboard | balances, net worth, recent activity, clean sample data | This is the strongest “why download” screen and should lead search results |
| 2 | Ongoing trust | Journal / recent transactions list | readable recent records, categories, dates, amounts | Reinforces everyday finance tracking credibility |
| 3 | Insight and clarity | Insights / charts | income vs expense trend or summary visualization | Adds analytical value after basic trust is established |
| 4 | Daily usefulness | Transaction entry | add expense or transfer flow with realistic values | Shows the app is practical, not just analytical |
| 5 | Depth and organization | Manage | accounts, categories, payees, budgets, reports | Demonstrates breadth without overwhelming the first screens |
| 6 | Personalization | Settings | base currency, defaults, privacy, theme | Shows the app adapts to the user’s workflow |
| 7 | Ownership and onboarding | Database / start flow | open/create/import/sample workflow | Ends with the differentiator: local control and secure data |

### Current raw capture coverage

The current simulator capture pass now covers these slots directly:

1. `overview-hero`
2. `journal-activity`
3. `insights-trends`
4. `transaction-entry`
5. `management-depth`
6. `database-ownership`
7. `settings-personalization`

For future recapture passes, keep using:

- realistic but non-sensitive sample data,
- consistent language and currency,
- clean timestamps and totals,
- no obviously incomplete or placeholder-heavy UI states.

### Recommended screenshot order

Because the first screenshots may appear in search results, lead with the most user-facing value:

#### Recommended current App Store order

1. `overview-hero`
2. `journal-activity`
3. `insights-trends`
4. `transaction-entry`
5. `management-depth`
6. `database-ownership`
7. `settings-personalization`

#### Generated order in this repository

1. `docs/assets/app-store/01-overview.png`
2. `docs/assets/app-store/02-journal.png`
3. `docs/assets/app-store/03-insights.png`
4. `docs/assets/app-store/04-entry.png`
5. `docs/assets/app-store/05-manage.png`
6. `docs/assets/app-store/06-start.png`
7. `docs/assets/app-store/07-settings.png`

### Screenshot overlay copy

Use short overlay headlines that remain legible on small displays.

| Order | Generated file | Source file | Headline | Subheadline |
|---|---|---|---|---|
| 1 | `01-overview.png` | `overview.png` | Your money, all in view | Balances, net worth, and cash flow at a glance |
| 2 | `02-journal.png` | `journal.png` | Find every transaction | Review recent activity by date, category, payee, and amount |
| 3 | `03-insights.png` | `insights.png` | Spot trends quickly | See income and spending trends in clear charts |
| 4 | `04-entry.png` | `enter.png` | Log spending in seconds | Record income, expenses, transfers, and split transactions with ease |
| 5 | `05-manage.png` | `manage.png` | Organize every detail | Manage accounts, categories, payees, budgets, reports, and more |
| 6 | `06-start.png` | `start.png` | Own your data securely | Open existing MMEX files or start fresh with local sample data |
| 7 | `07-settings.png` | `settings.png` | Make the app yours | Set base currency, defaults, privacy choices, and appearance |

### Final upload recommendation

For the next App Store submission, use the first 5 screenshots as the primary product story:

1. Overview
2. Journal / recent activity
3. Insights
4. Transaction entry
5. Manage

Use the final 2 screenshots as supporting differentiators:

6. Data ownership / onboarding
7. Settings / personalization

### Regenerating the screenshot set

To refresh the generated screenshot pack:

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install pillow
python scripts/generate_app_store_screenshots.py
```

### Additional screenshot suggestions

To strengthen the next App Store upload, prioritize these improvements on top of the new capture set:

- More polished sample finance data with stronger visual hierarchy on the overview screen.
- Cleaner payee/category/account naming tuned for marketing presentation.
- A dark-mode variant if the release wants to emphasize appearance support.
- Localized versions for each App Store language.
- Optional alternate overview or insights variants for product page optimization tests.

## App preview plan

Apple allows up to 3 previews per language, each up to 30 seconds. For this app, use a simple product-focused sequence and stay fully inside the app UI.

### Preview 1 — Overview and confidence

- Goal: explain what the app is and why it is trustworthy.
- Length: `22–28s`
- Suggested sequence:
  1. Open Money Manager Ex.
  2. Show database access/open flow.
  3. Land on the overview dashboard.
  4. Highlight balances, net worth, and recent transactions.
  5. End on the trend chart.

Suggested captions:

- Your finances, under your control
- Secure MMEX database support
- Track balances and net worth instantly
- Understand trends at a glance

Poster frame:

- Use the overview dashboard with visible summary cards and chart content.

### Preview 2 — Everyday transaction flow

- Goal: show that core finance entry is quick and practical.
- Length: `20–30s`
- Suggested sequence:
  1. Open transaction entry.
  2. Add an expense.
  3. Add a transfer.
  4. Show split transaction editing.
  5. Return to updated recent activity.

Suggested captions:

- Capture spending in seconds
- Support for transfers and split transactions
- Keep your records accurate on the go

Poster frame:

- Use the transaction edit screen with a clean, readable form.

### Preview 3 — Management and customization

- Goal: show depth beyond basic expense tracking.
- Length: `20–30s`
- Suggested sequence:
  1. Open Manage.
  2. Scroll through accounts, categories, payees, budgets, tags, and reports.
  3. Open Settings.
  4. Show base currency, defaults, privacy, and theme settings.

Suggested captions:

- Manage the details that matter
- Accounts, categories, budgets, and more
- Customize defaults, privacy, and theme

Poster frame:

- Use the management screen with multiple finance modules visible.

## Capture and export checklist

### Before recording

- Use realistic but non-sensitive sample data.
- Remove placeholder labels, unfinished screens, or obviously empty states unless they are part of the story.
- Keep system time, battery, and network indicators visually clean if possible.
- Prefer consistent light or dark appearance within one asset set.

### Screenshot checklist

- Capture clean portrait screenshots for the required App Store device class.
- Keep overlay copy outside critical UI controls.
- Maintain the same visual style across all screenshots.
- Ensure the first three screenshots can stand alone in search results.

### Preview checklist

- Capture footage directly from device.
- Stay within the app UI only.
- Keep text readable without audio.
- Avoid season-specific or dated language.
- Do not mention pricing.
- If the release later requires login, subscription, or paid-only features, disclose that in preview copy or the end card.

## Release gaps to close before upload

These are the main remaining production tasks:

1. Confirm the required App Store Connect screenshot slots at submission; this pack now includes medium and large iPhone exports.
2. Add localized metadata and screenshot overlays for any additional storefront languages.
3. Capture at least one dark-mode asset if the release intends to highlight appearance support.
4. Record up to 3 on-device app previews and choose poster frames.
5. Review screenshot sample data for polish, consistency, and privacy safety.

## China mainland App Store copy (zh-Hans)

Use this metadata and screenshot order for the China mainland storefront. Keep the product name recognizable and avoid wording that implies cloud sync or that every database is already encrypted.

### App name

**Money Manager Ex**

### 副标题

**本地记账与预算管理**

- Character count: `9 / 30`

### 宣传文本

**在 iPhone 上管理 MMEX 财务数据库，记录收支、查看净资产与趋势。支持 AES-256 加密数据库，通过“文件”管理数据，让财务记录由你掌控。**

- 字符数：`76 / 170`

### 关键词

**记账,记账软件,财务管理,预算,收支,家庭账本,个人理财,资产,MMEX,数据库,离线**

- 字符数：`43 / 100`

### 描述

> Money Manager Ex 帮助你在 iPhone 上记录收支、查看账户余额，并管理个人财务。数据保存在你自己的 MMEX 数据库中，让记录与文件始终由你掌控。
>
> 你可以快速记录收入、支出、转账和拆分交易，管理账户、分类、收款方、预算与标签，并通过图表了解收支趋势。应用支持 MMEX 数据库和 iOS“文件”工作流，也支持 AES-256 加密数据库。

### 搜索结果截图

1. **掌握每一笔收支** — 账户余额、净资产与现金流，一目了然。
2. **轻松查找每笔交易** — 按日期、类别和金额，快速查看近期交易。
3. **看清财务变化** — 直观查看收入与支出的变化趋势。
4. **几秒记下一笔** — 轻松记录收入、支出、转账和拆分交易。

前 3 张适合搜索结果预览；第 4 张交易录入图放在详情页后续位置，避免空白金额输入框和键盘占据搜索首屏。

### 截图文案

The localized first three overlay exports are `cn-01-overview.png`, `cn-02-journal.png`, and `cn-03-insights.png`.

### Sample database and simulator capture

The dated fixture `Screenshots/2026-refresh/MMEX-Sample-2026-11-01.mmb` is generated from the app's built-in sample records. To create a fresh dated copy in the simulator Documents folder, launch with `MMEX_SCREENSHOT_SAMPLE_DATABASE_NAME=MMEX-Sample-YYYY-MM-DD.mmb`; the screenshot harness recreates that file on each launch. Use the iPhone 17 simulator and capture the seven screens from the fixture, except the start/onboarding screen, which intentionally uses the disconnected state.
