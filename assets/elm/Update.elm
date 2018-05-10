module Update exposing (update)

import Actions exposing (..)
import Browser.Navigation
import Cache exposing (..)
import DjangoSend exposing (CSRFToken)
import ElvantoModels exposing (..)
import Helpers exposing (..)
import Http.Progress as Progress exposing (Progress(..))
import Messages exposing (..)
import Models exposing (..)
import Nav
import Regex


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlChange maybeRoute ->
            case maybeRoute of
                Just (Group pk) ->
                    ( { model
                        | currentRoute = Group pk
                        , activeGroupPk = pk
                        , emailField = getGroupEmail model.groups pk
                        , pushAutoField = getGroupPushAuto model.groups pk
                      }
                    , focus "personfilter"
                    )

                _ ->
                    ( { model
                        | currentRoute = Home
                        , activeGroupPk = 0
                        , formStatus = NoRequest
                        , pushGroupStatus = NotClicked
                        , groupFilter = nullRegex
                      }
                    , focus "groupfilter"
                    )

        -- Load data
        LoadData ->
            ( { model
                | fetchGroups = True
                , groupsLoadingProgress = 0
                , peopleLoadingProgress = 0
                , fetchPeople = True
              }
            , Cmd.none
            )

        GetGroupProgress None ->
            ( { model | groupsLoadingProgress = 0 }, Cmd.none )

        GetGroupProgress (Some progress) ->
            ( { model | groupsLoadingProgress = percentDone progress }, Cmd.none )

        GetGroupProgress (Fail _) ->
            ( failedRequest model, Cmd.none )

        GetGroupProgress (Done groups) ->
            ( { model
                | groups = groups
                , groupsLoadingProgress = 100
                , error = False
                , fetchGroups = False
              }
            , saveGroups groups
            )

        GetPeopleProgress None ->
            ( { model | peopleLoadingProgress = 0 }, Cmd.none )

        GetPeopleProgress (Some progress) ->
            ( { model | peopleLoadingProgress = percentDone progress }, Cmd.none )

        GetPeopleProgress (Fail _) ->
            ( failedRequest model, Cmd.none )

        GetPeopleProgress (Done people) ->
            ( { model
                | people = people
                , emailField = getGroupEmail model.groups model.activeGroupPk
                , pushAutoField = getGroupPushAuto model.groups model.activeGroupPk
                , peopleLoadingProgress = 100
                , firstPageLoad = False
                , error = False
                , fetchPeople = False
              }
            , savePeople people
            )

        -- Main page updates
        PullAllNow ->
            ( { model | pullAllStatus = Clicked }, submitPullAllRequest model )

        PushAllNow ->
            ( { model | pushAllStatus = Clicked }, submitPushAllRequest model )

        ShowGroup group ->
            ( model, Browser.Navigation.pushUrl (Nav.toPath (Group group.pk)) )

        UpdateGroupFilter filterText ->
            ( { model | groupFilter = textToRegex filterText }, Cmd.none )

        -- Group page updates
        HideGroup ->
            ( model, Browser.Navigation.pushUrl (Nav.toPath Home) )

        PushNow ->
            ( { model | pushGroupStatus = Clicked }, submitPushRequest model )

        ToggleAuto groupPk state ->
            ( { model | pushAutoField = not state }, toggleAutoSync groupPk state model.csrftoken )

        ToggleAutoResp (Ok group) ->
            ( { model | groups = replaceRecordByPk model.groups group }, Cmd.none )

        ToggleAutoResp (Err _) ->
            ( failedRequest model, Cmd.none )

        FormEmailChange email ->
            ( { model | emailField = email }, Cmd.none )

        FormSubmit model_ ->
            ( { model | formStatus = RequestSent }, submitForm model_ )

        FormSubmitResp (Ok arg) ->
            ( { model | formStatus = RequestSuccess, fetchPeople = True, fetchGroups = True }, Cmd.none )

        FormSubmitResp (Err _) ->
            ( { model | formStatus = RequestFail }, Cmd.none )

        UpdatePersonFilter filterText ->
            ( { model | personFilter = textToRegex filterText }, Cmd.none )

        -- Group table updates
        ToggleGlobal pk state ->
            ( { model | people = optUpdateGlobal model.people pk state }
            , toggleGlobal pk state model.csrftoken
            )

        ToggleLocal gPk pPk state ->
            ( { model
                | people = optUpdateLocal model.people gPk pPk state
              }
            , toggleLocal gPk pPk state model.csrftoken
            )

        ToggleResp (Ok person) ->
            ( { model | people = replaceRecordByPk model.people person }, Cmd.none )

        ToggleResp (Err _) ->
            ( failedRequest model, Cmd.none )
