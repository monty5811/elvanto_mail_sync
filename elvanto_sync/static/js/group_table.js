var GroupButton = React.createClass({displayName: "GroupButton",
    render: function () {
    if (this.props.person.disabled_groups.indexOf(parseInt(this.props.groupId)) > -1){
        return React.createElement("button", {type: "button", className: "btn btn-danger btn-xs", onClick: this.props.toggleLocal}, "Disabled")
        } else {
        return React.createElement("button", {type: "button", className: "btn btn-success btn-xs", onClick: this.props.toggleLocal}, "Enabled")
    }
    }
});
var GroupGlobalButton = React.createClass({displayName: "GroupGlobalButton",
    render: function () {
    var divId = 'local-'+this.props.person.pk;
    if (this.props.person.disabled_entirely){
       return React.createElement("button", {type: "button", className: "btn btn-danger btn-xs", onClick: this.props.toggleGlobal}, "Globally Disabled")
        } else {
       return React.createElement("button", {type: "button", className: "btn btn-success btn-xs", onClick: this.props.toggleGlobal}, "Globally Enabled")
    }
    }
});

var GroupRow = React.createClass({displayName: "GroupRow",
    render: function () {
        return (
            React.createElement("tr", null, 
                React.createElement("td", null, this.props.person.email), 
                React.createElement("td", null, this.props.person.full_name), 
                React.createElement("td", null, React.createElement(GroupButton, {person: this.props.person, groupId: this.props.groupId, toggleLocal: this.props.toggleLocal})), 
                React.createElement("td", null, React.createElement(GroupGlobalButton, {person: this.props.person, groupId: this.props.groupId, toggleGlobal: this.props.toggleGlobal}))
            )
        )
    }
});

var GroupTable = React.createClass({displayName: "GroupTable",
    toggleLocal: function (person, groupId) {
        var that = this;
        if (person.disabled_groups.indexOf(parseInt(groupId)) > -1) {
            var disabled_boolean = '1';
        } else {
            var disabled_boolean = '0';
        }
        $.ajax({
            url: '/buttons/update_local/',
            type: "POST",
            data: {'g_id':groupId, 'p_id': person.pk, "disabled_boolean": disabled_boolean},
            success: function (json) {
                that.loadResponsesFromServer()
            },
            error: function (xhr, errmsg, err) {
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    toggleGlobal: function (person, groupId) {
        var that = this;
        var currentState = person.disabled_entirely;
          this.state.data[this.state.data.indexOf(person)].disabled_entirely = !currentState
        this.setState({date: this.state.data});
        if (currentState) {
            var disabled_boolean = '0';
        } else {
            var disabled_boolean = '1';
        }
        $.ajax({
            url: '/buttons/update_global/',
            type: "POST",
            data: {'p_id': person.pk, "disabled_boolean": disabled_boolean},
            success: function (json) {
                that.loadResponsesFromServer()
            },
            error: function (xhr, errmsg, err) {
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    loadResponsesFromServer: function () {
        $.ajax({
            url: this.props.url,
            dataType: 'json',
            success: function (data) {
                this.setState({data: data});
            }.bind(this),
            error: function (xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }.bind(this)
        });
    },
    getInitialState: function () {
        return {data: []};
    },
    componentDidMount: function () {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function () {
        var that = this;
        var groupNodes = this.state.data.map(function (person, index) {
                return (
                    React.createElement(GroupRow, {person: person, groupId: that.props.groupId, key: index, toggleLocal: that.toggleLocal.bind(null, person, that.props.groupId), toggleGlobal: that.toggleGlobal.bind(null, person)}
                    )
                    )
        });
        return (
            React.createElement("table", {className: "table table-condensed table-striped"}, 
            React.createElement("thead", null, 
            React.createElement("tr", null, 
            React.createElement("th", null, "Email"), 
            React.createElement("th", null, "Name"), 
            React.createElement("th", null), 
            React.createElement("th", null)
            )
            ), 
            React.createElement("tbody", {className: "searchable"}, 
            groupNodes
            )
            )
        );
    }
});
