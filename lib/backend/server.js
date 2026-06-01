// dotenv configuration
require('dotenv').config();

// Import libraries
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Create express app
const app = express();

// Middleware
app.use(cors());                 // Allow cross-origin requests
app.use(express.json());        // Parse JSON request bodies

// MySQL connection pool
const dbPool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});
const db = dbPool.promise();
const JWT_SECRET = process.env.JWT_SECRET || 'your_super_secret_key_change_this';


// ==================== AUTHENTICATION ROUTES ====================
// Signup
app.post('/api/signup', async (req, res) => {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
        return res.status(422).json({ success: false, message: 'Missing required fields' });
    }
    try {
        // Check if user already exists
        const [existing] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (existing.length > 0) {
            return res.status(409).json({ success: false, message: 'Email already registered' });
        }
        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await db.query(
            'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
            [name, email, hashedPassword]
        );
        // Generate JWT token
        const token = jwt.sign({ userId: result.insertId, email }, JWT_SECRET, { expiresIn: '7d' });
        res.status(201).json({
            success: true,
            token,
            user: { id: result.insertId, name, email }
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// Login
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(422).json({ success: false, message: 'Email and password required' });
    }
    try {
        const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (rows.length === 0) {
            return res.status(401).json({ success: false, message: 'Invalid credentials' });
        }
        const user = rows[0];
        const valid = await bcrypt.compare(password, user.password);
        if (!valid) {
            return res.status(401).json({ success: false, message: 'Invalid credentials' });
        }
        const token = jwt.sign({ userId: user.user_id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
        res.json({
            success: true,
            token,
            user: { id: user.user_id, name: user.name, email: user.email }
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// ==================== MUSEUM ROUTES (CRUD) ====================
// GET all museums
app.get('/api/museums', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM museums');
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// GET single museum
app.get('/api/museums/:id', async (req, res) => {
    const museumId = req.params.id;
    try {
        const [rows] = await db.query('SELECT * FROM museums WHERE museum_id = ?', [museumId]);
        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: 'Museum not found' });
        }
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// CREATE a new museum
app.post('/api/museums', async (req, res) => {
    const { name, city, price, description, icon } = req.body;
    if (!name || !city || !price || !description || !icon) {
        return res.status(422).json({ success: false, message: 'Missing required fields' });
    }
    try {
        const [result] = await db.query(
            'INSERT INTO museums (name, city, price, description, icon) VALUES (?, ?, ?, ?, ?)',
            [name, city, price, description, icon]
        );
        const newMuseum = { museum_id: result.insertId, name, city, price, description, icon };
        res.status(201).json({ success: true, data: newMuseum });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// UPDATE a museum
app.put('/api/museums/:id', async (req, res) => {
    const museumId = req.params.id;
    const { name, city, price, description, icon } = req.body;
    try {
        const [result] = await db.query(
            'UPDATE museums SET name=?, city=?, price=?, description=?, icon=? WHERE museum_id=?',
            [name, city, price, description, icon, museumId]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Museum not found' });
        }
        res.json({ success: true, data: { museum_id: museumId, name, city, price, description, icon } });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// DELETE a museum
app.delete('/api/museums/:id', async (req, res) => {
    const museumId = req.params.id;
    try {
        const [result] = await db.query('DELETE FROM museums WHERE museum_id = ?', [museumId]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Museum not found' });
        }
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// ==================== BOOKING ROUTES (CRUD) ====================
// GET all bookings (with museum details)
app.get('/api/bookings', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT b.*, m.name as museum_name, m.city, m.price as museum_price
            FROM bookings b
            JOIN museums m ON b.museum_id = m.museum_id
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// GET single booking
app.get('/api/bookings/:id', async (req, res) => {
    const bookingId = req.params.id;
    try {
        const [rows] = await db.query(`
            SELECT b.*, m.name as museum_name, m.city, m.price as museum_price
            FROM bookings b
            JOIN museums m ON b.museum_id = m.museum_id
            WHERE b.booking_id = ?
        `, [bookingId]);
        if (rows.length === 0) return res.status(404).json({ success: false, message: 'Booking not found' });
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// CREATE a booking
app.post('/api/bookings', async (req, res) => {
    const { museum_id, quantity, total_price, status } = req.body;
    if (!museum_id || !total_price) {
        return res.status(422).json({ success: false, message: 'museum_id and total_price required' });
    }
    try {
        const [result] = await db.query(
            'INSERT INTO bookings (museum_id, quantity, total_price, status) VALUES (?, ?, ?, ?)',
            [museum_id, quantity || 1, total_price, status || 'pending']
        );
        const newBooking = {
            booking_id: result.insertId,
            museum_id,
            quantity: quantity || 1,
            total_price,
            status: status || 'pending'
        };
        res.status(201).json({ success: true, data: newBooking });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// UPDATE booking status
app.put('/api/bookings/:id', async (req, res) => {
    const bookingId = req.params.id;
    const { status } = req.body;
    if (!status) return res.status(422).json({ success: false, message: 'Status required' });
    try {
        const [result] = await db.query('UPDATE bookings SET status = ? WHERE booking_id = ?', [status, bookingId]);
        if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Booking not found' });
        res.json({ success: true, data: { booking_id: bookingId, status } });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// DELETE a booking
app.delete('/api/bookings/:id', async (req, res) => {
    const bookingId = req.params.id;
    try {
        const [result] = await db.query('DELETE FROM bookings WHERE booking_id = ?', [bookingId]);
        if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Booking not found' });
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// ==================== START SERVER ====================
const PORT = process.env.API_PORT || 3001;
app.listen(PORT, () => {
    console.log(`✅ MuseumPass API running at http://localhost:${PORT}`);
});
