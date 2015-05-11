require('coffee-script/register');
exports.config = {
  seleniumAddress: 'http://localhost:4444/wd/hub',
  specs: [
    'client/app/components/login/login-specs.coffee',
    'client/app/**/*specs.coffee'
  ]
};