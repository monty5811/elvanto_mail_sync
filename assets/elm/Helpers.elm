module Helpers exposing (..)

import Regex
import Models exposing (..)


filterRecord : Regex.Regex -> a -> Bool
filterRecord regex record =
    Regex.contains regex (toString record)


isPk : Int -> Int -> Bool
isPk pk1 pk2 =
    pk1 == pk2


getCurrentGroup : Groups -> Int -> ElvantoGroup
getCurrentGroup groups pk =
    List.filter (\x -> (isPk pk x.pk)) groups
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
    Regex.regex (Regex.escape text)


getGroupEmail : Model -> Int -> String
getGroupEmail model pk =
    getCurrentGroup model.groups pk
        |> .google_email
        |> Maybe.withDefault ""


getGroupPushAuto : Model -> Int -> Bool
getGroupPushAuto model pk =
    getCurrentGroup model.groups pk
        |> .push_auto
