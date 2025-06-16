const express = require('express');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const authenticateToken = require('../middleware/authMiddleware');

// JWT secret
const JWT_SECRET = 'your_jwt_secret';

// Authentication Middleware
// function authenticateToken(req, res, next) {
//   const authHeader = req.headers['authorization'];
//   const token = authHeader && authHeader.split(' ')[1];
//   if (!token) {
//     return res.status(401).json({ auth: false, message: 'No token provided.' });
//   }
//   jwt.verify(token, JWT_SECRET, (err, decoded) => {
//     if (err) {
//       return res.status(401).json({ auth: false, message: 'Failed to authenticate token.' });
//     }
//     req.user = decoded;
//     next();
//   });
// }

// Login Route
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ auth: false, message: 'Invalid credentials' });
    const isValid = bcrypt.compareSync(password, user.passwordHash);
    if (!isValid) return res.status(401).json({ auth: false, message: 'Invalid credentials' });
    const token = jwt.sign({ email, username: user.username }, JWT_SECRET, { expiresIn: '1h' });
    res.json({ auth: true, access_token: token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error.' });
  }
});

// Registration Route
router.post('/register', async (req, res) => {
  const { email, username, password } = req.body;
  try {
    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ message: 'User already exists.' });
    const passwordHash = bcrypt.hashSync(password, 8);
    const newUser = new User({ email, username, passwordHash });
    await newUser.save();
    res.status(201).json({ message: 'User registered successfully!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error.' });
  }
});

// Profile Route
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ email: req.user.email });
    if (!user) return res.status(404).json({ message: 'User not found.' });
    res.json({ email: user.email, username: user.username });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error.' });
  }
});
router.get('/all', authenticateToken, async (req, res) => {
  try {
    const users = await User.find({}, '_id username email');
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

module.exports = router;
