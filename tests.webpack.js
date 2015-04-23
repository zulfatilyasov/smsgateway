var context = require.context('./client/app', true, /_test.*$/);
context.keys().forEach(context);