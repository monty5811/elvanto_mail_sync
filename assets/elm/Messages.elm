module Messages exposing (..)

import ElvantoModels exposing (..)
import Http
import Http.Progress as Progress exposing (Progress(..))
import Models exposing (..)



-- MESSAGES


type Msg
    = NoOp
    | UrlChange (Maybe Route)
    | LoadData
    | UpdateGroupFilter String
    | UpdatePersonFilter String
    | GetGroupProgress (Progress Groups)
    | GetPeopleProgress (Progress People)
    | ToggleGlobal Int Bool
    | ToggleLocal GroupPk PersonPk Bool
    | ToggleResp (Result Http.Error ElvantoPerson)
    | ToggleAuto GroupPk Bool
    | ToggleAutoResp (Result Http.Error ElvantoGroup)
    | PushNow
    | PullAllNow
    | PushAllNow
    | ShowGroup ElvantoGroup
    | HideGroup
    | FormSubmit Model
    | FormSubmitResp (Result Http.Error ElvantoGroup)
    | FormEmailChange String
