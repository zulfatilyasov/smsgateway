import React from 'react';
import styles from './spinner.styl'

class Spinner extends React.Component {
    constructor(props){
        super(props)
    }
    render() {
        var visibility = this.props.show ? '' : 'hide';
        console.log(visibility);
        return (
            <svg className={'spinner ' + visibility} width={this.props.width} height={this.props.height} viewBox="0 0 66 66" xmlns="http://www.w3.org/2000/svg">
                <circle className="path" fill="none" strokeWidth="3" strokeLinecap="round" cx="33" cy="33" r="30"></circle>
            </svg>
        );
    }
}

export default Spinner