module View exposing (view)

import Actions exposing (..)
import ElvantoModels exposing (..)
import GroupViews exposing (groupView)
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onWithOptions)
import Json.Decode as Json
import Messages exposing (..)
import Models exposing (..)


view : Model -> Html Msg
view model =
    if model.error then
        div [ class "container" ]
            [ errorView
            ]
    else
        div []
            [ loadingIndicator 2 "#03A9F4" model.groupsLoadingProgress
            , loadingIndicator 0 "#8BC34A" model.peopleLoadingProgress
            , div [ class "container" ] [ mainView model ]
            ]


loadingIndicator : Int -> String -> Int -> Html Msg
loadingIndicator top colour progress =
    div
        [ style
            [ ( "height", "2px" )
            , ( "z-index", "100000" )
            , ( "top", (toString top) ++ "px" )
            , ( "position", "fixed" )
            , ( "opacity", "1" )
            , ( "background", colour )
            , ( "transition", "all .1s ease" )
            , ( "width", (toString progress) ++ "%" )
            ]
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
