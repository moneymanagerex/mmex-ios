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
- Generated marketing screenshots:
  - `docs/assets/app-store/01-overview.png`
  - `docs/assets/app-store/02-entry.png`
  - `docs/assets/app-store/03-journal.png`
  - `docs/assets/app-store/04-insights.png`
  - `docs/assets/app-store/05-manage.png`
  - `docs/assets/app-store/06-start.png`
  - `docs/assets/app-store/07-settings.png`
- Screenshot generator:
  - `scripts/generate_app_store_screenshots.py`

### Current screenshot size

The fresh simulator raw capture set is `1320x2868` portrait. Before submission, confirm the exact target device classes currently required by App Store Connect for this version and regenerate exports if Apple requests a different display class.

## Header and Search Results

These are the assets and copy most likely to influence App Store search performance and first impressions.

### App name

**Money Manager Ex**

### Subtitle

**Encrypted budget tracker**

- Character count: `24 / 30`
- Rationale: concise, value-focused, and avoids repeating the app name.

### Promotional text

**Track spending, monitor net worth, and manage MMEX databases on iPhone with AES-256 encryption, charts, multi-account support, and Files-based sync.**

- Character count: `148 / 170`

### Keywords

**budget,expense tracker,finance,money manager,offline,encrypted,net worth,sqlite,mmex,ledger**

- Character count: `91 / 100`

### Search-result positioning notes

To optimize search results and product-page scanning:

1. Put the strongest value proposition in the subtitle, not in the app name.
2. Keep the first screenshot focused on a recognizable finance overview.
3. Use the second screenshot for transaction entry speed.
4. Use the third screenshot for database compatibility and management depth.

## Product page description

Use the first sentence to explain the app clearly before the fold.

> Money Manager Ex for iPhone helps you track spending, monitor balances, and manage your personal finances with secure, encrypted local data.
>
> Built for people who want ownership of their financial records, the app works with MMEX databases and fits naturally into a file-based workflow across mobile and desktop. Use it to review account balances, record income and expenses, manage categories and payees, and explore charts that help you understand how your money moves.
>
> Features:
> - Secure local finance tracking with AES-256 database encryption
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
| 2 | Daily usefulness | Transaction entry | add expense or transfer flow with realistic values | Shows the app is practical, not just analytical |
| 3 | Ongoing trust | Journal / recent transactions list | readable recent records, categories, dates, amounts | Reinforces everyday finance tracking credibility |
| 4 | Insight and clarity | Insights / charts | income vs expense trend or summary visualization | Adds analytical value after basic trust is established |
| 5 | Depth and organization | Manage | accounts, categories, payees, budgets, reports | Demonstrates breadth without overwhelming the first screens |
| 6 | Personalization | Settings | base currency, defaults, privacy, theme | Shows the app adapts to the user’s workflow |
| 7 | Ownership and onboarding | Database / start flow | open/create/import/sample workflow | Ends with the differentiator: local control and secure data |

### Current raw capture coverage

The current simulator capture pass now covers these slots directly:

1. `overview-hero`
2. `transaction-entry`
3. `journal-activity`
4. `insights-trends`
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
2. `transaction-entry`
3. `journal-activity`
4. `insights-trends`
5. `management-depth`
6. `database-ownership`
7. `settings-personalization`

#### Generated order in this repository

1. `docs/assets/app-store/01-overview.png`
2. `docs/assets/app-store/02-entry.png`
3. `docs/assets/app-store/03-journal.png`
4. `docs/assets/app-store/04-insights.png`
5. `docs/assets/app-store/05-manage.png`
6. `docs/assets/app-store/06-start.png`
7. `docs/assets/app-store/07-settings.png`

### Screenshot overlay copy

Use short overlay headlines that remain legible on small displays.

| Order | Generated file | Source file | Headline | Subheadline |
|---|---|---|---|---|
| 1 | `01-overview.png` | `overview.png` | See your money clearly | Balances, trends, and recent activity in one secure overview |
| 2 | `02-entry.png` | `enter.png` | Record transactions fast | Capture income, expenses, transfers, and split entries in seconds |
| 3 | `03-journal.png` | `journal.png` | Stay on top of activity | Review recent transactions with clear dates, categories, and amounts |
| 4 | `04-insights.png` | `insights.png` | Spot trends quickly | Explore income and expense patterns with clear charts and summaries |
| 5 | `05-manage.png` | `manage.png` | Organize every detail | Manage accounts, categories, payees, budgets, reports, and more |
| 6 | `06-start.png` | `start.png` | Own your data securely | Open existing MMEX files or start fresh with local sample data |
| 7 | `07-settings.png` | `settings.png` | Make the app yours | Set base currency, defaults, privacy choices, and appearance |

### Final upload recommendation

For the next App Store submission, use the first 5 screenshots as the primary product story:

1. Overview
2. Transaction entry
3. Journal / recent activity
4. Insights
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

1. Re-export screenshots for the exact App Store Connect device classes required at submission time.
2. Produce localized screenshot overlays for each supported App Store language, starting with English and Simplified Chinese.
3. Capture at least one dark-mode asset if the release intends to highlight appearance support.
4. Record up to 3 on-device app previews and choose poster frames.
5. Review screenshot sample data for polish, consistency, and privacy safety.

## Simplified Chinese localization starter copy

If you localize the product page for zh-Hans, these can be used as a starting point.

### 副标题

**加密记账与预算追踪**

### 宣传文本

**在 iPhone 上安全管理 MMEX 财务数据库，随时记录收支、查看净资产趋势，并通过“文件”工作流保持数据可控。**

### 截图文案

1. **一眼看清资金变化**  
   余额、趋势与最近交易尽在首页
2. **快速记录每一笔交易**  
   支持收入、支出、转账与拆分交易
3. **细致管理财务结构**  
   账户、分类、收款人、预算与报表
4. **按你的习惯自定义**  
   默认账户、基准货币、隐私与主题
5. **安全打开 MMEX 数据**  
   支持加密数据库与文件工作流
