var GroupRow = React.createClass({displayName: "GroupRow",
    render: function () {
        return (
            React.createElement("tr", null, 
                React.createElement("td", null, React.createElement("a", {href: this.props.group.url}, this.props.group.name)), 
                React.createElement("td", null, this.props.group.google_email), 
                React.createElement("td", null, this.props.group.last_pulled), 
                React.createElement("td", null, this.props.group.last_pushed), 
                React.createElement("td", null, this.props.group.total_people_in_group), 
                React.createElement("td", null, this.props.group.total_disabled_people_in_group)
            )
        )
    }
});

var AllGroupsTable = React.createClass({displayName: "AllGroupsTable",
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
        var groupNodes = this.state.data.map(function (group, index) {
                return (
                    React.createElement(GroupRow, {group: group, key: index}
                    )
                    )
        });
        return (
            React.createElement("table", {className: "table table-condensed table-striped"}, 
            React.createElement("thead", null, 
            React.createElement("tr", null, 
            React.createElement("th", null, "Name"), 
            React.createElement("th", null, "Email Address"), 
            React.createElement("th", null, "Last Pull"), 
            React.createElement("th", null, "Last Push"), 
            React.createElement("th", null, "Total # Ppl"), 
            React.createElement("th", null, "# Excluded Ppl")
            )
            ), 
            React.createElement("tbody", {className: "searchable"}, 
            groupNodes
            )
            )
        );
    }
});
