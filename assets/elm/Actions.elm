module Actions exposing (..)

import Task exposing (Task)
import Http
import Json.Decode as Decode
import DjangoSend exposing (csrfSend, CSRFToken)
import Decoders exposing (..)
import Encoders exposing (..)
import Helpers exposing (..)
import Messages exposing (..)
import Models exposing (..)


-- Fetch data from server


fetchGroupsInit : Model -> Cmd Msg
fetchGroupsInit model =
    if List.isEmpty model.groups then
        fetchGroups model.csrftoken
    else
        Cmd.none


fetchGroups : CSRFToken -> Cmd Msg
fetchGroups csrftoken =
    csrfSend groupsUrl "GET" Http.empty csrftoken
        |> Http.fromJson (Decode.list groupDecoder)
        |> Task.perform FetchError FetchGroupsSuccess


fetchPeople : CSRFToken -> Cmd Msg
fetchPeople csrftoken =
    csrfSend peopleUrl "GET" Http.empty csrftoken
        |> Http.fromJson (Decode.list personDecoder)
        |> Task.perform FetchError FetchPeopleSuccess



-- All group actions


submitPushAllRequest : Model -> Cmd Msg
submitPushAllRequest model =
    csrfSend "/buttons/push_all/" "POST" (encodeBody []) model.csrftoken
        |> Http.fromJson decodeAlwaysTrue
        |> Task.perform FetchError (always LoadGroups)


submitPullAllRequest : Model -> Cmd Msg
submitPullAllRequest model =
    csrfSend "/buttons/push_all/" "POST" (encodeBody []) model.csrftoken
        |> Http.fromJson decodeAlwaysTrue
        |> Task.perform FetchError (always LoadGroups)



-- Group specific actions


toggleAutoSync : Int -> Bool -> CSRFToken -> Cmd Msg
toggleAutoSync pk state csrftoken =
    csrfSend "/buttons/update_sync/" "POST" (toggleSyncBody pk state) csrftoken
        |> Http.fromJson groupDecoder
        |> Task.perform FetchError ToggleAutoSuccess


submitForm : Model -> Cmd Msg
submitForm model =
    let
        url =
            groupsUrl ++ (toString model.activeGroupPk)

        body =
            submitFormBody model.emailField model.pushAutoField
    in
        csrfSend url "POST" body model.csrftoken
            |> Http.fromJson groupDecoder
            |> Task.perform FormSubmitError FormSubmitSuccess


submitPushRequest : Model -> Cmd Msg
submitPushRequest model =
    let
        body =
            pushRequestBody model.activeGroupPk
    in
        csrfSend "/buttons/push_group/" "POST" body model.csrftoken
            |> Http.fromJson decodeAlwaysTrue
            |> Task.perform FetchError (always LoadGroups)



-- Person specific actions


toggleGlobal : Int -> Bool -> CSRFToken -> Cmd Msg
toggleGlobal pk state csrftoken =
    csrfSend "/buttons/update_global/" "POST" (toggleGlobalBody pk state) csrftoken
        |> Http.fromJson personDecoder
        |> Task.perform FetchError ToggleSuccess


optUpdateGlobal : Model -> Int -> Bool -> Model
optUpdateGlobal model pk state =
    { model | people = (List.map (updateGlobal pk state) model.people) }


updateGlobal : Int -> Bool -> ElvantoPerson -> ElvantoPerson
updateGlobal pk state person =
    if person.pk == pk then
        { person | disabled_entirely = (not state) }
    else
        person


toggleLocal : Int -> Int -> Bool -> CSRFToken -> Cmd Msg
toggleLocal gPk pPk state csrftoken =
    csrfSend "/buttons/update_local/" "POST" (toggleLocalBody pPk gPk state) csrftoken
        |> Http.fromJson personDecoder
        |> Task.perform FetchError ToggleSuccess


optUpdateLocal : Model -> Int -> Int -> Bool -> Model
optUpdateLocal model groupPk personPk state =
    { model | people = (List.map (updateLocal groupPk personPk state) model.people) }


updateLocal : Int -> Int -> Bool -> ElvantoPerson -> ElvantoPerson
updateLocal groupPk personPk state person =
    if person.pk == personPk then
        { person | disabled_groups = (updateDisablefGroupsList groupPk state person.disabled_groups) }
    else
        person


updateDisablefGroupsList : Int -> Bool -> List Int -> List Int
updateDisablefGroupsList groupPk state groups =
    if state then
        let
            ( _, newGroups ) =
                (List.partition (isPk groupPk) groups)
        in
            newGroups
    else
        groupPk :: groups
