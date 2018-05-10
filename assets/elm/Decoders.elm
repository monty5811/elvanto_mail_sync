module Decoders exposing (..)

import ElvantoModels exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode


groupDecoder : Decode.Decoder ElvantoGroup
groupDecoder =
    Decode.map7 ElvantoGroup
        (Decode.field "pk" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "googleEmail" (Decode.maybe Decode.string))
        (Decode.field "pushAuto" Decode.bool)
        (Decode.field "lastPushed" (Decode.maybe Decode.string))
        (Decode.field "lastPulled" (Decode.maybe Decode.string))
        (Decode.field "peoplePks" (Decode.list Decode.int))


personDecoder : Decode.Decoder ElvantoPerson
personDecoder =
    Decode.map5 ElvantoPerson
        (Decode.field "email" Decode.string)
        (Decode.field "fullName" Decode.string)
        (Decode.field "pk" Decode.int)
        (Decode.field "disabledEntirely" Decode.bool)
        (Decode.field "disabledGroups" (Decode.list Decode.int))


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True
