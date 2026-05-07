const fs = require('fs');
const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'root',
    database: process.env.DB_NAME || 'my_party_4',
    waitForConnections: process.env.DB_WAIT_FOR_CONNECTIONS || true,
    connectTimeout: process.env.DB_CONNECT_TIMEOUT || 30000,
    connectionLimit: process.env.DB_CONNECTION_LIMIT || 10,
    queueLimit: process.env.DB_QUEUE_LIMIT || 0,
    ...(process.env.DB_SSL_CA? {
                ssl: {ca: fs.readFileSync(process.env.DB_SSL_CA || '/home/zyad/Desktop/all devlopment projects/flutter/my_party/backend/ca.pem')}
            }: {})
});

// if(['localhost', '0.0.0.0'].includes(process.env.DB_HOST)){
    
// pool.on('connection', (connection) => {
//     console.log('Database connection established');
//     pool.query('SET GLOBAL event_scheduler="ON"');
// });
// }
// pool.on('error', (err) => {
//     console.log('Database connection error', err);
// });
module.exports = pool;
