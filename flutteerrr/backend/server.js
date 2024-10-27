// backend/server.js
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const MONGO_URI = 'mongodb+srv://kushagradhingra:hello@cluster.yrtp0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster';
const PORT = process.env.PORT || 3000;

let db;

// Connect to MongoDB
async function connectDB() {
  try {
    const client = await MongoClient.connect(MONGO_URI);
    db = client.db();
    console.log('Connected to MongoDB');
  } catch (err) {
    console.error('Failed to connect to MongoDB:', err);
  }
}

connectDB();

// User Schema
const UserSchema = require("./user_model.js")

// Signup Route
app.post('/api/signup', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    console.log(req.body);
    // Check if the user already exists
    const existingUser = await db.collection('users').findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash the password

    // Create a new user
    const newUser = { name, email, password };
    const result = await db.collection('users').insertOne(newUser);
    
    res.status(200).json({ userId: result.insertedId.toString() });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login Route
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log(req.body);
    // Find user by email
    const user = await db.collection('users').findOne({ email });
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Validate password
    const isValidPassword = (password==user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    res.status(200).json({ userId: user._id.toString() });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Journal Entry Routes
app.post('/api/journal-entries/:userId', async (req, res) => {
  try {
    const userId = req.params.userId; // Get userId from request parameters
    const journalEntry = { ...req.body, userId }; // Add userId to the entry

    const result = await db.collection('journal_entries').insertOne(journalEntry);
    res.status(200).json({ id: result.insertedId.toString() });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/journal-entries/:userId', async (req, res) => {
  try {
    const userId = req.params.userId; // Get userId from request parameters
    const entries = await db.collection('journal_entries').find({ userId }).toArray();
    res.json(entries);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/journal-entries/date/:userId', async (req, res) => {
  try {
    const userId = req.params.userId; // Get userId from request parameters
    const inputDate = new Date(req.body["dateVal"]);

    const startOfDay = new Date(inputDate.getUTCFullYear(), inputDate.getUTCMonth(), inputDate.getUTCDate(), 0, 0, 0, 0);
    const endOfDay = new Date(inputDate.getUTCFullYear(), inputDate.getUTCMonth(), inputDate.getUTCDate(), 23, 59, 59, 999);

    const entries = await db.collection('journal_entries')
      .find({
        date: {
          $gte: startOfDay,
          $lte: endOfDay
        },
        userId // Filter by userId
      })
      .toArray();
    res.json(entries);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/journal-entries/:id/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    await db.collection('journal_entries').updateOne(
      { _id: new ObjectId(req.params.id), userId }, // Ensure the entry belongs to the user
      { $set: req.body }
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/journal-entries/:id/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    await db.collection('journal_entries').deleteOne(
      { _id: new ObjectId(req.params.id), userId } // Ensure the entry belongs to the user
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Questions Routes
app.get('/api/questions/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const questions = await db.collection('questions').find({ userId }).toArray(); // Filter questions by userId
    res.json(questions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
