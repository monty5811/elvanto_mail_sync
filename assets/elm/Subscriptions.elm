module Subscriptions exposing (subscriptions)

import Decoders exposing (..)
import DjangoSend exposing (get)
import ElvantoModels exposing (..)
import Http
import Http.Progress as Progress exposing (Progress(..))
import Json.Decode as Decode
import Messages exposing (..)
import Models exposing (..)
import Time exposing (Posix)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (1000 * 60) (\t -> LoadData)
        , groupsSub model
        , peopleSub model
        ]


groupsSub : Model -> Sub Msg
groupsSub model =
    case model.fetchGroups of
        True ->
            get groupsUrl Http.emptyBody (Decode.list groupDecoder)
                |> Progress.track groupsUrl GetGroupProgress

        False ->
            Sub.none


peopleSub : Model -> Sub Msg
peopleSub model =
    case model.fetchPeople of
        True ->
            get peopleUrl Http.emptyBody (Decode.list personDecoder)
                |> Progress.track peopleUrl GetPeopleProgress

        False ->
            Sub.none
