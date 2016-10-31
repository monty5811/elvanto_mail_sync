port module Cache exposing (..)

import ElvantoModels exposing (..)


port saveGroups : Groups -> Cmd msg


port savePeople : People -> Cmd msg
