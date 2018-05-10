module ElvantoModels exposing (..)

import Regex


type alias GroupPk =
    Int


type alias PersonPk =
    Int


type alias ElvantoGroup =
    { pk : GroupPk
    , name : String
    , googleEmail : Maybe String
    , pushAuto : Bool
    , lastPushed : Maybe String
    , lastPulled : Maybe String
    , people : List PersonPk
    }


groupToString : ElvantoGroup -> String
groupToString g =
    String.join ","
        [ String.fromInt g.pk
        , g.name
        , Maybe.withDefault "" g.googleEmail
        , Maybe.withDefault "Never" g.lastPulled
        , Maybe.withDefault "Never" g.lastPushed
        ]


type alias ElvantoPerson =
    { email : String
    , fullName : String
    , pk : PersonPk
    , disabledEntirely : Bool
    , disabledGroups : List Int
    }


personToString : ElvantoPerson -> String
personToString p =
    String.join ","
        [ p.email
        , p.fullName
        , String.fromInt p.pk
        ]


type alias People =
    List ElvantoPerson


type alias Groups =
    List ElvantoGroup


nullGroup : ElvantoGroup
nullGroup =
    ElvantoGroup 0 "" Nothing False Nothing Nothing []


nullRegex : Regex.Regex
nullRegex =
    Regex.never


groupsUrl : String
groupsUrl =
    "/api/v1/elvanto/groups/"


peopleUrl : String
peopleUrl =
    "/api/v1/elvanto/people/"
