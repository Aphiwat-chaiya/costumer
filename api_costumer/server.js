const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors'); // เพิ่มการ import CORS

const app = express();

// ตั้งค่า CORS
app.use(cors()); // เปิดใช้งาน CORS

app.use(bodyParser.json());

// เชื่อมต่อกับฐานข้อมูล MySQL
const db = mysql.createConnection({
  host: '127.0.0.1',
  user: 'root', // ใส่ username ของ MySQL Workbench
  password: '', // ใส่รหัสผ่านของ MySQL Workbench
  database: 'gas_station_loyalty'
});

db.connect((err) => {
  if (err) {
    console.error('ไม่สามารถเชื่อมต่อฐานข้อมูล:', err);
    return;
  }
  console.log('เชื่อมต่อฐานข้อมูลสำเร็จ');
});



// API สำหรับการ login ลูกค้า
app.post('/login/customer', (req, res) => {
  const { customer_id, phone_number } = req.body;

  const query = `SELECT * FROM customers WHERE customer_id = ? AND phone_number = ?`;
  db.query(query, [customer_id, phone_number], (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      return res.status(500).json({ message: 'มีข้อผิดพลาดในการเชื่อมต่อฐานข้อมูล' });
    }

    if (results.length > 0) {
      console.log('Login successful:', results[0]);
      res.json({ message: 'ล็อกอินสำเร็จ', customer: results[0] });
    } else {
      console.log('Invalid login credentials');
      res.status(401).json({ message: 'ข้อมูลล็อกอินไม่ถูกต้อง' });
    }
  });
});


// API สำหรับดึงข้อมูลลูกค้าตาม customer_id
app.get('/customer/:customer_id', (req, res) => {
  const { customer_id } = req.params;

  const query = `SELECT * FROM customers WHERE customer_id = ?`;
  db.query(query, [customer_id], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'มีข้อผิดพลาดในการเชื่อมต่อฐานข้อมูล' });
    }
    
    if (results.length > 0) {
      res.json({ customer: results[0] });
    } else {
      res.status(404).json({ message: 'ไม่พบข้อมูลลูกค้า' });
    }
  });
});


////////////////
app.get('/transactions/:customer_id', (req, res) => {
  const customerId = req.params.customer_id;

  const query = `
    SELECT t.transaction_id, t.transaction_date, t.amount, f.fuel_type_name
    FROM transactions t
    JOIN fuel_types f ON t.fuel_type_id = f.fuel_type_id
    WHERE t.customer_id = ?
    ORDER BY t.transaction_date DESC
  `;

  db.query(query, [customerId], (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      return res.status(500).json({ message: 'Database query error' });
    }

    res.json(results);
  });
});


// API สำหรับดึงข้อมูลรางวัล
app.get('/rewards', (req, res) => {
  const query = `SELECT * FROM rewards`;
  db.query(query, (err, results) => {
      if (err) {
          return res.status(500).json({ message: 'มีข้อผิดพลาดในการเชื่อมต่อฐานข้อมูล' });
      }
      res.json(results);
  });
});

// Redeem reward
app.post('/api/redeem', (req, res) => {
  const { customer_id, reward_id, points_used } = req.body;

  // ตรวจสอบคะแนนของลูกค้า
  const checkPoints = `SELECT points_balance FROM customers WHERE customer_id = ?`;
  db.query(checkPoints, [customer_id], (err, results) => {
    if (err || results.length === 0) {
      return res.status(500).json({ message: 'มีข้อผิดพลาดในการตรวจสอบคะแนน' });
    }

    const pointsBalance = results[0].points_balance;
    if (pointsBalance < points_used) {
      return res.status(400).json({ message: 'คะแนนไม่เพียงพอ' });
    }

    // อัปเดตคะแนนของลูกค้า
    const updateCustomerPoints = `UPDATE customers SET points_balance = points_balance - ? WHERE customer_id = ?`;
    db.query(updateCustomerPoints, [points_used, customer_id], (err) => {
      if (err) {
        return res.status(500).json({ message: 'ไม่สามารถอัพเดตคะแนนได้' });
      }

      const insertRedemption = `INSERT INTO redemptions (customer_id, reward_id, redemption_date, points_used, status) VALUES (?, ?, NOW(), ?, 'pending')`;
      db.query(insertRedemption, [customer_id, reward_id, points_used], (err) => {
        if (err) {
          return res.status(500).json({ message: 'ไม่สามารถบันทึกการแลกของรางวัลได้' });
        }
        res.status(200).json({ message: 'แลกของรางวัลสำเร็จ' });
      });
    });
  });
});

///////////////

// เริ่มเซิร์ฟเวอร์
app.listen(3000, () => {
  console.log('เซิร์ฟเวอร์ทำงานที่ http://localhost:3000');
});