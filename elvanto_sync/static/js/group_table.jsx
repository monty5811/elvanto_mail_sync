var GroupButton = React.createClass({
    render: function () {
    if (this.props.person.disabled_groups.indexOf(parseInt(this.props.groupId)) > -1){
        return <button type="button" className="btn btn-danger btn-xs" onClick={this.props.toggleLocal}>Disabled</button>
        } else {
        return <button type="button" className="btn btn-success btn-xs" onClick={this.props.toggleLocal}>Enabled</button>
    }
    }
});
var GroupGlobalButton = React.createClass({
    render: function () {
    var divId = 'local-'+this.props.person.pk;
    if (this.props.person.disabled_entirely){
       return <button type="button" className="btn btn-danger btn-xs" onClick={this.props.toggleGlobal}>Globally Disabled</button>
        } else {
       return <button type="button" className="btn btn-success btn-xs" onClick={this.props.toggleGlobal}>Globally Enabled</button>
    }
    }
});

var GroupRow = React.createClass({
    render: function () {
        return (
            <tr>
                <td>{this.props.person.email}</td>
                <td>{this.props.person.full_name}</td>
                <td><GroupButton person={this.props.person} groupId={this.props.groupId} toggleLocal={this.props.toggleLocal}></GroupButton></td>
                <td><GroupGlobalButton person={this.props.person} groupId={this.props.groupId} toggleGlobal={this.props.toggleGlobal}></GroupGlobalButton></td>
            </tr>
        )
    }
});

var GroupTable = React.createClass({
    toggleLocal: function (person, groupId) {
        var that = this;
        if (person.disabled_groups.indexOf(parseInt(groupId)) > -1) {
            var disable_toggle = true;
        } else {
            var disable_toggle = false;
        }
        $.ajax({
            url: '/buttons/update_local/',
            type: "POST",
            data: {'g_id': groupId, 'p_id': person.pk, "disable": disable_toggle},
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
        $.ajax({
            url: '/buttons/update_global/',
            type: "POST",
            data: {'p_id': person.pk, "disable": !currentState},
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
                    <GroupRow person={person} groupId={that.props.groupId} key={index} toggleLocal={that.toggleLocal.bind(null, person, that.props.groupId)} toggleGlobal={that.toggleGlobal.bind(null, person)}>
                    </GroupRow>
                    )
        });
        return (
            <table className="table table-condensed table-striped">
            <thead>
            <tr>
            <th>Email</th>
            <th>Name</th>
            <th></th>
            <th></th>
            </tr>
            </thead>
            <tbody className="searchable">
            {groupNodes}
            </tbody>
            </table>
        );
    }
});
