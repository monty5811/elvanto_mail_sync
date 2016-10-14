module Actions exposing (..)

import Task exposing (Task)
import Models exposing (..)
import Http
import Json.Decode as Decode exposing ((:=), maybe)
import DjangoSend exposing (csrfSend, CSRFToken)
import Json.Encode as Encode
import Regex
import Messages exposing (..)
import Decoders exposing (..)


filterByPk : Int -> ElvantoGroup -> Bool
filterByPk pk group =
    if group.pk == pk then
        True
    else
        False


getData : String -> CSRFToken -> Task Http.Error Groups
getData url csrftoken =
    csrfSend url "GET" Http.empty csrftoken
        |> Http.fromJson (Decode.list groupDecoder)


getPeople : String -> CSRFToken -> Task Http.Error People
getPeople url csrftoken =
    csrfSend url "GET" Http.empty csrftoken
        |> Http.fromJson (Decode.list personDecoder)


fetchCmd : String -> CSRFToken -> Cmd Msg
fetchCmd url csrftoken =
    Task.perform FetchError FetchSuccess (getData url csrftoken)


fetchGroups : Model -> Cmd Msg
fetchGroups model =
    fetchCmd groupsUrl model.csrftoken


fetchPeople : Model -> Cmd Msg
fetchPeople model =
    fetchPeopleCmd peopleUrl model.csrftoken


fetchPeopleCmd : String -> CSRFToken -> Cmd Msg
fetchPeopleCmd url csrftoken =
    Task.perform FetchError FetchPeopleSuccess (getPeople url csrftoken)


filterGroups : Regex.Regex -> ElvantoGroup -> Bool
filterGroups regex record =
    Regex.contains regex (toString record)


filterPeople : Regex.Regex -> ElvantoPerson -> Bool
filterPeople regex record =
    Regex.contains regex (toString record)


toggleAutoSyncCmd : Int -> Bool -> CSRFToken -> Cmd Msg
toggleAutoSyncCmd pk state csrftoken =
    toggleAutoSync pk state csrftoken
        |> Task.perform FetchError ToggleAutoSuccess


toggleAutoSync : Int -> Bool -> CSRFToken -> Task Http.Error ElvantoGroup
toggleAutoSync pk state csrftoken =
    csrfSend "/buttons/update_sync/"
        "POST"
        (Http.string
            (Encode.encode 0
                (Encode.object
                    [ ( "pk", Encode.int pk )
                    , ( "push_auto", Encode.bool (not state) )
                    ]
                )
            )
        )
        csrftoken
        |> Http.fromJson groupDecoder


toggleGlobalCmd : Int -> Bool -> CSRFToken -> Cmd Msg
toggleGlobalCmd pk state csrftoken =
    toggleGlobal pk state csrftoken
        |> Task.perform FetchError ToggleSuccess


toggleGlobal : Int -> Bool -> CSRFToken -> Task Http.Error ElvantoPerson
toggleGlobal pk state csrftoken =
    csrfSend "/buttons/update_global/"
        "POST"
        (Http.string
            (Encode.encode 0
                (Encode.object
                    [ ( "pk", Encode.int pk )
                    , ( "disable", Encode.bool (not state) )
                    ]
                )
            )
        )
        csrftoken
        |> Http.fromJson personDecoder


toggleLocalCmd : Int -> Int -> Bool -> CSRFToken -> Cmd Msg
toggleLocalCmd gPk pPk state csrftoken =
    toggleLocal gPk pPk state csrftoken
        |> Task.perform FetchError ToggleSuccess


toggleLocal : Int -> Int -> Bool -> CSRFToken -> Task Http.Error ElvantoPerson
toggleLocal gPk pPk state csrftoken =
    csrfSend "/buttons/update_local/"
        "POST"
        (Http.string
            (Encode.encode 0
                (Encode.object
                    [ ( "p_id", Encode.int pPk )
                    , ( "g_id", Encode.int gPk )
                    , ( "disable", Encode.bool state )
                    ]
                )
            )
        )
        csrftoken
        |> Http.fromJson personDecoder


optUpdateGlobal : Model -> Int -> Bool -> Model
optUpdateGlobal model pk state =
    { model | people = (List.map (updateGlobal pk state) model.people) }


updateGlobal : Int -> Bool -> ElvantoPerson -> ElvantoPerson
updateGlobal pk state person =
    if person.pk == pk then
        { person | disabled_entirely = (not state) }
    else
        person


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


isPk : Int -> Int -> Bool
isPk pk1 pk2 =
    pk1 == pk2


getCurrentGroup : Groups -> Int -> ElvantoGroup
getCurrentGroup groups pk =
    List.filter (\x -> x.pk == pk) groups
        |> List.head
        |> Maybe.withDefault nullGroup


getCurrentPeople : People -> ElvantoGroup -> People
getCurrentPeople people group =
    List.filter (inGroup group) people


inGroup : ElvantoGroup -> ElvantoPerson -> Bool
inGroup group person =
    List.member person.pk group.people


submitFormCmd : Model -> Cmd Msg
submitFormCmd model =
    submitForm model
        |> Task.perform FormSubmitError FormSubmitSuccess


submitForm : Model -> Task Http.Error ElvantoGroup
submitForm model =
    csrfSend (groupsUrl ++ (toString model.activeGroupPk))
        "POST"
        (Http.string
            (Encode.encode 0
                (Encode.object
                    [ ( "google_email", Encode.string model.emailField )
                    , ( "push_auto", Encode.bool model.pushAutoField )
                    ]
                )
            )
        )
        model.csrftoken
        |> Http.fromJson groupDecoder


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True


submitPushRequestCmd : Model -> Cmd Msg
submitPushRequestCmd model =
    submitPushRequest model
        |> Task.perform FetchError (always LoadGroups)


submitPushRequest : Model -> Task Http.Error Bool
submitPushRequest model =
    csrfSend "buttons/push_group/"
        "POST"
        (Http.string
            (Encode.encode 0
                (Encode.object
                    [ ( "g_id", Encode.int model.activeGroupPk ) ]
                )
            )
        )
        model.csrftoken
        |> Http.fromJson decodeAlwaysTrue


submitPushAllRequestCmd : Model -> Cmd Msg
submitPushAllRequestCmd model =
    submitPushAllRequest model
        |> Task.perform FetchError (always LoadGroups)


submitPushAllRequest : Model -> Task Http.Error Bool
submitPushAllRequest model =
    csrfSend "buttons/push_all/"
        "POST"
        (Http.string
            (Encode.encode 0
                (Encode.object
                    []
                )
            )
        )
        model.csrftoken
        |> Http.fromJson decodeAlwaysTrue


submitPullAllRequestCmd : Model -> Cmd Msg
submitPullAllRequestCmd model =
    submitPullAllRequest model
        |> Task.perform FetchError (always LoadGroups)


submitPullAllRequest : Model -> Task Http.Error Bool
submitPullAllRequest model =
    csrfSend "buttons/pull_all/"
        "POST"
        (Http.string
            (Encode.encode 0
                (Encode.object
                    []
                )
            )
        )
        model.csrftoken
        |> Http.fromJson decodeAlwaysTrue
