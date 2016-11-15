module Main exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Flags, Model, initialModel)
import Nav exposing (urlUpdate)
import Navigation exposing (Location, programWithFlags)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main : Program Flags Model Msg
main =
    programWithFlags urlParser
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    urlUpdate location (initialModel flags)


urlParser : Location -> Msg
urlParser location =
    UrlChange location
