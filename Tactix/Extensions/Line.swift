//
//  Line.swift
//  Tactix
//
//  Created by Hardik Kothari on 22.03.25.
//

import SwiftUI

struct Line: Shape {
    var direction: WinDirection
    
    init(direction: WinDirection) {
        self.direction = direction
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch direction {
        case .horizontal:
            path.move(to: CGPoint(x: 0, y: rect.maxY * 0.5))
            path.addLine(to: CGPoint(x: rect.width, y: rect.maxY * 0.5))
        case .vertical:
            path.move(to: CGPoint(x: rect.maxX * 0.5, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX * 0.5, y: rect.height))
        case .forwardDiagnal:
            path.move(to: CGPoint(x: 0, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        case .backwardDiagnal:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        return path
    }
}
