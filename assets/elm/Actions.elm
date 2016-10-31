module Actions exposing (..)

import Task exposing (Task)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Window
import DjangoSend exposing (csrfSend, CSRFToken)
import Decoders exposing (..)
import Encoders exposing (..)
import Helpers exposing (..)
import Messages exposing (..)
import Models exposing (..)
import ElvantoModels exposing (..)
import Cache exposing (saveGroups)


-- Initial window size


getWinSize : Cmd Msg
getWinSize =
    Task.perform (\_ -> NoOp) WinResize Window.size



-- Fetch data from server


pageLoadInit : Model -> Cmd Msg
pageLoadInit model =
    if model.firstPageLoad then
        Cmd.batch
            [ getWinSize
            , fetchData model.csrftoken
            ]
    else
        Cmd.none


fetchData : CSRFToken -> Cmd Msg
fetchData csrftoken =
    Cmd.batch [ fetchGroups csrftoken, fetchPeople csrftoken ]


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
        |> Task.perform FetchError (always LoadData)


submitPullAllRequest : Model -> Cmd Msg
submitPullAllRequest model =
    csrfSend "/buttons/pull_all/" "POST" (encodeBody []) model.csrftoken
        |> Http.fromJson decodeAlwaysTrue
        |> Task.perform FetchError (always LoadData)



-- Group specific actions


toggleAutoSync : GroupPk -> Bool -> CSRFToken -> Cmd Msg
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
            |> Task.perform FetchError (always LoadData)



-- Person specific actions


toggleGlobal : PersonPk -> Bool -> CSRFToken -> Cmd Msg
toggleGlobal pk state csrftoken =
    csrfSend "/buttons/update_global/" "POST" (toggleGlobalBody pk state) csrftoken
        |> Http.fromJson personDecoder
        |> Task.perform FetchError ToggleSuccess


optUpdateGlobal : People -> PersonPk -> Bool -> People
optUpdateGlobal people pk state =
    people
        |> List.map (updateGlobal pk state)


updateGlobal : PersonPk -> Bool -> ElvantoPerson -> ElvantoPerson
updateGlobal pk state person =
    if person.pk == pk then
        { person | disabledEntirely = (not state) }
    else
        person


toggleLocal : GroupPk -> PersonPk -> Bool -> CSRFToken -> Cmd Msg
toggleLocal gPk pPk state csrftoken =
    csrfSend "/buttons/update_local/" "POST" (toggleLocalBody pPk gPk state) csrftoken
        |> Http.fromJson personDecoder
        |> Task.perform FetchError ToggleSuccess


optUpdateLocal : People -> GroupPk -> PersonPk -> Bool -> People
optUpdateLocal people groupPk personPk state =
    people
        |> List.map (updateLocal groupPk personPk state)


updateLocal : GroupPk -> PersonPk -> Bool -> ElvantoPerson -> ElvantoPerson
updateLocal groupPk personPk state person =
    if person.pk == personPk then
        { person
            | disabledGroups = (updateDisabledGroupsList groupPk state person.disabledGroups)
        }
    else
        person


updateDisabledGroupsList : GroupPk -> Bool -> List GroupPk -> List GroupPk
updateDisabledGroupsList groupPk state groups =
    if state then
        let
            ( _, newGroups ) =
                groups
                    |> List.partition (\pk -> pk == groupPk)
        in
            newGroups
    else
        groupPk :: groups


replaceRecordByPk : List { a | pk : Int } -> { a | pk : Int } -> List { a | pk : Int }
replaceRecordByPk objs updated =
    objs
        |> List.map (updateObj updated)


updateObj : { a | pk : Int } -> { a | pk : Int } -> { a | pk : Int }
updateObj newObj oldObj =
    if newObj.pk == oldObj.pk then
        newObj
    else
        oldObj
