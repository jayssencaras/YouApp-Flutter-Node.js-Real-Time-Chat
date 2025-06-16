const express = require('express');
const router = express.Router();
const Message = require('../models/Message');
const User = require('../models/User');
const authenticateToken = require('../middleware/authMiddleware');
const mongoose = require('mongoose');

// ✅ Send a message
router.post('/send', authenticateToken, async (req, res) => {
  try {
    const { recipientId, content } = req.body;
    const senderId = new mongoose.Types.ObjectId(req.user.id); // ✅ cast to ObjectId

    if (!recipientId || !content) {
      return res.status(400).json({ message: 'All fields are required.' });
    }

    const message = new Message({
      sender: senderId,
      recipient: new mongoose.Types.ObjectId(recipientId), // ✅ cast to ObjectId
      content
    });

    await message.save();

    res.status(201).json({ message: 'Message sent successfully.', data: message });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});


// ✅ Get conversation between current user and another user
router.get('/conversation/:userId', authenticateToken, async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const otherUserId = req.params.userId;

    const messages = await Message.find({
      $or: [
        { sender: currentUserId, recipient: otherUserId },
        { sender: otherUserId, recipient: currentUserId },
      ],
    })
      .sort({ timestamp: 1 })
      .populate('sender', 'username')
      .populate('recipient', 'username');

    res.json(messages);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

module.exports = router;
