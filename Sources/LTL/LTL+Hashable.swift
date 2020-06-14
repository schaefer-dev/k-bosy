//  LTL implementation by Leander Tentrupp (github @ltentrup)
//
//  Sourced by Daniel Schäfer on 28.02.20.

extension LTLFunction: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
        hasher.combine(arity)
    }

    public static func ==(lhs: LTLFunction, rhs: LTLFunction) -> Bool {
        return lhs.symbol == rhs.symbol && lhs.arity == rhs.arity
    }
}

extension LTLAtomicProposition: Equatable {
    public static func ==(lhs: LTLAtomicProposition, rhs: LTLAtomicProposition) -> Bool {
        return lhs.name == rhs.name
    }
}

extension LTLPathVariable: Hashable {
    public static func ==(lhs: LTLPathVariable, rhs: LTLPathVariable) -> Bool {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension LTL: Equatable {
    public static func == (lhs: LTL, rhs: LTL) -> Bool {
        switch (lhs, rhs) {
        case (.atomicProposition(let lhs), .atomicProposition(let rhs)):
            return lhs == rhs
        case (.pathProposition(let lhs, let lhsPath), .pathProposition(let rhs, let rhsPath)):
            return lhs == rhs && lhsPath == rhsPath
        case (.application(let lhsFun, let lhsParameters), .application(let rhsFun, parameters: let rhsParameters)):
            return lhsFun == rhsFun && lhsParameters == rhsParameters
        case (.pathQuantifier(let lhsQuant, let lhsParamaters, let lhsBody), .pathQuantifier(let rhsQuant, parameters: let rhsParameters, body: let rhsBody)):
            return lhsQuant == rhsQuant && lhsParamaters == rhsParameters && lhsBody == rhsBody
        default:
            return false
        }
    }
}
