import request from 'superagent-promise'

class ApiClient {
    constructor(host = '', baseUrl = '') {
        this.accessToken = '';
        this.prefix = host + baseUrl;
        this._pendingRequests = {};
    }

    setToken(token) {
        this.accessToken = token;
    }

    _abortRequest(key) {
        if (this._pendingRequests[key]) {
            this._pendingRequests[key]._callback = ()=> {
            };
            this._pendingRequests[key].abort();
            this._pendingRequests[key] = null;
        }
    }


    login(email, password) {
        return request
            .post(this.prefix + '/users/login')
            .send({email: email, password: password})
            .end();
    }

    sendMessage(message){
        console.log(this.accessToken);
        return request
            .post(this.prefix + '/messages')
            .send(message)
            .set('Authorization', this.accessToken)
            .end();
    }

}

var devHost = 'http://192.168.0.2:3000';
export default new ApiClient('', '/api');