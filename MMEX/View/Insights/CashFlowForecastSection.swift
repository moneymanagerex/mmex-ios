//
//  CashFlowForecastSection.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/10/21.
//

import SwiftUI
import Charts

struct CashFlowForecastSection: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var insights: InsightsViewModel
    @EnvironmentObject var context: AppContext
    let formatter: CurrencyFormatter?

    @State private var windowDays: Int = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Window", selection: $windowDays) {
                Text("30 days").tag(30)
                Text("60 days").tag(60)
                Text("90 days").tag(90)
            }
            .pickerStyle(.segmented)
            .onChange(of: windowDays) { _, _ in reload() }

            if insights.forecastIsLoading {
                HStack {
                    ProgressView().scaleEffect(0.7)
                    Text("Forecasting...").font(.caption).foregroundColor(.secondary)
                }
            } else if let summary = insights.forecastSummary, !summary.items.isEmpty {
                metrics(summary)
                balanceChart(summary)
                upcomingItems(summary)
            } else {
                empty
            }
        }
        .task { reload() }
        .onChange(of: vm.scheduledList.state) { _, newState in
            if newState == .ready { reload() }
        }
        .onChange(of: context.selectedAccountId) { _, _ in reload() }
    }

    private func reload() {
        insights.loadForecast(from: vm, days: windowDays, accountId: context.selectedAccountId)
    }

    @ViewBuilder private func metrics(_ s: CashFlowForecastSummary) -> some View {
        HStack(spacing: 8) {
            metric("In",  s.totalInflow, pref.theme.incomeColor)
            metric("Out", s.totalOutflow, pref.theme.expenseColor)
            metric("Net", s.netChange, pref.theme.changeColor(for: s.netChange))
        }
    }

    @ViewBuilder private func metric(_ title: String, _ amount: Double, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundColor(.secondary)
            Text(amount.formatted(by: formatter))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(color).lineLimit(1).minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.gray.opacity(0.06))
        .cornerRadius(6)
    }

    @ViewBuilder private func balanceChart(_ s: CashFlowForecastSummary) -> some View {
        let points = cumulativePoints(s)
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Projected balance").font(.caption).foregroundColor(.secondary)
                Spacer()
                Text(s.projectedBalance.formatted(by: formatter))
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(s.projectedBalance >= 0 ? .primary : pref.theme.expenseColor)
            }
            Chart {
                ForEach(points, id: \.date) { point in
                    LineMark(x: .value("Date", point.date),
                             y: .value("Balance", point.balance))
                        .foregroundStyle(Color.accentColor)
                        .interpolationMethod(.monotone)
                }
                RuleMark(y: .value("Zero", 0))
                    .foregroundStyle(.gray.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [2]))
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(v.formatted(by: formatter)).font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 140)
        }
    }

    private func cumulativePoints(_ s: CashFlowForecastSummary) -> [(date: Date, balance: Double)] {
        var balance = s.startingBalance
        var points: [(Date, Double)] = [(s.windowStart, balance)]
        for day in s.days {
            balance += day.net
            points.append((day.date, balance))
        }
        return points
    }

    @ViewBuilder private func upcomingItems(_ s: CashFlowForecastSummary) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Next scheduled").font(.caption).foregroundColor(.secondary)
            ForEach(s.items.prefix(3)) { item in
                HStack {
                    Image(systemName: item.isInflow ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .foregroundColor(item.isInflow ? pref.theme.incomeColor : pref.theme.expenseColor)
                        .font(.caption)
                    Text(item.payeeName).font(.caption).lineLimit(1)
                    Spacer()
                    Text(item.date, format: .dateTime.month(.abbreviated).day())
                        .font(.caption2).foregroundColor(.secondary)
                    Text(item.amount.formatted(by: formatter))
                        .font(.caption.weight(.medium))
                }.padding(.vertical, 2)
            }
        }
    }

    @ViewBuilder private var empty: some View {
        HStack {
            Image(systemName: "calendar.badge.clock").foregroundColor(.secondary)
            Text("No upcoming scheduled transactions in this window.")
                .font(.caption).foregroundColor(.secondary)
            Spacer()
        }.padding(.vertical, 8)
    }
}
