module Nav.Update exposing (..)

import Navigation
import Actions exposing (pageLoadInit)
import Helpers exposing (..)
import Messages exposing (Msg(..))
import Models exposing (..)
import ElvantoModels exposing (..)
import Nav.Models exposing (Page(..))
import Nav.Parser exposing (..)


urlUpdate : Result String Page -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    case result of
        Err _ ->
            ( model, Navigation.modifyUrl (toPath model.currentPage) )

        Ok page ->
            case page of
                Group pk ->
                    ( { model
                        | currentPage = page
                        , activeGroupPk = pk
                        , emailField = getGroupEmail model.groups pk
                        , pushAutoField = getGroupPushAuto model.groups pk
                      }
                    , pageLoadInit model
                    )

                _ ->
                    ( { model
                        | currentPage = page
                        , activeGroupPk = 0
                        , formStatus = NoRequest
                        , pushGroupStatus = NotClicked
                        , groupFilter = nullRegex
                      }
                    , pageLoadInit model
                    )
