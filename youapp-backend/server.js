const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');
const router = express.Router();
const User = require('./models/User');
const authenticateToken = require('./middleware/authMiddleware');



const app = express();
const PORT = 5000;
const JWT_SECRET = 'your_jwt_secret';

// 🌟 Zodiac/Horoscope calculation
function calculateZodiac(month, day) {
  const zodiacSigns = [
    { sign: 'Capricorn', start: [12, 22], end: [1, 19] },
    { sign: 'Aquarius', start: [1, 20], end: [2, 18] },
    { sign: 'Pisces', start: [2, 19], end: [3, 20] },
    { sign: 'Aries', start: [3, 21], end: [4, 19] },
    { sign: 'Taurus', start: [4, 20], end: [5, 20] },
    { sign: 'Gemini', start: [5, 21], end: [6, 20] },
    { sign: 'Cancer', start: [6, 21], end: [7, 22] },
    { sign: 'Leo', start: [7, 23], end: [8, 22] },
    { sign: 'Virgo', start: [8, 23], end: [9, 22] },
    { sign: 'Libra', start: [9, 23], end: [10, 22] },
    { sign: 'Scorpio', start: [10, 23], end: [11, 21] },
    { sign: 'Sagittarius', start: [11, 22], end: [12, 21] }
  ];

  for (const zodiac of zodiacSigns) {
    const [startMonth, startDay] = zodiac.start;
    const [endMonth, endDay] = zodiac.end;
    if (
      (month === startMonth && day >= startDay) ||
      (month === endMonth && day <= endDay)
    ) {
      return zodiac.sign;
    }
  }
  return 'Unknown';
}

function getDailyHoroscope() {
  return 'Today is a good day to focus on yourself.';
}

// 📦 Middleware
app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static('uploads'));

// Multer Configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueName = Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname);
    cb(null, uniqueName);
  }
});
const upload = multer({ storage });

// 🗂️ Logger
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// 🔌 MongoDB Connection
mongoose.connect('mongodb://localhost:27017/youappdb')
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// 🟣 API Health Check
app.get('/', (req, res) => {
  res.send('API is running!');
});

// 🟢 Login
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ auth: false, message: 'Invalid credentials' });
    }

    const passwordIsValid = bcrypt.compareSync(password, user.passwordHash);
    if (!passwordIsValid) {
      return res.status(401).json({ auth: false, message: 'Invalid credentials' });
    }

    const token = jwt.sign(
  { id: user._id, email: user.email, username: user.username },
  JWT_SECRET,
  { expiresIn: '1h' }
);


    res.json({ auth: true, access_token: token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error.' });
  }
});

// 🟢 Registration
app.post('/api/register', async (req, res) => {
  const { email, username, password } = req.body;
  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists.' });
    }

    const passwordHash = bcrypt.hashSync(password, 8);
    const newUser = new User({ email, username, passwordHash });
    await newUser.save();

    res.status(201).json({ message: 'User registered successfully!' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error.' });
  }
});

// 🟡 Auth Middleware
// function authenticateToken(req, res, next) {
//   const authHeader = req.headers['authorization'];
//   if (!authHeader) {
//     return res.status(401).json({ auth: false, message: 'No token provided.' });
//   }
//   const token = authHeader.split(' ')[1];
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

// 🔵 Profile GET
app.get('/api/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ email: req.user.email });
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.json({
      email: user.email,
      username: user.username,
      displayName: user.displayName || '',
      gender: user.gender || '',
      birthday: user.birthday || '',
      horoscope: user.horoscope || '',
      zodiac: user.zodiac || '',
      height: user.height || '',
      weight: user.weight || '',
      avatar: user.avatar ? `/uploads/${user.avatar}` : ''
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error.' });
  }
});

// 🔵 Profile PUT
app.put('/api/profile', authenticateToken, async (req, res) => {
  try {
    const updatedFields = req.body;
    if (updatedFields.birthday) {
      const [day, month, year] = updatedFields.birthday.split('/').map(Number);
      updatedFields.zodiac = calculateZodiac(month, day);
      updatedFields.horoscope = getDailyHoroscope();
    }

    const user = await User.findOneAndUpdate(
      { email: req.user.email },
      { $set: updatedFields },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.json({ message: 'Profile updated successfully!', user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error.' });
  }
});

// 🔵 Avatar Upload
app.post('/api/profile/avatar', authenticateToken, upload.single('avatar'), async (req, res) => {
  try {
    const user = await User.findOne({ email: req.user.email });
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    user.avatar = req.file.filename;
    await user.save();

    res.json({ message: 'Avatar uploaded successfully!', avatar: `/uploads/${user.avatar}` });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error.' });
  }
});

const messageRoutes = require('./routes/messageRoutes');
app.use('/api/messages', messageRoutes);

const userRoutes = require('./models/userRoutes');
app.use('/api/users', userRoutes);

// 🚀 Start Server



const http = require('http');
const { Server } = require('socket.io');

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
  }
});

// Store connected users
const onlineUsers = new Map();

io.on('connection', (socket) => {
  console.log('🟢 New client connected:', socket.id);

  socket.on('register', (userId) => {
    onlineUsers.set(userId, socket.id);
    console.log(`✅ Registered user ${userId} with socket ${socket.id}`);
  });

  socket.on('sendMessage', (messageData) => {
    console.log('📤 sendMessage called', messageData);

    const recipientSocketId = onlineUsers.get(messageData.recipientId);
    const senderSocketId = onlineUsers.get(messageData.senderId);

    if (recipientSocketId) {
      io.to(recipientSocketId).emit('newMessage', messageData);
      console.log(`✅ Sent to recipient ${messageData.recipientId}`);
    }

    if (senderSocketId && senderSocketId !== recipientSocketId) {
      io.to(senderSocketId).emit('newMessage', messageData);
      console.log(`✅ Sent to sender ${messageData.senderId}`);
    }
  });

  socket.on('disconnect', () => {
    console.log('🔴 Client disconnected:', socket.id);
    for (let [userId, sockId] of onlineUsers.entries()) {
      if (sockId === socket.id) {
        onlineUsers.delete(userId);
        console.log(`🧹 Removed user ${userId} from onlineUsers`);
        break;
      }
    }
  });
});


server.listen(PORT, () => {
  console.log(`✅ Backend server running with WebSocket at http://localhost:${PORT}`);
});




