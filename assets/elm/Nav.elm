module Nav exposing (toPath, toRoute, urlUpdate)

import ElvantoModels exposing (GroupPk, Groups, nullRegex)
import Helpers exposing (..)
import Messages exposing (Msg(..))
import Models exposing (..)
import Url
import Url.Parser exposing ((</>), Parser, Url, int, map, oneOf, parse, s)


urlUpdate : Url -> Msg
urlUpdate url =
    UrlChange <| toRoute url


toRoute : Url -> Maybe Route
toRoute url =
    parse routeParser url


toPath : Route -> String
toPath route =
    case route of
        Home ->
            Url.absolute [] []

        Group id ->
            Url.absolute [ "/group/", String.fromInt id ] []


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Home (s "")
        , map Group (s "group" </> int)
        ]
