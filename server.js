const http = require('http');
const { createProxy } = require('proxy');

const server = createProxy(http.createServer());
const port = process.env.PORT || 8080;

server.listen(port, () => {
  console.log(`NPM-based proxy server listening on port ${port}`);
});

server.on('error', (err) => {
  console.error('Proxy server error:', err);
});