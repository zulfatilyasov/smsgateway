import React from 'react';
import styles from './table.less';

class Table extends React.Component {
    constructor(props) {
        super(props);
    }


    render() {

        var rows = [];
        var items = this.props.rowItems;
        console.log(items);
        for (var i = items.length - 1; i >= 0; i--) {
            var item = items[i];
            if (item) {
                rows.push(<tr>
                    <td data-title="Status" className="status">{item.status}</td>
                    <td data-title="Contact">{item.contact}</td>
                    <td data-title="Message">{item.message}</td>
                </tr>);
            }
        }
        return (
            <div className="table-responsive-vertical">
                <table id="table" className="table table-hover table-bordered table-mc-light-blue">
                    <thead>
                    <tr>
                        <th>Status</th>
                        <th>Contact</th>
                        <th>Messge</th>
                    </tr>
                    </thead>
                    <tbody>
                    {rows}
                    </tbody>
                </table>
            </div>

        );
    }
}

export default Table