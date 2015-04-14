import React from 'react';
import styles from './table.less';

class Table extends React.Component {
    render() {
        return (
            <div className="table-responsive-vertical">
                <table id="table" className="table table-hover table-bordered table-mc-light-blue">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Link</th>
                        <th>Status</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td data-title="ID">1</td>
                        <td data-title="Name">Material Design Sidebar</td>
                        <td data-title="Link"><a href="http://codepen.io/zavoloklom/pen/dIgco" target="_blank">Link</a></td>
                        <td data-title="Status">Completed</td>
                    </tr>
                    <tr>
                        <td data-title="ID">2</td>
                        <td data-title="Name">Material Design Tiles</td>
                        <td data-title="Link">
                            <a href="http://codepen.io/zavoloklom/pen/wtApI" target="_blank">Link</a>
                        </td>
                        <td data-title="Status">Completed</td>
                    </tr>
                    <tr>
                        <td data-title="ID">3</td>
                        <td data-title="Name">Material Design Animation Timing</td>
                        <td data-title="Link">
                            <a href="http://codepen.io/zavoloklom/pen/Jbrho" target="_blank">Link</a>
                        </td>
                        <td data-title="Status">Completed</td>
                    </tr>
                    <tr>
                        <td data-title="ID">4</td>
                        <td data-title="Name">Material Design Iconic Font</td>
                        <td data-title="Link">
                            <a href="http://codepen.io/zavoloklom/pen/uqCsB" target="_blank">Link</a>
                        </td>
                        <td data-title="Status">Completed</td>
                    </tr>
                    <tr>
                        <td data-title="ID">5</td>
                        <td data-title="Name">Material Design Typography</td>
                        <td data-title="Link">
                            <a href="http://codepen.io/zavoloklom/pen/IkaFL" target="_blank">Link</a>
                        </td>
                        <td data-title="Status">Completed</td>
                    </tr>
                    <tr>
                        <td data-title="ID">6</td>
                        <td data-title="Name">Material Design Buttons</td>
                        <td data-title="Link">
                            <a href="http://codepen.io/zavoloklom/pen/Gubja" target="_blank">Link</a>
                        </td>
                        <td data-title="Status">In progress</td>
                    </tr>
                    <tr>
                        <td data-title="ID">7</td>
                        <td data-title="Name">Material Design Form Elements</td>
                        <td data-title="Link">
                            <a href="http://codepen.io/zavoloklom/pen/yaozl" target="_blank">Link</a>
                        </td>
                        <td data-title="Status">In progress</td>
                    </tr>
                    <tr>
                        <td data-title="ID">8</td>
                        <td data-title="Name">Material Design Email Template</td>
                        <td data-title="Link">
                            <a href="http://codepen.io/zavoloklom/pen/qEVqzx" target="_blank">Link</a>
                        </td>
                        <td data-title="Status">In progress</td>
                    </tr>
                    </tbody>
                </table>
            </div>

        );
    }
}

export default Table