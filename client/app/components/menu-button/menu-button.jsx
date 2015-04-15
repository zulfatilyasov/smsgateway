import React from 'react'
import mui, {FloatingActionButton, SvgIcon} from 'material-ui';
import styles from './menu-button.styl'

class MenuButton extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            top: 136,
            left: 155
        }
    }
    _getLeftPosition(){
        var content = document.getElementsByClassName("mui-app-content-canvas");
        if (!content.length) {
            return;
        }
        var contentEl = content[0];
        var pos = contentEl.getBoundingClientRect();

        if (!pos) {
            return
        }
        return pos.left / 2;
    }

    handleResize(e) {
        this.setState({left: this._getLeftPosition()});
    }

    componentDidMount() {
        this.setState({left: this._getLeftPosition()});
        window.addEventListener('resize', this.handleResize.bind(this));
    }

    componentWillUnmount() {
        window.removeEventListener('resize', this.handleResize.bind(this));
    }


    render() {
        var style = {top: this.state.top, left: this.state.left};
        var fill = '#727272';

        return (
            <div style={style} className="menu-button">
                <FloatingActionButton iconClassName="" onClick={this.props.onMenuButtonClick}>
                    <SvgIcon>
                        <path fill={fill} d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"/>
                    </SvgIcon>
                </FloatingActionButton>
            </div>
        );
    }
}

export default MenuButton