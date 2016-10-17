module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Models exposing (..)
import Html.App as App
import DjangoSend exposing (csrfSend, CSRFToken)
import Regex
import Actions exposing (..)
import Messages exposing (..)
import Views exposing (errorView, mainView)
import Time exposing (Time, minute)


main =
    App.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    { csrftoken : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { groups = []
      , people = []
      , csrftoken = flags.csrftoken
      , groupFilter = nullRegex
      , personFilter = nullRegex
      , displayGroup = False
      , activeGroupPk = 0
      , emailField = ""
      , pushAutoField = False
      , error = False
      , formStatus = NoRequest
      }
    , fetchGroups flags.csrftoken
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Load data
        LoadGroups ->
            ( model, (fetchGroups model.csrftoken) )

        LoadPeople ->
            ( model, (fetchPeople model.csrftoken) )

        -- Main page updates
        PullAllNow ->
            ( model, (submitPushAllRequestCmd model) )

        PushAllNow ->
            ( model, (submitPullAllRequestCmd model) )

        ShowGroup pk email pushAuto ->
            ( { model | groupFilter = nullRegex, displayGroup = True, activeGroupPk = pk, emailField = (Maybe.withDefault "" email), pushAutoField = pushAuto }, Cmd.none )

        UpdateGroupFilter filterText ->
            ( { model | groupFilter = (updateFilterRegex filterText) }, Cmd.none )

        -- Group page updates
        HideGroup ->
            ( { model | displayGroup = False, activeGroupPk = 0, formStatus = NoRequest }, Cmd.none )

        PushNow ->
            ( model, (submitPushRequestCmd model) )

        ToggleAuto groupPk state ->
            ( { model | pushAutoField = (not state) }, (toggleAutoSyncCmd groupPk state model.csrftoken) )

        FormEmail email ->
            ( { model | emailField = email }, Cmd.none )

        FormSubmit model ->
            ( { model | formStatus = RequestSent }, (submitFormCmd model) )

        UpdatePersonFilter filterText ->
            ( { model | personFilter = (updateFilterRegex filterText) }, Cmd.none )

        -- Group table updates
        ToggleGlobal pk state ->
            ( (optUpdateGlobal model pk state), (toggleGlobalCmd pk state model.csrftoken) )

        ToggleLocal groupPk personPk state ->
            ( (optUpdateLocal model groupPk personPk state), (toggleLocalCmd groupPk personPk state model.csrftoken) )

        -- Http result updates
        FetchSuccess groups ->
            ( { model | groups = groups }, (fetchPeople model.csrftoken) )

        FetchPeopleSuccess people ->
            ( { model | people = people }, Cmd.none )

        FetchError error ->
            ( { model | error = True }, Cmd.none )

        ToggleAutoSuccess group ->
            ( model, (fetchGroups model.csrftoken) )

        FormSubmitSuccess arg ->
            ( { model | formStatus = RequestSuccess }, (fetchGroups model.csrftoken) )

        FormSubmitError error ->
            ( { model | formStatus = RequestFail }, Cmd.none )

        ToggleSuccess person ->
            ( model, (fetchGroups model.csrftoken) )



-- VIEW


view : Model -> Html Msg
view model =
    if model.error then
        div [ class "container" ]
            [ errorView
            ]
    else
        div [ class "container" ]
            [ mainView model
            ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every minute (\t -> LoadGroups)
