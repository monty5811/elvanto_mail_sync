module DjangoSend exposing (..)

import Http exposing (..)
import Task exposing (Task)
import Json.Decode as Decode


type alias CSRFToken =
    String


post : String -> Http.Body -> CSRFToken -> Decode.Decoder a -> Request a
post url body csrftoken decoder =
    request
        { method = "POST"
        , headers =
            [ header "X-CSRFToken" csrftoken
            ]
        , url = url
        , body = body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = True
        }


get : String -> Http.Body -> Decode.Decoder a -> Request a
get url body decoder =
    request
        { method = "GET"
        , headers = []
        , url = url
        , body = body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = True
        }
