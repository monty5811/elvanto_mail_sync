module Main exposing (..)

import Browser
import Messages exposing (Msg(..))
import Models exposing (Flags, Model, initialModel)
import Nav
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.fullscreen
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onNavigation = Just Nav.urlUpdate
        }


init : Browser.Env Flags -> ( Model, Cmd Msg )
init { url, flags } =
    ( initialModel flags <| Nav.toRoute url, Cmd.none )
