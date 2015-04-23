var React = require('react');
var TestUtils = require('react/lib/ReactTestUtils');
var Login = require('./login.cjsx');

describe('Login', function() {
    var login;
    var primaryButton;
    var email;
    var emailInput;
    var password;
    var passwordInput;

    beforeAll(function() {
        login = TestUtils.renderIntoDocument( < Login / > );
        primaryButton = TestUtils.findRenderedDOMComponentWithClass(login, 'loginButton');
        email = TestUtils.findRenderedDOMComponentWithClass(login, 'email-input');
        emailInput = TestUtils.findRenderedDOMComponentWithTag(email, 'input');
        password = TestUtils.findRenderedDOMComponentWithClass(login, 'password-input');
        passwordInput = TestUtils.findRenderedDOMComponentWithTag(password, 'input');
    });

    it('have correct header', function() {
        var header = TestUtils.findRenderedDOMComponentWithClass(login, 'login-header');
        expect(header.getDOMNode().textContent).toEqual('SMS Gateway');
    });

    it('requires an email', function() {
        TestUtils.Simulate.blur(emailInput);
        var error = TestUtils.findRenderedDOMComponentWithClass(email, 'mui-text-field-error');
        expect(error.getDOMNode().textContent).toBe('email is required');
    });

    it('should show error on invalid email', function() {
        var invalidEmail = 'invalidEmail';
        TestUtils.Simulate.change(emailInput, {
            target: {
                value: invalidEmail
            }
        });
        TestUtils.Simulate.blur(emailInput);
        expect(login.email).toBe(invalidEmail);
        var error = TestUtils.findRenderedDOMComponentWithClass(email, 'mui-text-field-error');
        expect(error.getDOMNode().textContent).toBe('email is not valid');
    });

    it('should not show error if Email is Valid', function() {
        var validEmail = 'mail@zulfat.net';
        TestUtils.Simulate.change(emailInput, {
            target: {
                value: validEmail
            }
        });
        expect(login.email).toBe(validEmail);
        TestUtils.Simulate.blur(emailInput);
        var error = TestUtils.scryRenderedDOMComponentsWithClass(email, 'mui-text-field-error');
        expect(error.length).toBe(0);
        debugger
    });

    it('requires a password', function() {
        TestUtils.Simulate.blur(passwordInput);
        var error = TestUtils.findRenderedDOMComponentWithClass(password, 'mui-text-field-error');
        expect(error.getDOMNode().textContent).toBe('password is required');
    });

    it('sets password', function() {
        var password = '518009';
        TestUtils.Simulate.change(passwordInput, {
            target: {
                value: password
            }
        });
        expect(login.password).toBe(password);

        var button = TestUtils.findRenderedDOMComponentWithTag(primaryButton, 'button');
        expect(button.getDOMNode().disabled).toBe(false);
        TestUtils.Simulate.click(primaryButton);
    });
});
