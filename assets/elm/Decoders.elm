module Decoders exposing (..)

import Json.Decode as Decode exposing ((:=), maybe)
import Json.Decode.Pipeline exposing (optional, required, decode)
import Json.Encode as Encode
import Models exposing (..)
import ElvantoModels exposing (..)


apply : Decode.Decoder (a -> b) -> Decode.Decoder a -> Decode.Decoder b
apply func value =
    Decode.object2 (<|) func value


groupDecoder : Decode.Decoder ElvantoGroup
groupDecoder =
    decode ElvantoGroup
        |> required "pk" Decode.int
        |> required "name" Decode.string
        |> required "googleEmail" (Decode.maybe Decode.string)
        |> required "pushAuto" Decode.bool
        |> required "lastPushed" (Decode.maybe Decode.string)
        |> required "lastPulled" (Decode.maybe Decode.string)
        |> required "peoplePks" (Decode.list Decode.int)


personDecoder : Decode.Decoder ElvantoPerson
personDecoder =
    Decode.object5 ElvantoPerson
        ("email" := Decode.string)
        ("fullName" := Decode.string)
        ("pk" := Decode.int)
        ("disabledEntirely" := Decode.bool)
        ("disabledGroups" := Decode.list Decode.int)


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True
