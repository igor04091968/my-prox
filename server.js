const http = require('http');
const httpProxy = require('http-proxy');
const net = require('net');
const url = require('url');

const proxy = httpProxy.createProxyServer({});

const server = http.createServer((req, res) => {
  console.log('Proxying HTTP request for: ' + req.url);
  // The target for a forward proxy is the requested URL itself.
  proxy.web(req, res, { target: req.url, changeOrigin: true });
});

// Listen for the 'connect' event for HTTPS requests
server.on('connect', (req, clientSocket, head) => {
  // The requested URL is in the form 'hostname:port'
  const { port, hostname } = url.parse(`http://${req.url}`);
  
  if (hostname && port) {
    console.log('Proxying HTTPS connection to:', hostname, port);
    const serverSocket = net.connect(port, hostname, () => {
      clientSocket.write('HTTP/1.1 200 Connection Established\r\n' +
                         'Proxy-agent: Node.js-Proxy\r\n' +
                         '\r\n');
      serverSocket.write(head);
      serverSocket.pipe(clientSocket);
      clientSocket.pipe(serverSocket);
    });

    serverSocket.on('error', (e) => {
      console.error('Server socket error:', e);
      clientSocket.end('HTTP/1.1 500 Internal Server Error\r\n\r\n');
    });
    
    clientSocket.on('error', (e) => {
        console.error('Client socket error:', e);
        serverSocket.end();
    });

  } else {
    clientSocket.end('HTTP/1.1 400 Bad Request\r\n\r\n');
  }
});

proxy.on('error', (err, req, res) => {
  console.error('Proxy master error:', err);
  // res might be undefined if the error happens during a CONNECT request.
  if (res && !res.headersSent) {
    res.writeHead(502, { 'Content-Type': 'text/plain' });
  }
  if (res) {
    res.end('Proxy Error.');
  }
});

const port = process.env.PORT || 8082;
server.listen(port, () => {
  console.log(`HTTP/HTTPS Forward Proxy server listening on port ${port}`);
});
