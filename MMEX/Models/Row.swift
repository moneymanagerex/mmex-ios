//
//  Row.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/19.
//

import SQLite

extension Row {
    func getNumeric(_ doubleExpression: Expression<Double?>, _ intExpression: Expression<Int64?>) -> Double {
        return self[doubleExpression] ?? Double(self[intExpression] ?? 0)
    }
}
