module Models exposing (..)

import Regex
import DjangoSend exposing (CSRFToken)


type alias Flags =
    { csrftoken : String
    , pk : Int
    }


type alias Model =
    { groups : Groups
    , people : People
    , csrftoken : CSRFToken
    , error : Bool
    , displayGroup : Bool
    , activeGroupPk : Int
    , groupFilter : Regex.Regex
    , personFilter : Regex.Regex
    , emailField : String
    , pushAutoField : Bool
    , formStatus : FormStatus
    }


type FormStatus
    = NoRequest
    | RequestSent
    | RequestSuccess
    | RequestFail


type alias ElvantoGroup =
    { pk : Int
    , name : String
    , google_email : Maybe String
    , push_auto : Bool
    , last_pushed : Maybe String
    , last_pulled : Maybe String
    , total_disabled_people_in_group : Int
    , people : List Int
    }


type alias ElvantoPerson =
    { email : String
    , full_name : String
    , pk : Int
    , disabled_entirely : Bool
    , disabled_groups : List Int
    }


type alias People =
    List ElvantoPerson


type alias Groups =
    List ElvantoGroup


nullGroup : ElvantoGroup
nullGroup =
    ElvantoGroup 0 "" Nothing False Nothing Nothing 0 []


nullRegex : Regex.Regex
nullRegex =
    Regex.regex ""


groupsUrl : String
groupsUrl =
    "/api/v1/elvanto/groups/"


peopleUrl : String
peopleUrl =
    "/api/v1/elvanto/people/"
