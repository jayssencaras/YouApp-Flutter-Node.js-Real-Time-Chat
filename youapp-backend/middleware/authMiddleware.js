const jwt = require('jsonwebtoken');
const JWT_SECRET = 'your_jwt_secret';

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.status(401).json({ auth: false, message: 'No token provided.' });

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ auth: false, message: 'Failed to authenticate token.' });
    req.user = decoded;
    req.id = decoded.id;
    next();
  });
}

module.exports = authenticateToken;
