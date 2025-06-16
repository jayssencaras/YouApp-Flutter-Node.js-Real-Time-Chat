const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true
  },
  username: {
    type: String,
    required: true
  },
  passwordHash: {
    type: String,
    required: true
  },
  bio: {
    type: String,
    default: ''
  },
  displayName: {
    type: String,
    default: ''
  },
  gender: {
    type: String,
    default: ''
  },
  birthday: {
    type: String,
    default: ''
  },
  horoscope: {
    type: String,
    default: ''
  },
  zodiac: {
    type: String,
    default: ''
  },
  height: {
    type: String,
    default: ''
  },
  weight: {
    type: String,
    default: ''
  }
});

module.exports = mongoose.model('User', UserSchema);
