// models/user.js
const { Schema } = require("mongoose");

const UserSchema = new Schema({
  id: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: false },
});

module.exports = UserSchema;
