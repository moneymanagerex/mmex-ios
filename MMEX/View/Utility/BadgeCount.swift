//
//  BadgeCount.swift
//  MMEX
//
//  2024-10-04: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct BadgeCount: View {
    var count: Int
    var body: some View {
        Text("\(count)")
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(.gray, in: .capsule)
    }
}
