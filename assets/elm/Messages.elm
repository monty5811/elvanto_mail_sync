module Messages exposing (..)

import Http
import Window exposing (Size)
import Models exposing (..)
import ElvantoModels exposing (..)


-- MESSAGES


type Msg
    = NoOp
    | LoadData
    | UpdateGroupFilter String
    | UpdatePersonFilter String
    | FetchGroupsSuccess Groups
    | FetchPeopleSuccess People
    | FetchError Http.Error
    | ToggleGlobal Int Bool
    | ToggleLocal GroupPk PersonPk Bool
    | ToggleSuccess ElvantoPerson
    | ToggleAuto GroupPk Bool
    | ToggleAutoSuccess ElvantoGroup
    | PushNow
    | PullAllNow
    | PushAllNow
    | ShowGroup ElvantoGroup
    | HideGroup
    | FormSubmit Model
    | FormSubmitError Http.Error
    | FormSubmitSuccess ElvantoGroup
    | FormEmailChange String
    | WinResize Size
