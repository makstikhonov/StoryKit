//
//  Loading.swift
//

import Foundation

enum Loading<Value> {
    case none
    case loading
    case loaded(Value)
    case failed(Error)

    private var rawValue: String {
        switch self {
        case .none:
            "none"
        case .loading:
            "loading"
        case .loaded:
            "loaded"
        case .failed:
            "failed"
        }
    }

    var value: Value? {
        switch self {
        case .none, .loading, .failed:
            return nil
        case .loaded(let value):
            return value
        }
    }

    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .none, .loaded, .failed:
            return false
        }
    }

    var isLoaded: Bool {
        switch self {
        case .none, .loading, .failed:
            return false
        case .loaded:
            return true
        }
    }

    init(from result: Result<Value, Error>) {
        switch result {
        case .success(let value):
            self = .loaded(value)
        case .failure(let error):
            self = .failed(error)
        }
    }

    func map<AnotherValue>(_ mapValue: (Value) -> AnotherValue) -> Loading<AnotherValue> {
        switch self {
        case .none:
            return .none
        case .loading:
            return .loading
        case .loaded(let value):
            return .loaded(mapValue(value))
        case .failed(let error):
            return .failed(error)
        }
    }
}

// MARK: - Equatable
extension Loading: Equatable {

    static func == (lhs: Loading<Value>, rhs: Loading<Value>) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
