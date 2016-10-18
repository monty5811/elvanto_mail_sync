module Main exposing (..)

import Navigation
import Models exposing (Flags, Model, initialModel)
import Messages exposing (Msg)
import Nav.Models exposing (Page)
import Nav.Update exposing (urlUpdate)
import Nav.Parser exposing (urlParser)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main : Program Flags
main =
    Navigation.programWithFlags urlParser
        { init = init
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }


init : Flags -> Result String Page -> ( Model, Cmd Msg )
init flags result =
    urlUpdate result (initialModel flags)
