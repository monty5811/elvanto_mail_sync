module Models exposing (..)

import Regex
import DjangoSend exposing (CSRFToken)
import Nav.Models exposing (..)


type alias Flags =
    { csrftoken : String }


type alias Model =
    { groups : Groups
    , people : People
    , csrftoken : CSRFToken
    , error : Bool
    , activeGroupPk : Int
    , groupFilter : Regex.Regex
    , personFilter : Regex.Regex
    , emailField : String
    , pushAutoField : Bool
    , formStatus : FormStatus
    , pushGroupStatus : ButtonStatus
    , pushAllStatus : ButtonStatus
    , pullAllStatus : ButtonStatus
    , currentPage : Page
    }


initialModel : Flags -> Model
initialModel flags =
    { groups = []
    , people = []
    , csrftoken = flags.csrftoken
    , groupFilter = nullRegex
    , personFilter = nullRegex
    , activeGroupPk = 0
    , emailField = ""
    , pushAutoField = False
    , error = False
    , formStatus = NoRequest
    , pushGroupStatus = NotClicked
    , pushAllStatus = NotClicked
    , pullAllStatus = NotClicked
    , currentPage = Home
    }


type FormStatus
    = NoRequest
    | RequestSent
    | RequestSuccess
    | RequestFail


type ButtonStatus
    = NotClicked
    | Clicked


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
