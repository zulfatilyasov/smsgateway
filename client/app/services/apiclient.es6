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

}

export default new ApiClient('http://localhost:4000', '/api');