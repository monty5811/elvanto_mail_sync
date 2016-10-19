module Update exposing (update)

import Navigation
import Regex
import Actions exposing (..)
import DjangoSend exposing (csrfSend, CSRFToken)
import Helpers exposing (..)
import Messages exposing (..)
import Models exposing (..)
import Nav.Models exposing (Page(..))
import Nav.Parser exposing (toPath, urlParser)
import Debug


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        -- Load data
        LoadGroups ->
            ( model, (fetchGroups model.csrftoken) )

        LoadPeople ->
            ( model, (fetchPeople model.csrftoken) )

        -- Main page updates
        PullAllNow ->
            ( { model | pullAllStatus = Clicked }, (submitPullAllRequest model) )

        PushAllNow ->
            ( { model | pushAllStatus = Clicked }, (submitPushAllRequest model) )

        ShowGroup pk email pushAuto ->
            ( model, Navigation.newUrl (toPath (Group pk)) )

        UpdateGroupFilter filterText ->
            ( { model | groupFilter = (textToRegex filterText) }, Cmd.none )

        -- Group page updates
        HideGroup ->
            ( model, Navigation.newUrl (toPath Home) )

        PushNow ->
            ( { model | pushGroupStatus = Clicked }, (submitPushRequest model) )

        ToggleAuto groupPk state ->
            ( { model | pushAutoField = (not state) }, (toggleAutoSync groupPk state model.csrftoken) )

        FormEmailChange email ->
            ( { model | emailField = email }, Cmd.none )

        FormSubmit model ->
            ( { model | formStatus = RequestSent }, (submitForm model) )

        UpdatePersonFilter filterText ->
            ( { model | personFilter = (textToRegex filterText) }, Cmd.none )

        -- Group table updates
        ToggleGlobal pk state ->
            ( (optUpdateGlobal model pk state), (toggleGlobal pk state model.csrftoken) )

        ToggleLocal groupPk personPk state ->
            ( (optUpdateLocal model groupPk personPk state), (toggleLocal groupPk personPk state model.csrftoken) )

        -- Http result updates
        FetchGroupsSuccess groups ->
            ( { model
                | groups = groups
                , loadingProgress = 75
              }
            , fetchPeople model.csrftoken
            )

        FetchPeopleSuccess people ->
            ( { model
                | people = people
                , emailField = getGroupEmail model model.activeGroupPk
                , pushAutoField = getGroupPushAuto model model.activeGroupPk
                , loadingProgress = 100
                , firstLoadDone = True
              }
            , Cmd.none
            )

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

        -- Change url
        Go path ->
            ( model, Navigation.newUrl path )

        -- Window size
        WinResize size ->
            ( { model | height = size.height }, Cmd.none )
