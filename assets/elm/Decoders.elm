module Decoders exposing (..)

import ElvantoModels exposing (..)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required, decode)
import Json.Encode as Encode


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
    decode ElvantoPerson
        |> required "email" Decode.string
        |> required "fullName" Decode.string
        |> required "pk" Decode.int
        |> required "disabledEntirely" Decode.bool
        |> required "disabledGroups" (Decode.list Decode.int)


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True
