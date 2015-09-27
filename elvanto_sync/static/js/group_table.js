"use strict";

var GroupButton = React.createClass({
    displayName: "GroupButton",

    render: function render() {
        if (this.props.person.disabled_groups.indexOf(parseInt(this.props.groupId)) > -1) {
            return React.createElement(
                "button",
                { type: "button", className: "btn btn-danger btn-xs", onClick: this.props.toggleLocal },
                "Disabled"
            );
        } else {
            return React.createElement(
                "button",
                { type: "button", className: "btn btn-success btn-xs", onClick: this.props.toggleLocal },
                "Enabled"
            );
        }
    }
});
var GroupGlobalButton = React.createClass({
    displayName: "GroupGlobalButton",

    render: function render() {
        var divId = 'local-' + this.props.person.pk;
        if (this.props.person.disabled_entirely) {
            return React.createElement(
                "button",
                { type: "button", className: "btn btn-danger btn-xs", onClick: this.props.toggleGlobal },
                "Globally Disabled"
            );
        } else {
            return React.createElement(
                "button",
                { type: "button", className: "btn btn-success btn-xs", onClick: this.props.toggleGlobal },
                "Globally Enabled"
            );
        }
    }
});

var GroupRow = React.createClass({
    displayName: "GroupRow",

    render: function render() {
        return React.createElement(
            "tr",
            null,
            React.createElement(
                "td",
                null,
                this.props.person.email
            ),
            React.createElement(
                "td",
                null,
                this.props.person.full_name
            ),
            React.createElement(
                "td",
                null,
                React.createElement(GroupButton, { person: this.props.person, groupId: this.props.groupId, toggleLocal: this.props.toggleLocal })
            ),
            React.createElement(
                "td",
                null,
                React.createElement(GroupGlobalButton, { person: this.props.person, groupId: this.props.groupId, toggleGlobal: this.props.toggleGlobal })
            )
        );
    }
});

var GroupTable = React.createClass({
    displayName: "GroupTable",

    toggleLocal: function toggleLocal(person, groupId) {
        var that = this;
        if (person.disabled_groups.indexOf(parseInt(groupId)) > -1) {
            var disable_toggle = true;
        } else {
            var disable_toggle = false;
        }
        $.ajax({
            url: '/buttons/update_local/',
            type: "POST",
            data: { 'g_id': groupId, 'p_id': person.pk, "disable": disable_toggle },
            success: function success(json) {
                that.loadResponsesFromServer();
            },
            error: function error(xhr, errmsg, err) {
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    toggleGlobal: function toggleGlobal(person, groupId) {
        var that = this;
        var currentState = person.disabled_entirely;
        this.state.data[this.state.data.indexOf(person)].disabled_entirely = !currentState;
        this.setState({ date: this.state.data });
        $.ajax({
            url: '/buttons/update_global/',
            type: "POST",
            data: { 'p_id': person.pk, "disable": !currentState },
            success: function success(json) {
                that.loadResponsesFromServer();
            },
            error: function error(xhr, errmsg, err) {
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    loadResponsesFromServer: function loadResponsesFromServer() {
        $.ajax({
            url: this.props.url,
            dataType: 'json',
            success: (function (data) {
                this.setState({ data: data });
            }).bind(this),
            error: (function (xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }).bind(this)
        });
    },
    getInitialState: function getInitialState() {
        return { data: [] };
    },
    componentDidMount: function componentDidMount() {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function render() {
        var that = this;
        var groupNodes = this.state.data.map(function (person, index) {
            return React.createElement(GroupRow, { person: person, groupId: that.props.groupId, key: index, toggleLocal: that.toggleLocal.bind(null, person, that.props.groupId), toggleGlobal: that.toggleGlobal.bind(null, person) });
        });
        return React.createElement(
            "table",
            { className: "table table-condensed table-striped" },
            React.createElement(
                "thead",
                null,
                React.createElement(
                    "tr",
                    null,
                    React.createElement(
                        "th",
                        null,
                        "Email"
                    ),
                    React.createElement(
                        "th",
                        null,
                        "Name"
                    ),
                    React.createElement("th", null),
                    React.createElement("th", null)
                )
            ),
            React.createElement(
                "tbody",
                { className: "searchable" },
                groupNodes
            )
        );
    }
});