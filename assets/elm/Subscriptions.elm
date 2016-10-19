module Subscriptions exposing (subscriptions)

import Models exposing (..)
import Messages exposing (..)
import Time exposing (Time, minute)
import Window


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every minute
            (\t -> LoadGroups)
        , Window.resizes WinResize
        ]
