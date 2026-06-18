// Service/ServiceError.swift
import Foundation

enum ServiceError: Error {
    case repositoryFailed(reason: String)
    case notFound
    case insertFailed
    case updateFailed
    case deleteFailed
    case validationFailed(message: String)
    case cacheMiss
}