module Models exposing (..)

import Json.Decode as Decode
import ElvantoModels exposing (..)
import Decoders exposing (groupDecoder)
import DjangoSend exposing (CSRFToken)
import Nav.Models exposing (..)
import Regex


type alias Flags =
    { csrftoken : String
    , groupsCache : Groups
    , peopleCache : People
    }


type alias Model =
    { groups : Groups
    , people : People
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
    , currentPage : Page
    , groupsLoadingProgress : Int
    , peopleLoadingProgress : Int
    , firstPageLoad : Bool
    , height : Int
    }


initialModel : Flags -> Model
initialModel flags =
    { groups = flags.groupsCache
    , people = flags.peopleCache
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
    , groupsLoadingProgress = 0
    , peopleLoadingProgress = 0
    , firstPageLoad = True
    , height = 720
    }


type FormStatus
    = NoRequest
    | RequestSent
    | RequestSuccess
    | RequestFail


type ButtonStatus
    = NotClicked
    | Clicked
