module Models exposing (..)

import Decoders exposing (groupDecoder)
import DjangoSend exposing (CSRFToken)
import ElvantoModels exposing (..)
import Json.Decode as Decode
import Regex


type alias Flags =
    { csrftoken : String
    , groupsCache : Groups
    , peopleCache : People
    }


type alias Model =
    { groups : Groups
    , people : People
    , fetchGroups : Bool
    , fetchPeople : Bool
    , csrftoken : CSRFToken
    , error : Bool
    , activeGroupPk : GroupPk
    , groupFilter : Regex.Regex
    , personFilter : Regex.Regex
    , emailField : String
    , pushAutoField : Bool
    , formStatus : FormStatus
    , pushGroupStatus : ButtonStatus
    , pushAllStatus : ButtonStatus
    , pullAllStatus : ButtonStatus
    , currentRoute : Route
    , groupsLoadingProgress : Int
    , peopleLoadingProgress : Int
    , firstPageLoad : Bool
    }


initialModel : Flags -> Maybe Route -> Model
initialModel flags maybeRoute =
    { groups = flags.groupsCache
    , people = flags.peopleCache
    , fetchGroups = True
    , fetchPeople = True
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
    , currentRoute = Maybe.withDefault Home maybeRoute
    , groupsLoadingProgress = 0
    , peopleLoadingProgress = 0
    , firstPageLoad = True
    }


type FormStatus
    = NoRequest
    | RequestSent
    | RequestSuccess
    | RequestFail


type ButtonStatus
    = NotClicked
    | Clicked


type Route
    = Home
    | Group GroupPk
