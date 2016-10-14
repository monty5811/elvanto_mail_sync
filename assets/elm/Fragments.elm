module Fragments exposing (..)

import Html exposing (..)
import Html.Lazy exposing (lazy)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Regex
import Models exposing (..)
import Messages exposing (..)
import Actions exposing (..)


errorView : Html Msg
errorView =
    div [ class "alert alert-danger " ]
        [ p [] [ text "Uh, oh, something went seriously wrong there." ]
        , p [] [ text "You may not have an internet connection." ]
        , p [] [ text "Please try refreshing the page." ]
        ]


mainView : Model -> Html Msg
mainView model =
    if model.displayGroup then
        groupView model
    else
        mainTable model


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
    List.map
        lazyGroupRow
        (List.filter (filterGroups model.groupFilter) model.groups)


lazyGroupRow : ElvantoGroup -> Html Msg
lazyGroupRow group =
    lazy groupRow group


groupRow : ElvantoGroup -> Html Msg
groupRow group =
    tr []
        [ td [] [ nameLink group ]
        , td [] [ text (Maybe.withDefault "" group.google_email) ]
        , td [] [ dateCell group.last_pulled ]
        , td [] [ dateCell group.last_pushed ]
        , td [] [ text (toString (List.length group.people)) ]
        , td [] [ text (toString group.total_disabled_people_in_group) ]
        , td [] [ syncIndicator group.push_auto ]
        ]


nameLink : ElvantoGroup -> Html Msg
nameLink group =
    a [ href "#", onClick (ShowGroup group.pk group.google_email group.push_auto) ] [ text group.name ]


syncIndicator : Bool -> Html Msg
syncIndicator bool =
    if bool then
        span [ class "tag tag-primary" ] [ text "Syncing" ]
    else
        div [] []


dateCell : Maybe String -> Html Msg
dateCell date =
    div [] [ text (Maybe.withDefault "Never" date) ]


groupView : Model -> Html Msg
groupView model =
    let
        group =
            getCurrentGroup model.groups model.activeGroupPk

        people =
            getCurrentPeople model.people group
    in
        if model.displayGroup then
            div [ class "six column" ]
                [ div
                    [ class "d-block w-100" ]
                    [ button [ class "btn btn-danger", style [ ( "width", "33%" ) ], onClick HideGroup ] [ text "Close" ]
                    , button [ class "btn btn-success", style [ ( "width", "33%" ) ], onClick PushNow ] [ text "Push to Google" ]
                    , syncButton group model.pushAutoField
                    ]
                , br [] []
                , headerView group
                , br [] []
                , formView model group
                , br [] []
                , groupTableView group people model.personFilter
                ]
        else
            div [] []


headerView : ElvantoGroup -> Html Msg
headerView group =
    div [] [ h1 [] [ text group.name ] ]


pushAllButton : Model -> Html Msg
pushAllButton model =
    button [ class "btn btn-warning", onClick PushAllNow ] [ text "Push All" ]


pullAllButton : Model -> Html Msg
pullAllButton model =
    button [ class "btn btn-primary pull-xs-right", onClick PullAllNow ] [ text "Pull All" ]


syncButton : ElvantoGroup -> Bool -> Html Msg
syncButton group pushAutoField =
    if pushAutoField then
        button [ class "btn btn-success", style [ ( "width", "33%" ) ], onClick (ToggleAuto group.pk pushAutoField) ] [ text "Syncing" ]
    else
        button [ class "btn btn-warning", style [ ( "width", "33%" ) ], onClick (ToggleAuto group.pk pushAutoField) ] [ text "Not Syncing" ]


groupTableView : ElvantoGroup -> People -> Regex.Regex -> Html Msg
groupTableView group people personFilter =
    div [ class "row" ]
        [ div [ class "input-group" ]
            [ span [ class "input-group-addon" ] [ text "Filter" ]
            , input
                [ class "form-control"
                , type' "text"
                , placeholder "Filter..."
                , onInput UpdatePersonFilter
                ]
                []
            ]
        , div [ class "table-responsive" ]
            [ table [ class "table table-bordered table-sm" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Name" ]
                        , th [] [ text "Email Address" ]
                        , th [] [ text "Enabled?" ]
                        , th [] [ text "Globally Enabled?" ]
                        ]
                    ]
                , tbody []
                    (List.map (personRow group.pk) (List.filter (filterPeople personFilter) people))
                ]
            ]
        ]


formView : Model -> ElvantoGroup -> Html Msg
formView model group =
    case model.formStatus of
        NoRequest ->
            emailForm model group

        RequestSent ->
            div [ class "alert alert-info" ]
                [ i [ class "fa fa-spinner" ] []
                , text " saving"
                ]

        RequestSuccess ->
            div []
                [ div [ class "alert alert-success" ]
                    [ text "Update saved"
                    ]
                , emailForm model group
                ]

        RequestFail ->
            div [ class "alert alert-danger" ] [ text "Update not saved! Something went wrong :(" ]


emailForm : Model -> ElvantoGroup -> Html Msg
emailForm model group =
    div []
        [ div [ class "form-group" ]
            [ input [ class "form-control", id "id_google_email", attribute "maxlength" "254", name "google_email", placeholder "Google Email", type' "email", onInput FormEmail, value model.emailField ]
                []
            ]
        , div [ class "form-group" ]
            [ button [ class "btn btn-default", onClick (FormSubmit model) ]
                [ text "Update email" ]
            ]
        ]


personRow : Int -> ElvantoPerson -> Html Msg
personRow pk person =
    tr []
        [ td [] [ text person.full_name ]
        , td [] [ text person.email ]
        , td [] [ disableGroupButton pk person ]
        , td [] [ disableEntirelyButton person ]
        ]


disableGroupButton : Int -> ElvantoPerson -> Html Msg
disableGroupButton pk person =
    let
        disabled =
            List.member pk person.disabled_groups
    in
        if (disabled) then
            button [ class "btn btn-danger btn-sm", onClick (ToggleLocal pk person.pk disabled) ] [ text "Disabled" ]
        else
            button [ class "btn btn-success btn-sm", onClick (ToggleLocal pk person.pk disabled) ] [ text "Enabled" ]


disableEntirelyButton : ElvantoPerson -> Html Msg
disableEntirelyButton person =
    if person.disabled_entirely then
        button [ class "btn btn-danger btn-sm", onClick (ToggleGlobal person.pk person.disabled_entirely) ] [ text "Disabled" ]
    else
        button [ class "btn btn-success btn-sm", onClick (ToggleGlobal person.pk person.disabled_entirely) ] [ text "Enabled" ]
