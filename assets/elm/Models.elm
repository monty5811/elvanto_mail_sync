module Models exposing (..)

import ElvantoModels exposing (..)
import DjangoSend exposing (CSRFToken)
import Nav.Models exposing (..)
import Regex


type alias Flags =
    { csrftoken : String }


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
    , loadingProgress : Int
    , firstLoadDone : Bool
    , height : Int
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
    , loadingProgress = 25
    , firstLoadDone = False
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
