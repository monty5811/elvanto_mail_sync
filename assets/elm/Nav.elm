module Nav exposing (..)

import ElvantoModels exposing (GroupPk)
import ElvantoModels exposing (Groups, nullRegex)
import Helpers exposing (..)
import Messages exposing (Msg(..))
import Models exposing (..)
import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), int, map, oneOf, s)


urlUpdate : Location -> Model -> ( Model, Cmd Msg )
urlUpdate location model =
    let
        page =
            Maybe.withDefault Home (pathParser location)
    in
        case page of
            Group pk ->
                ( { model
                    | currentPage = page
                    , activeGroupPk = pk
                    , emailField = getGroupEmail model.groups pk
                    , pushAutoField = getGroupPushAuto model.groups pk
                  }
                , focus "personfilter"
                )

            _ ->
                ( { model
                    | currentPage = page
                    , activeGroupPk = 0
                    , formStatus = NoRequest
                    , pushGroupStatus = NotClicked
                    , groupFilter = nullRegex
                  }
                , focus "groupfilter"
                )


toPath : Page -> String
toPath page =
    case page of
        Home ->
            "/"

        Group id ->
            "/group/" ++ toString id


pathParser : Location -> Maybe Page
pathParser location =
    UrlParser.parsePath pageParser location


pageParser : Parser (Page -> a) a
pageParser =
    oneOf
        [ map Home (s "")
        , map Group (s "group" </> int)
        ]
