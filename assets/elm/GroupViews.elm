module GroupViews exposing (..)

import Actions exposing (..)
import ElvantoModels exposing (..)
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes as A
import Html.Events exposing (onClick, onInput, onSubmit)
import Messages exposing (..)
import Models exposing (..)
import Regex


groupView : Model -> Html Msg
groupView model =
    let
        group =
            getCurrentGroup model.groups model.activeGroupPk

        people =
            getCurrentPeople model.people group
    in
    div [ A.class "six column" ]
        [ div
            [ A.class "d-block w-100" ]
            [ button [ A.class "btn btn-danger", A.style "width" "33%", onClick HideGroup ] [ text "Close" ]
            , pushGroupButton model.pushGroupStatus
            , syncButton group model.pushAutoField
            ]
        , br [] []
        , headerView group
        , currentEmailView group
        , br [] []
        , formView model group
        , br [] []
        , groupTableView group people model.personFilter
        ]


pushGroupButton : ButtonStatus -> Html Msg
pushGroupButton status =
    case status of
        NotClicked ->
            button [ A.class "btn btn-success", A.style "width" "33%", onClick PushNow ] [ text "Push to Google" ]

        Clicked ->
            button [ A.class "btn btn-disabled", A.style "width" "33%" ] [ text "Pushing ..." ]


headerView : ElvantoGroup -> Html Msg
headerView group =
    div [] [ h1 [] [ text group.name ] ]


currentEmailView : ElvantoGroup -> Html Msg
currentEmailView group =
    h4 [] [ text (Maybe.withDefault "[No email set]" group.googleEmail) ]


syncButton : ElvantoGroup -> Bool -> Html Msg
syncButton group pushAutoField =
    if pushAutoField then
        button [ A.class "btn btn-success", A.style "width" "33%", onClick (ToggleAuto group.pk pushAutoField) ] [ text "Syncing" ]

    else
        button [ A.class "btn btn-warning", A.style "width" "33%", onClick (ToggleAuto group.pk pushAutoField) ] [ text "Not Syncing" ]


groupTableView : ElvantoGroup -> People -> Regex.Regex -> Html Msg
groupTableView group people personFilter =
    div [ A.class "row" ]
        [ div [ A.class "input-group" ]
            [ span [ A.class "input-group-addon" ] [ text "Filter" ]
            , input
                [ A.class "form-control"
                , A.type_ "text"
                , A.placeholder "Filter..."
                , onInput UpdatePersonFilter
                , A.id "personfilter"
                ]
                []
            ]
        , div [ A.class "table-responsive" ]
            [ table [ A.class "table table-bordered table-sm" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Name" ]
                        , th [] [ text "Email Address" ]
                        , th [] [ text "Enabled?" ]
                        , th [] [ text "Globally Enabled?" ]
                        ]
                    ]
                , tbody []
                    (people
                        |> List.filter (filterRecord personFilter personToString)
                        |> List.map (personRow group)
                    )
                ]
            ]
        ]


formView : Model -> ElvantoGroup -> Html Msg
formView model group =
    case model.formStatus of
        NoRequest ->
            emailForm model group

        RequestSent ->
            div [ A.class "alert alert-info" ]
                [ i [ A.class "fa fa-spinner" ] []
                , text " saving"
                ]

        RequestSuccess ->
            div []
                [ div [ A.class "alert alert-success" ]
                    [ text "Update saved"
                    ]
                , emailForm model group
                ]

        RequestFail ->
            div [ A.class "alert alert-danger" ] [ text "Update not saved! Something went wrong :(" ]


emailForm : Model -> ElvantoGroup -> Html Msg
emailForm model group =
    div []
        [ Html.form
            [ A.class "form-inline"
            , onSubmit (FormSubmit model)
            ]
            [ div [ A.class "input-group" ]
                [ input
                    [ A.class "form-control"
                    , A.placeholder "Google Email"
                    , A.type_ "email"
                    , onInput FormEmailChange
                    , A.value model.emailField
                    ]
                    []
                , div
                    [ A.class "input-group-addon"
                    , onClick (FormSubmit model)
                    ]
                    [ i [ A.class "fa fa-save" ] []
                    ]
                ]
            ]
        ]


personRow : ElvantoGroup -> ElvantoPerson -> Html Msg
personRow group person =
    tr []
        [ td [] [ text person.fullName ]
        , td [] [ text person.email ]
        , td [] [ disableGroupButton group person ]
        , td [] [ disableEntirelyButton person ]
        ]


disableGroupButton : ElvantoGroup -> ElvantoPerson -> Html Msg
disableGroupButton group person =
    let
        disabled =
            List.member group.pk person.disabledGroups
    in
    if disabled then
        button [ A.class "btn btn-danger btn-sm", onClick (ToggleLocal group.pk person.pk disabled) ] [ text "Disabled" ]

    else
        button [ A.class "btn btn-success btn-sm", onClick (ToggleLocal group.pk person.pk disabled) ] [ text "Enabled" ]


disableEntirelyButton : ElvantoPerson -> Html Msg
disableEntirelyButton person =
    if person.disabledEntirely then
        button [ A.class "btn btn-danger btn-sm", onClick (ToggleGlobal person.pk person.disabledEntirely) ] [ text "Disabled" ]

    else
        button [ A.class "btn btn-success btn-sm", onClick (ToggleGlobal person.pk person.disabledEntirely) ] [ text "Enabled" ]
