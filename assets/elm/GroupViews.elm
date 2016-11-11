module GroupViews exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Regex
import Actions exposing (..)
import Helpers exposing (..)
import Messages exposing (..)
import Models exposing (..)
import ElvantoModels exposing (..)


groupView : Model -> Html Msg
groupView model =
    let
        group =
            getCurrentGroup model.groups model.activeGroupPk

        people =
            getCurrentPeople model.people group
    in
        div [ class "six column" ]
            [ div
                [ class "d-block w-100" ]
                [ button [ class "btn btn-danger", style [ ( "width", "33%" ) ], onClick HideGroup ] [ text "Close" ]
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
            button [ class "btn btn-success", style [ ( "width", "33%" ) ], onClick PushNow ] [ text "Push to Google" ]

        Clicked ->
            button [ class "btn btn-disabled", style [ ( "width", "33%" ) ] ] [ text "Pushing ..." ]


headerView : ElvantoGroup -> Html Msg
headerView group =
    div [] [ h1 [] [ text group.name ] ]


currentEmailView : ElvantoGroup -> Html Msg
currentEmailView group =
    h4 [] [ text (Maybe.withDefault "[No email set]" group.googleEmail) ]


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
                    (people
                        |> List.filter (filterRecord personFilter)
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
            [ input [ class "form-control", id "id_google_email", attribute "maxlength" "254", name "google_email", placeholder "Google Email", type' "email", onInput FormEmailChange, value model.emailField ]
                []
            ]
        , div [ class "form-group" ]
            [ button [ class "btn btn-default", onClick (FormSubmit model) ]
                [ text "Update email" ]
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
            button [ class "btn btn-danger btn-sm", onClick (ToggleLocal group.pk person.pk disabled) ] [ text "Disabled" ]
        else
            button [ class "btn btn-success btn-sm", onClick (ToggleLocal group.pk person.pk disabled) ] [ text "Enabled" ]


disableEntirelyButton : ElvantoPerson -> Html Msg
disableEntirelyButton person =
    if person.disabledEntirely then
        button [ class "btn btn-danger btn-sm", onClick (ToggleGlobal person.pk person.disabledEntirely) ] [ text "Disabled" ]
    else
        button [ class "btn btn-success btn-sm", onClick (ToggleGlobal person.pk person.disabledEntirely) ] [ text "Enabled" ]
