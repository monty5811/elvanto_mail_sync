module Update exposing (update)

import Navigation
import Regex
import Actions exposing (..)
import DjangoSend exposing (csrfSend, CSRFToken)
import Helpers exposing (..)
import Messages exposing (..)
import Models exposing (..)
import ElvantoModels exposing (..)
import Nav.Models exposing (Page(..))
import Nav.Parser exposing (toPath, urlParser)
import Cache exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        -- Load data
        LoadData ->
            ( model, (fetchData model.csrftoken) )

        FetchGroupsSuccess groups ->
            ( { model
                | groups = groups
                , groupsLoadingProgress = 50
                , error = False
              }
            , saveGroups groups
            )

        FetchPeopleSuccess people ->
            ( { model
                | people = people
                , emailField = getGroupEmail model.groups model.activeGroupPk
                , pushAutoField = getGroupPushAuto model.groups model.activeGroupPk
                , peopleLoadingProgress = 50
                , firstPageLoad = False
                , error = False
              }
            , savePeople people
            )

        FetchError error ->
            ( { model
                | error = True
                , firstPageLoad = True
                , groupsLoadingProgress = 0
                , peopleLoadingProgress = 0
              }
            , Cmd.none
            )

        -- Main page updates
        PullAllNow ->
            ( { model | pullAllStatus = Clicked }, (submitPullAllRequest model) )

        PushAllNow ->
            ( { model | pushAllStatus = Clicked }, (submitPushAllRequest model) )

        ShowGroup group ->
            ( model, Navigation.newUrl (toPath (Group group.pk)) )

        UpdateGroupFilter filterText ->
            ( { model | groupFilter = (textToRegex filterText) }, Cmd.none )

        -- Group page updates
        HideGroup ->
            ( model, Navigation.newUrl (toPath Home) )

        PushNow ->
            ( { model | pushGroupStatus = Clicked }, (submitPushRequest model) )

        ToggleAuto groupPk state ->
            ( { model | pushAutoField = (not state) }, (toggleAutoSync groupPk state model.csrftoken) )

        ToggleAutoSuccess group ->
            ( { model | groups = replaceRecordByPk model.groups group }, Cmd.none )

        FormEmailChange email ->
            ( { model | emailField = email }, Cmd.none )

        FormSubmit model ->
            ( { model | formStatus = RequestSent }, (submitForm model) )

        FormSubmitSuccess arg ->
            ( { model | formStatus = RequestSuccess }, (fetchData model.csrftoken) )

        FormSubmitError error ->
            ( { model | formStatus = RequestFail }, Cmd.none )

        UpdatePersonFilter filterText ->
            ( { model | personFilter = (textToRegex filterText) }, Cmd.none )

        -- Group table updates
        ToggleGlobal pk state ->
            ( { model | people = optUpdateGlobal model.people pk state }
            , (toggleGlobal pk state model.csrftoken)
            )

        ToggleLocal gPk pPk state ->
            ( { model
                | people = optUpdateLocal model.people gPk pPk state
              }
            , (toggleLocal gPk pPk state model.csrftoken)
            )

        ToggleSuccess person ->
            ( { model | people = (replaceRecordByPk model.people person) }, Cmd.none )

        -- Window size
        WinResize size ->
            ( { model | height = size.height }, Cmd.none )
