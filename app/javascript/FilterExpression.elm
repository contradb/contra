module FilterExpression exposing (FilterExpression(..))

type FilterExpression
    = Figure Move (List FigureParameter)
    | Formation String
    | Progression
    | And (List FilterExpression)
    | Amperstand (List FilterExpression)
    | Or (List FilterExpression)
    | Then (List FilterExpression)
    | No FilterExpression
    | Not FilterExpression
    | All FilterExpression
    | Count FilterExpression CountComparison Int

filterTypes : List FilterType
filterTypes = -- manually sync to the above list :(
    [ "figure"
    , "formation"
    , "progression"
    , "and"
    , "&"
    , "or"
    , "then"
    , "no"
    , "not"
    , "all"
    , "count"
    ]

type alias FilterType = String

type CountComparison
    = Equals
    | NotEquals
    | GreaterThan
    | GreaterThanOrEqual
    | LessThan
    | LessThanOrEqual

type alias Move = String

type FigureParameter
    = Int
