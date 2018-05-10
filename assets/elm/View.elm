module View exposing (view)

import Actions exposing (..)
import Browser
import ElvantoModels exposing (..)
import GroupViews exposing (groupView)
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes as A exposing (..)
import Html.Events exposing (custom, onInput)
import Json.Decode as Json
import Messages exposing (..)
import Models exposing (..)


view : Model -> Browser.Page Msg
view model =
    if model.error then
        { title = "E -> G: Error!"
        , body =
            [ div [ class "container" ]
                [ errorView
                ]
            ]
        }

    else
        { title = routeTitle model
        , body =
            [ loadingIndicator 2 "#03A9F4" model.groupsLoadingProgress
            , loadingIndicator 0 "#8BC34A" model.peopleLoadingProgress
            , div [ class "container" ] [ mainView model ]
            ]
        }


routeTitle : Model -> String
routeTitle model =
    case model.currentRoute of
        Home ->
            "E -> G"

        Group pk ->
            let
                group =
                    getCurrentGroup model.groups model.activeGroupPk
            in
            "E -> G: " ++ group.name


loadingIndicator : Int -> String -> Int -> Html Msg
loadingIndicator top colour progress =
    div
        [ A.style "height" "2px"
        , A.style "z-index" "100000"
        , A.style "top" (String.fromInt top ++ "px")
        , A.style "position" "fixed"
        , A.style "opacity" "1"
        , A.style "background" colour
        , A.style "transition" "all .1s ease"
        , A.style "width" (String.fromInt progress ++ "%")
        ]
        []


errorView : Html Msg
errorView =
    div [ class "alert alert-danger " ]
        [ p [] [ text "Uh, oh, something went seriously wrong there." ]
        , p [] [ text "You may not have an internet connection." ]
        , p [] [ text "Please try refreshing the page." ]
        ]


mainView : Model -> Html Msg
mainView model =
    case model.currentRoute of
        Home ->
            mainTable model

        Group pk ->
            groupView model


mainTable : Model -> Html Msg
mainTable model =
    div [ class "six column" ]
        [ h1 [ class "page-header" ] [ text "Overview" ]
        , br [] []
        , div []
            [ pushAllButton model
            , pullAllButton model
            , br [] []
            ]
        , div [ class "input-group" ]
            [ span [ class "input-group-addon" ] [ text "Filter" ]
            , input
                [ class "form-control"
                , type_ "text"
                , placeholder "Filter..."
                , onInput UpdateGroupFilter
                , id "groupfilter"
                ]
                []
            ]
        , div [ class "table-responsive" ]
            [ table [ class "table table-bordered table-sm" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Name" ]
                        , th [] [ text "Email Address" ]
                        , th [] [ text "Last Pull" ]
                        , th [] [ text "Last Push" ]
                        , th [] [ text "Total # Ppl" ]
                        , th [] [ text "# Excl. Ppl" ]
                        , th [] [ text "Auto?" ]
                        ]
                    ]
                , tbody [] (groupRows model)
                ]
            ]
        ]


groupRows : Model -> List (Html Msg)
groupRows model =
    model.groups
        |> List.filter (filterRecord model.groupFilter groupToString)
        |> List.map (groupRow model.people)


groupRow : People -> ElvantoGroup -> Html Msg
groupRow people group =
    tr []
        [ td [] [ nameLink group ]
        , td [] [ text (Maybe.withDefault "" group.googleEmail) ]
        , td [] [ dateCell group.lastPulled ]
        , td [] [ dateCell group.lastPushed ]
        , td [] [ text (String.fromInt (List.length group.people)) ]
        , td [] [ text (String.fromInt (numDisabledPeople group people)) ]
        , td [] [ syncIndicator group.pushAuto ]
        ]


nameLink : ElvantoGroup -> Html Msg
nameLink group =
    a [ href "", onClick (ShowGroup group) ] [ text group.name ]


syncIndicator : Bool -> Html Msg
syncIndicator bool =
    if bool then
        span [ class "tag tag-primary" ] [ text "Syncing" ]

    else
        div [] []


dateCell : Maybe String -> Html Msg
dateCell date =
    div [] [ text (Maybe.withDefault "Never" date) ]


pushAllButton : Model -> Html Msg
pushAllButton model =
    case model.pushAllStatus of
        NotClicked ->
            button [ class "btn btn-warning", onClick PushAllNow ] [ text "Push All" ]

        Clicked ->
            button [ class "btn btn-disabled" ] [ text "Pushing..." ]


pullAllButton : Model -> Html Msg
pullAllButton model =
    case model.pullAllStatus of
        NotClicked ->
            button [ class "btn btn-primary pull-xs-right", onClick PullAllNow ] [ text "Pull All" ]

        Clicked ->
            button [ class "btn btn-disabled pull-xs-right" ] [ text "Pullling..." ]


onClick : msg -> Attribute msg
onClick message =
    let
        options =
            { stopPropagation = True
            , preventDefault = True
            , message = message
            }
    in
    custom "click" (Json.succeed options)
