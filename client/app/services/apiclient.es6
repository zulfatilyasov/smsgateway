import request from 'superagent-promise'

class ApiClient {
    constructor(host = '', baseUrl = '') {
        this.accessToken = '';
        this.prefix = host + baseUrl;
        this._pendingRequests = {};
    }

    _getToken(){
        return localStorage.getItem('sg-token');
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

    register(registrationData) {
        return request
            .post(this.prefix + '/users')
            .send(registrationData)
            .end();
    }

    sendMessage(message){
        console.log(this.accessToken);
        return request
            .post(this.prefix + '/messages')
            .send(message)
            .set('Authorization', this._getToken())
            .end();
    }
}

var devHost = 'http://192.168.0.2:3200';
export default new ApiClient('', '/api');