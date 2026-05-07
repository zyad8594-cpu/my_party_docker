// backend/config/server.js
const { Server } = require('socket.io');
const { sendPushNotification } = require('./firebase');
const pool = require('./db');

let io;

/**
 * تهيئة كائن Socket.io وربطه بخادم HTTP
 * @param {http.Server} server - خادم HTTP الخاص بـ Express
 */
function initSocket(server) {
    io = new Server(server, {
        cors: {
            origin: "*", // يمكنك تحديد النطاقات المسموح بها هنا لاحقاً
            methods: ["GET", "POST"]
        }
    });

    io.on('connection', (socket) => {
        

        socket.on('join-room', (userId) => {
            let userData = {id: socket.id,};
            if (userId) {
                socket.join(`user_${userId}`);
                userData[`👤 User ${userId} joined room`] = `user_${userId}`;
            }
            console.log('📱 جهاز جديد متصل عبر WebSocket.:', userData);
        });

        socket.on('disconnect', () => {
            console.log('📱 انقطع اتصال الجهاز:', socket.id);
        });
    });

    return io;
}

/**
 * إرسال إشعار لمستخدم معين عبر غرفته الخاصة
 * @param {Object} notificationData - بيانات الإشعار القادمة من قاعدة البيانات
 */
async function sendNotificationToClients(notificationData) {
    if (io && notificationData.user_id) {
        console.log(`📤 إرسال إشعار للمستخدم ${notificationData.user_id}: ${notificationData.title}`);
        io.to(`user_${notificationData.user_id}`).emit('new-notification', notificationData);
    }

    // إرسال عبر FCM (Push Notification)
    if (notificationData.user_id) {
        try {
            const [tokens] = await pool.execute(
                'SELECT token FROM User_FCM_Tokens WHERE user_id = ?',
                [notificationData.user_id]
            );

            if (tokens.length > 0) {
                const tokenList = tokens.map(t => t.token);
                await sendPushNotification(tokenList, {
                    title: notificationData.title,
                    message: notificationData.message,
                    data: {
                        notification_id: String(notificationData.notification_id),
                        type: notificationData.type
                    }
                });
            }
        } catch (err) {
            console.error('❌ Error sending FCM:', err);
        }
    }
}

module.exports = {
    initSocket,
    sendNotificationToClients
};