const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// Remove Authorization header for login requests
app.use('/api/login', (req, res, next) => {
  delete req.headers['authorization'];
  next();
});

app.use('/api', createProxyMiddleware({
  target: 'https://techtest.youapp.ai',
  changeOrigin: true,
  pathRewrite: { '^/api': '/api' },
}));

app.listen(PORT, () => {
  console.log(`Proxy server running at http://localhost:${PORT}`);
});
