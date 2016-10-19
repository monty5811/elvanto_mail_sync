module Messages exposing (..)

import Http
import Window exposing (Size)
import Models exposing (..)


-- MESSAGES


type Msg
    = NoOp
    | LoadGroups
    | LoadPeople
    | UpdateGroupFilter String
    | UpdatePersonFilter String
    | FetchGroupsSuccess Groups
    | FetchPeopleSuccess People
    | FetchError Http.Error
    | ToggleGlobal Int Bool
    | ToggleLocal Int Int Bool
    | ToggleSuccess ElvantoPerson
    | ToggleAuto Int Bool
    | ToggleAutoSuccess ElvantoGroup
    | PushNow
    | PullAllNow
    | PushAllNow
    | ShowGroup Int (Maybe String) Bool
    | HideGroup
    | FormSubmit Model
    | FormSubmitError Http.Error
    | FormSubmitSuccess ElvantoGroup
    | FormEmailChange String
    | Go String
    | WinResize Size
