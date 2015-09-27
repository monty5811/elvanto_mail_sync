var GroupRow = React.createClass({
    render: function () {
      if (this.props.group.push_auto) { 
        return (
            <tr>
                <td><a href={this.props.group.url}>{this.props.group.name}</a></td>
                <td>{this.props.group.google_email}</td>
                <td>{this.props.group.last_pulled}</td>
                <td>{this.props.group.last_pushed}</td>
                <td>{this.props.group.total_people_in_group}</td>
                <td>{this.props.group.total_disabled_people_in_group}</td>
                <td><span className="label label-info">Syncing</span></td>
            </tr>
        )
      } else { 
        return (
            <tr>
                <td><a href={this.props.group.url}>{this.props.group.name}</a></td>
                <td>{this.props.group.google_email}</td>
                <td>{this.props.group.last_pulled}</td>
                <td>{this.props.group.last_pushed}</td>
                <td>{this.props.group.total_people_in_group}</td>
                <td>{this.props.group.total_disabled_people_in_group}</td>
                <td></td>
            </tr>
        )
      }
    }
});

var AllGroupsTable = React.createClass({
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
                    <GroupRow group={group} key={index}>
                    </GroupRow>
                    )
        });
        return (
            <table className="table table-condensed table-striped">
            <thead>
            <tr>
            <th>Name</th>
            <th>Email Address</th>
            <th>Last Pull</th>
            <th>Last Push</th>
            <th>Total # Ppl</th>
            <th># Excluded Ppl</th>
            <th>Auto?</th>
            </tr>
            </thead>
            <tbody className="searchable">
            {groupNodes}
            </tbody>
            </table>
        );
    }
});
