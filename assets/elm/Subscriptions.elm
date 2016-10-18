module Subscriptions exposing (subscriptions)

import Models exposing (..)
import Messages exposing (..)
import Time exposing (Time, minute)


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every minute (\t -> LoadGroups)
