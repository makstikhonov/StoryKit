//
//  Extension+Double.swift
//
//
//  Created by Sakhabaev Egor on 12.04.2024.
//

import Foundation

extension FloatingPoint {

    func clamp(_ minValue: Self, _ maxValue: Self) -> Self {
        return self < minValue ? minValue : (self > maxValue ? maxValue : self)
    }
}
