module View exposing (view)

import Actions exposing (..)
import GroupViews exposing (groupView)
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onWithOptions)
import Json.Decode as Json
import Messages exposing (..)
import Models exposing (..)
import Nav.Models exposing (..)
import ElvantoModels exposing (..)


view : Model -> Html Msg
view model =
    if model.error then
        div [ class "container" ]
            [ errorView
            ]
    else
        div [ class "container" ]
            [ loadingIndicator model
            , mainView model
            ]


loadingIndicator : Model -> Html Msg
loadingIndicator model =
    if model.firstLoadDone then
        div [] []
    else
        div
            [ class "pos-f-t"
            , style
                [ ( "min-height", (toString model.height) ++ "px" )
                ]
            ]
            [ div
                [ class "pos-f-t"
                , style
                    [ ( "z-index", "100000" )
                    , ( "top", toString ((round ((toFloat model.height) / 2)) - 32) ++ "px" )
                    , ( "font-size", "32px" )
                    ]
                ]
                [ div [ class "text-xs-center" ] [ text "Loading" ]
                , progress
                    [ class "progress progress-success"
                    , value (toString model.loadingProgress)
                    , Html.Attributes.max "100"
                    ]
                    []
                ]
            , div
                [ class "pos-f-t"
                , style
                    [ ( "background-color", "#ddd" )
                    , ( "min-height", (toString model.height) ++ "px" )
                    , ( "opacity", ".75" )
                    ]
                ]
                []
            ]


errorView : Html Msg
errorView =
    div [ class "alert alert-danger " ]
        [ p [] [ text "Uh, oh, something went seriously wrong there." ]
        , p [] [ text "You may not have an internet connection." ]
        , p [] [ text "Please try refreshing the page." ]
        ]


mainView : Model -> Html Msg
mainView model =
    case model.currentPage of
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
                , type' "text"
                , placeholder "Filter..."
                , onInput UpdateGroupFilter
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
        |> List.filter (filterRecord model.groupFilter)
        |> List.map (groupRow model.people)


groupRow : People -> ElvantoGroup -> Html Msg
groupRow people group =
    tr []
        [ td [] [ nameLink group ]
        , td [] [ text (Maybe.withDefault "" group.googleEmail) ]
        , td [] [ dateCell group.lastPulled ]
        , td [] [ dateCell group.lastPushed ]
        , td [] [ text (toString (List.length group.people)) ]
        , td [] [ text (toString (numDisabledPeople group people)) ]
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
            }
    in
        onWithOptions "click" options (Json.succeed message)
