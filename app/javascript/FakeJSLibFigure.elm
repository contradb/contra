module FakeJSLibFigure exposing (..)

moves =
    ["allemande"
    ,"allemande orbit"
    ,"arch & dive"
    ,"balance"
    ,"balance the ring"
    ,"box circulate"
    ,"box the gnat"
    ,"swat the flea"
    ,"butterfly whirl"
    ,"California twirl"
    ,"chain"
    ,"circle"
    ,"contra corners"
    ,"cross trails"
    ,"custom"
    ,"do si do"
    ,"see saw"
    ,"dolphin hey"
    ,"down the hall"
    ,"up the hall"
    ,"figure 8"
    ,"form long waves"
    ,"form a long wave"
    ,"form an ocean wave"
    ,"gate"
    ,"give & take"
    ,"facing star"
    ,"gyre"
    ,"hey"
    ,"long lines"
    ,"mad robin"
    ,"pass by"
    ,"pass through"
    ,"petronella"
    ,"poussette"
    ,"promenade"
    ,"progress"
    ,"pull by dancers"
    ,"pull by direction"
    ,"revolving door"
    ,"right left through"
    ,"roll away"
    ,"Rory O'More"
    ,"slice"
    ,"slide along set"
    ,"square through"
    ,"stand still"
    ,"star"
    ,"star promenade"
    ,"swing"
    ,"meltdown swing"
    ,"turn alone"
    ,"zig zag"
    ]

type Move = Allemande
          | AllemandeOrbit
          | ArchAndDive
          | Balance
          | BalanceTheRing
          | BoxCirculate
          | BoxTheGnat
          | SwatTheFlea
          | ButterflyWhirl
          | CaliforniaTwirl
          | Chain
          | Circle
          | ContraCorners
          | CrossTrails
          | Custom
          | DoSiDo
          | SeeSaw
          | DolphinHey
          | DownTheHall
          | UpTheHall
          | Figure8
          | FormLongWaves
          | FormALongWave
          | FormAnOceanWave
          | Gate
          | GiveAndTake
          | FacingStar
          | Gyre
          | Hey
          | LongLines
          | MadRobin
          | PassBy
          | PassThrough
          | Petronella
          | Poussette
          | Promenade
          | Progress
          | PullByDancers
          | PullByDirection
          | RevolvingDoor
          | RightLeftThrough
          | RollAway
          | RoryOMore
          | Slice
          | SlideAlongSet
          | SquareThrough
          | StandStill
          | Star
          | StarPromenade
          | Swing
          | MeltdownSwing
          | TurnAlone
          | ZigZag

toMove : String -> Maybe Move
toMove x =
    case x of
        "allemande" -> Just Allemande
        "allemande orbit" -> Just AllemandeOrbit
        "arch & dive" -> Just ArchAndDive
        "balance" -> Just Balance
        "balance the ring" -> Just BalanceTheRing
        "box circulate" -> Just BoxCirculate
        "box the gnat" -> Just BoxTheGnat
        "swat the flea" -> Just SwatTheFlea
        "butterfly whirl" -> Just ButterflyWhirl
        "California twirl" -> Just CaliforniaTwirl
        "chain" -> Just Chain
        "circle" -> Just Circle
        "contra corners" -> Just ContraCorners
        "cross trails" -> Just CrossTrails
        "custom" -> Just Custom
        "do si do" -> Just DoSiDo
        "see saw" -> Just SeeSaw
        "dolphin hey" -> Just DolphinHey
        "down the hall" -> Just DownTheHall
        "up the hall" -> Just UpTheHall
        "figure 8" -> Just Figure8
        "form long waves" -> Just FormLongWaves
        "form a long wave" -> Just FormALongWave
        "form an ocean wave" -> Just FormAnOceanWave
        "gate" -> Just Gate
        "give & take" -> Just GiveAndTake
        "facing star" -> Just FacingStar
        "gyre" -> Just Gyre
        "hey" -> Just Hey
        "long lines" -> Just LongLines
        "mad robin" -> Just MadRobin
        "pass by" -> Just PassBy
        "pass through" -> Just PassThrough
        "petronella" -> Just Petronella
        "poussette" -> Just Poussette
        "promenade" -> Just Promenade
        "progress" -> Just Progress
        "pull by dancers" -> Just PullByDancers
        "pull by direction" -> Just PullByDirection
        "revolving door" -> Just RevolvingDoor
        "right left through" -> Just RightLeftThrough
        "roll away" -> Just RollAway
        "Rory O'More" -> Just RoryOMore
        "slice" -> Just Slice
        "slide along set" -> Just SlideAlongSet
        "square through" -> Just SquareThrough
        "stand still" -> Just StandStill
        "star" -> Just Star
        "star promenade" -> Just StarPromenade
        "swing" -> Just Swing
        "meltdown swing" -> Just MeltdownSwing
        "turn alone" -> Just TurnAlone
        "zig zag" -> Just ZigZag
        _ -> Nothing


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


type FigureParameter
    = Int
