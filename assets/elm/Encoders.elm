module Encoders exposing (..)

import Http
import Json.Encode as Encode


encodeBody : List ( String, Encode.Value ) -> Http.Body
encodeBody data =
    data
        |> Encode.object
        |> Encode.encode 0
        |> Http.string


toggleSyncBody : Int -> Bool -> Http.Body
toggleSyncBody pk state =
    [ ( "pk", Encode.int pk ), ( "push_auto", Encode.bool (not state) ) ]
        |> encodeBody


toggleGlobalBody : Int -> Bool -> Http.Body
toggleGlobalBody pk state =
    [ ( "pk", Encode.int pk ), ( "disable", Encode.bool (not state) ) ]
        |> encodeBody


toggleLocalBody : Int -> Int -> Bool -> Http.Body
toggleLocalBody pPk gPk state =
    [ ( "p_id", Encode.int pPk )
    , ( "g_id", Encode.int gPk )
    , ( "disable", Encode.bool state )
    ]
        |> encodeBody


submitFormBody : String -> Bool -> Http.Body
submitFormBody emailField pushAutoField =
    [ ( "google_email", Encode.string emailField )
    , ( "push_auto", Encode.bool pushAutoField )
    ]
        |> encodeBody


pushRequestBody : Int -> Http.Body
pushRequestBody pk =
    [ ( "g_id", Encode.int pk ) ]
        |> encodeBody
