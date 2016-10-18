module Decoders exposing (..)

import Json.Decode as Decode exposing ((:=), maybe)
import Json.Decode.Pipeline exposing (optional, required, decode)
import Json.Encode as Encode
import Models exposing (..)


apply : Decode.Decoder (a -> b) -> Decode.Decoder a -> Decode.Decoder b
apply func value =
    Decode.object2 (<|) func value


groupDecoder : Decode.Decoder ElvantoGroup
groupDecoder =
    decode ElvantoGroup
        |> required "pk" Decode.int
        |> required "name" Decode.string
        |> required "google_email" (Decode.maybe Decode.string)
        |> required "push_auto" Decode.bool
        |> required "last_pushed" (Decode.maybe Decode.string)
        |> required "last_pulled" (Decode.maybe Decode.string)
        |> required "total_disabled_people_in_group" Decode.int
        |> required "people_pks" (Decode.list Decode.int)


personDecoder : Decode.Decoder ElvantoPerson
personDecoder =
    Decode.object5 ElvantoPerson
        ("email" := Decode.string)
        ("full_name" := Decode.string)
        ("pk" := Decode.int)
        ("disabled_entirely" := Decode.bool)
        ("disabled_groups" := Decode.list Decode.int)


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True
