module Helpers exposing (..)

import Dom
import ElvantoModels exposing (..)
import Http.Progress as Progress exposing (Progress(..))
import Messages exposing (..)
import Models exposing (..)
import Regex
import Set exposing (Set)
import Task


percentDone : { bytes : Int, bytesExpected : Int } -> Int
percentDone progress =
    100
        * (toFloat progress.bytes)
        / (toFloat progress.bytesExpected)
        |> round


filterRecord : Regex.Regex -> a -> Bool
filterRecord regex record =
    Regex.contains regex (toString record)


getCurrentGroup : Groups -> Int -> ElvantoGroup
getCurrentGroup groups pk =
    List.filter (\x -> pk == x.pk) groups
        |> List.head
        |> Maybe.withDefault nullGroup


getCurrentPeople : People -> ElvantoGroup -> People
getCurrentPeople people group =
    List.filter (inGroup group) people


inGroup : ElvantoGroup -> ElvantoPerson -> Bool
inGroup group person =
    List.member person.pk group.people


textToRegex : String -> Regex.Regex
textToRegex text =
    text
        |> Regex.escape
        |> Regex.regex
        |> Regex.caseInsensitive


getGroupEmail : Groups -> Int -> String
getGroupEmail groups pk =
    getCurrentGroup groups pk
        |> .googleEmail
        |> Maybe.withDefault ""


getGroupPushAuto : Groups -> Int -> Bool
getGroupPushAuto groups pk =
    getCurrentGroup groups pk
        |> .pushAuto


numDisabledPeople : ElvantoGroup -> People -> Int
numDisabledPeople group people =
    let
        peopleInGroup =
            getCurrentPeople people group

        globallyDisabled =
            peopleInGroup
                |> List.filter (\x -> x.disabledEntirely)
                |> List.map (\x -> x.pk)

        locallyDisabled =
            peopleInGroup
                |> List.filter (\person -> List.member group.pk person.disabledGroups)
                |> List.map (\x -> x.pk)
    in
        Set.fromList (List.concat [ globallyDisabled, locallyDisabled ])
            |> Set.size


failedRequest : Model -> Model
failedRequest model =
    { model
        | error = True
        , firstPageLoad = True
        , groupsLoadingProgress = 0
        , peopleLoadingProgress = 0
    }


focus : String -> Cmd Msg
focus id =
    Task.attempt (\_ -> NoOp) (Dom.focus id)
