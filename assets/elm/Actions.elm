module Actions exposing (..)

import Cache exposing (saveGroups)
import Decoders exposing (..)
import DjangoSend exposing (CSRFToken, get, post)
import ElvantoModels exposing (..)
import Encoders exposing (..)
import Helpers exposing (..)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)



-- All group actions


submitPushAllRequest : Model -> Cmd Msg
submitPushAllRequest model =
    post "/buttons/push_all/" (encodeBody []) model.csrftoken decodeAlwaysTrue
        |> Http.send (always LoadData)


submitPullAllRequest : Model -> Cmd Msg
submitPullAllRequest model =
    post "/buttons/pull_all/" (encodeBody []) model.csrftoken decodeAlwaysTrue
        |> Http.send (always LoadData)



-- Group specific actions


toggleAutoSync : GroupPk -> Bool -> CSRFToken -> Cmd Msg
toggleAutoSync pk state csrftoken =
    post "/buttons/update_sync/" (toggleSyncBody pk state) csrftoken groupDecoder
        |> Http.send ToggleAutoResp


submitForm : Model -> Cmd Msg
submitForm model =
    let
        url =
            groupsUrl ++ String.fromInt model.activeGroupPk

        body =
            submitFormBody model.emailField model.pushAutoField
    in
    post url
        body
        model.csrftoken
        groupDecoder
        |> Http.send FormSubmitResp


submitPushRequest : Model -> Cmd Msg
submitPushRequest model =
    let
        body =
            pushRequestBody model.activeGroupPk
    in
    post "/buttons/push_group/" body model.csrftoken decodeAlwaysTrue
        |> Http.send (always LoadData)



-- Person specific actions


toggleGlobal : PersonPk -> Bool -> CSRFToken -> Cmd Msg
toggleGlobal pk state csrftoken =
    post "/buttons/update_global/" (toggleGlobalBody pk state) csrftoken personDecoder
        |> Http.send ToggleResp


optUpdateGlobal : People -> PersonPk -> Bool -> People
optUpdateGlobal people pk state =
    people
        |> List.map (updateGlobal pk state)


updateGlobal : PersonPk -> Bool -> ElvantoPerson -> ElvantoPerson
updateGlobal pk state person =
    if person.pk == pk then
        { person | disabledEntirely = not state }

    else
        person


toggleLocal : GroupPk -> PersonPk -> Bool -> CSRFToken -> Cmd Msg
toggleLocal gPk pPk state csrftoken =
    post "/buttons/update_local/" (toggleLocalBody pPk gPk state) csrftoken personDecoder
        |> Http.send ToggleResp


optUpdateLocal : People -> GroupPk -> PersonPk -> Bool -> People
optUpdateLocal people groupPk personPk state =
    people
        |> List.map (updateLocal groupPk personPk state)


updateLocal : GroupPk -> PersonPk -> Bool -> ElvantoPerson -> ElvantoPerson
updateLocal groupPk personPk state person =
    if person.pk == personPk then
        { person
            | disabledGroups = updateDisabledGroupsList groupPk state person.disabledGroups
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
