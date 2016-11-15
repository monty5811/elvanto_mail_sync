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


type alias ElvantoPerson =
    { email : String
    , fullName : String
    , pk : PersonPk
    , disabledEntirely : Bool
    , disabledGroups : List Int
    }


type alias People =
    List ElvantoPerson


type alias Groups =
    List ElvantoGroup


nullGroup : ElvantoGroup
nullGroup =
    ElvantoGroup 0 "" Nothing False Nothing Nothing []


nullRegex : Regex.Regex
nullRegex =
    Regex.regex ""


groupsUrl : String
groupsUrl =
    "/api/v1/elvanto/groups/"


peopleUrl : String
peopleUrl =
    "/api/v1/elvanto/people/"
