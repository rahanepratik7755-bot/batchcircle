const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const helmet = require('helmet');
const multer = require('multer');
const path = require('path');
require('dotenv').config();

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use(express.static(path.join(__dirname, 'public')));

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:password@localhost:5432/batchcircle_db'
});

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, `id_${Date.now()}${path.extname(file.originalname)}`)
});
const upload = multer({ storage });

// Google Login
app.post('/api/auth/google', async (req, res) => {
  const { email, name, google_id } = req.body;
  try {
    let user = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (user.rows.length === 0) {
      const newUser = await pool.query(
        'INSERT INTO users (name, email, google_id) VALUES ($1, $2, $3) RETURNING *',
        [name, email, google_id]
      );
      return res.status(201).json({ user: newUser.rows[0], isNewUser: true });
    }
    return res.status(200).json({ user: user.rows[0], isNewUser: false });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update Profile
app.post('/api/user/update-profile', async (req, res) => {
  const { userId, college_name, course_name, academic_year } = req.body;
  try {
    let college = await pool.query('SELECT id FROM colleges WHERE name = $1', [college_name]);
    let collegeId = college.rows.length ? college.rows[0].id : null;

    if (!collegeId) {
      const newCollege = await pool.query('INSERT INTO colleges (name) VALUES ($1) RETURNING id', [college_name]);
      collegeId = newCollege.rows[0].id;
    }

    const updated = await pool.query(
      'UPDATE users SET college_id = $1, course_name = $2, academic_year = $3 WHERE id = $4 RETURNING *',
      [collegeId, course_name, academic_year, userId]
    );
    res.status(200).json({ user: updated.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ID Verification Upload
app.post('/api/user/verify-id', upload.single('id_card_image'), async (req, res) => {
  const { userId } = req.body;
  const idCardUrl = req.file ? `/uploads/${req.file.filename}` : null;
  try {
    const result = await pool.query(
      'UPDATE users SET id_card_url = $1, verification_status = $2 WHERE id = $3 RETURNING *',
      [idCardUrl, 'pending', userId]
    );
    res.status(200).json({ success: true, user: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Campus AI Endpoint
app.post('/api/campus-ai/chat', (req, res) => {
  const { question, courseName } = req.body;
  const reply = `[Campus AI (${courseName})]: '${question}' या प्रश्नाचे उत्तर तयार आहे.`;
  res.status(200).json({ reply });
});

// Subscription Verify
app.post('/api/subscriptions/verify', async (req, res) => {
  const { userId, platform, productId, transactionId, purchaseToken } = req.body;
  try {
    const days = productId.includes('yearly') ? 365 : 30;
    const expiry = new Date();
    expiry.setDate(expiry.getDate() + days);

    await pool.query(
      `INSERT INTO subscriptions (user_id, platform, plan_type, transaction_id, purchase_token, is_active, expiry_date)
       VALUES ($1, $2, $3, $4, $5, TRUE, $6)
       ON CONFLICT (transaction_id) DO UPDATE SET is_active = TRUE, expiry_date = $6`,
      [userId, platform, productId.includes('yearly') ? 'yearly' : 'monthly', transactionId, purchaseToken, expiry]
    );

    await pool.query('UPDATE users SET is_premium = TRUE, premium_expiry = $1 WHERE id = $2', [expiry, userId]);
    res.status(200).json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Admin APIs
app.get('/api/admin/pending-verifications', async (req, res) => {
  const result = await pool.query(
    `SELECT u.id, u.name, u.email, u.course_name, u.academic_year, u.id_card_url, c.name AS college_name 
     FROM users u LEFT JOIN colleges c ON u.college_id = c.id 
     WHERE u.verification_status = 'pending' AND u.id_card_url IS NOT NULL`
  );
  res.status(200).json(result.rows);
});

app.post('/api/admin/verify-user', async (req, res) => {
  const { userId, status } = req.body;
  await pool.query('UPDATE users SET verification_status = $1 WHERE id = $2', [status, userId]);
  res.status(200).json({ success: true });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server listening on port ${PORT}`));
                                    
