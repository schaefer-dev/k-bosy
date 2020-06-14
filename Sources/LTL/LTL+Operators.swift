//  LTL implementation by Leander Tentrupp (github @ltentrup)
//
//  Sourced by Daniel Schäfer on 28.02.20.

// We define operators to make working with LTL easier

// FIXME: check which precedence is correct
infix operator =>
infix operator <=>

extension LTL {

    public static func && (lhs: LTL, rhs: LTL) -> LTL {
        return .application(.and, parameters: [lhs, rhs])
    }

    public static func &= (lhs: inout LTL, rhs: LTL) {
        lhs = lhs && rhs
    }

    public static func || (lhs: LTL, rhs: LTL) -> LTL {
        return .application(.or, parameters: [lhs, rhs])
    }

    public static prefix func ! (ltl: LTL) -> LTL {
        return .application(.negation, parameters: [ltl])
    }

    public static func => (lhs: LTL, rhs: LTL) -> LTL {
        return .application(.implies, parameters: [lhs, rhs])
    }

    public static func <=> (lhs: LTL, rhs: LTL) -> LTL {
        return .application(.equivalent, parameters: [lhs, rhs])
    }

    public static func until(_ lhs: LTL, _ rhs: LTL) -> LTL {
        return .application(.until, parameters: [lhs, rhs])
    }

    public static func weakUntil(_ lhs: LTL, _ rhs: LTL) -> LTL {
        return .application(.weakUntil, parameters: [lhs, rhs])
    }

    public static func release(_ lhs: LTL, _ rhs: LTL) -> LTL {
        return .application(.release, parameters: [lhs, rhs])
    }

}
