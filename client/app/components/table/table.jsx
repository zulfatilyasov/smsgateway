import React from 'react';
import styles from './table.less';
import classBuilder from 'classnames';
import {FontIcon} from 'material-ui';

function getItemStatusText(item) {
    if(item.incoming)
        return 'Received';
    if(item.status === 'sent')
        return 'Sent'
    if(item.status === 'failed')
        return 'Failed'
    if(item.status === 'sending')
        return 'Sending'
}

class Table extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {

        var rows = [];
        var items = this.props.rowItems;

        for (var i = items.length - 1; i >= 0; i--) {
            var item = items[i];
            var statusClass = classBuilder({
                'status-td':true,
                success: item.status === 'sent',
                fail: item.status === 'failed',
                sending: item.status === 'sending',
                received: item.incoming === true
            });
            item.statusText = getItemStatusText(item);
            var iconClassName = classBuilder({
                'icon-arrow-with-circle-left outcoming': item.outcoming,
                'icon-arrow-with-circle-right incoming': item.incoming
            });
            if (item) {
                rows.push(<tr key={item.id}>
                    <td className="icon"><FontIcon  className={iconClassName} /></td>
                    <td data-title="Status " className={statusClass}><div className="status status-block">{item.statusText}</div></td>
                    <td data-title="Contact">{item.address}</td>
                    <td data-title="Message">{item.body}</td>
                </tr>);
            }
        }
        return (
            <div className="table-responsive-vertical">
                <table id="table" className="table table-hover table-bordered table-mc-light-blue">
                    <thead>
                    <tr>
                        <th className="icon"></th>
                        <th className="status-th">Status</th>
                        <th>Contact</th>
                        <th>Message</th>
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