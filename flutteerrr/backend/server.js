// backend/server.js
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const MONGO_URI = 'mongodb+srv://kushagradhingra:BAK7fISZJBBg5wkY@cluster.yrtp0.mongodb.net/?retryWrites=true&w=majority&appName=Cluster';
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

// API Routes
app.get('/api/journal-entries', async (req, res) => {
  try {
    const entries = await db.collection('journal_entries').find().toArray();
    res.json(entries);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/journal-entries/:date', async (req, res) => {
  try {
    const startOfDay = new Date(req.params.date);
    const endOfDay = new Date(startOfDay);
    endOfDay.setDate(endOfDay.getDate() + 1);
    
    const entries = await db.collection('journal_entries')
      .find({
        date: {
          $gte: startOfDay.toISOString(),
          $lt: endOfDay.toISOString()
        }
      })
      .toArray();
    res.json(entries);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/journal-entries', async (req, res) => {
  try {
    const result = await db.collection('journal_entries').insertOne(req.body);
    res.json({ id: result.insertedId });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/journal-entries/:id', async (req, res) => {
  try {
    await db.collection('journal_entries').updateOne(
      { _id: new ObjectId(req.params.id) },
      { $set: req.body }
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/journal-entries/:id', async (req, res) => {
  try {
    await db.collection('journal_entries').deleteOne(
      { _id: new ObjectId(req.params.id) }
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/questions', async (req, res) => {
  try {
    const questions = await db.collection('questions').find().toArray();
    res.json(questions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});