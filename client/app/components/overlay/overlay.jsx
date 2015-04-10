import React from 'react';
import styles from './overlay.styl'

class Overlay extends React.Component {
  render() {
    return (
        <div className="overlay">
            {this.props.children}
        </div>
    );
  }
}

export default Overlay;