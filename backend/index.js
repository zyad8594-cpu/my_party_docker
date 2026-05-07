const express = require('express');
const http = require('http');
const cors = require('cors');
const path = require('path');
require('dotenv').config();
const ApiResponse = require('./utils/apiResponse');

const { initSocket, sendNotificationToClients } = require('./config/server');
const { initRealtimeNotifier } = require('./config/realtimeNotifier');

const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 3000;
const HOST =  process.env.HOST=='localhost' ? '0.0.0.0' : (process.env.HOST || '0.0.0.0');

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Use Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/events', require('./routes/events'));
app.use('/api/tasks', require('./routes/tasks'));
app.use('/api/suppliers', require('./routes/suppliers'));
app.use('/api/services', require('./routes/services'));
app.use('/api/coordinators', require('./routes/coordinators'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/clients', require('./routes/clients'));
app.use('/api/incomes', require('./routes/incomes'));
app.use('/api/users', require('./routes/users'));
app.use('/api/dashboard', require('./routes/dashboard'));
app.use('/api/roles', require('./routes/roles'));
app.use('/api/system_users', require('./routes/systemUsers'));

// المسار الأساسي للاختبار
app.get('/', (req, res) => {
    res.json({ 
        message: 'مرحباً بكم في واجهة برمجة تطبيقات My Party Pro مع الإشعارات الفورية',
        endPointes: {
            auth: {
                login: ['/api/auth/login', 'POST'],
                register: ['/api/auth/register', 'POST'],
            },
            events: {
                getAllEvents: ['/api/events', 'GET'],
                getEventById: ['/api/events/:id', 'GET'],
                createEvent: ['/api/events', 'POST'],
                updateEvent: ['/api/events/:id', 'PUT'],
                deleteEvent: ['/api/events/:id', 'DELETE'],
            },
            tasks: {
                getAllTasks: ['/api/tasks', 'GET'],
                getTaskById: ['/api/tasks/:id', 'GET'],
                createTask: ['/api/tasks', 'POST'],
                updateTask: ['/api/tasks/:id', 'PUT'],
                deleteTask: ['/api/tasks/:id', 'DELETE'],
            },
            suppliers: {
                getAllSuppliers: ['/api/suppliers', 'GET'],
                getSupplierById: ['/api/suppliers/:id', 'GET'],
                createSupplier: ['/api/suppliers', 'POST'],
                updateSupplier: ['/api/suppliers/:id', 'PUT'],
                deleteSupplier: ['/api/suppliers/:id', 'DELETE'],
            },
            services: {
                getAllServices: ['/api/services', 'GET'],
                getServiceById: ['/api/services/:id', 'GET'],
                createService: ['/api/services', 'POST'],
                updateService: ['/api/services/:id', 'PUT'],
                deleteService: ['/api/services/:id', 'DELETE'],
            },
            coordinators: {
                getAllCoordinators: ['/api/coordinators', 'GET'],
                getCoordinatorById: ['/api/coordinators/:id', 'GET'],
                createCoordinator: ['/api/coordinators', 'POST'],
                updateCoordinator: ['/api/coordinators/:id', 'PUT'],
                deleteCoordinator: ['/api/coordinators/:id', 'DELETE'],
            },
            notifications: {
                getAllNotifications: ['/api/notifications', 'GET'],
                getNotificationById: ['/api/notifications/:id', 'GET'],
                createNotification: ['/api/notifications', 'POST'],
                updateNotification: ['/api/notifications/:id', 'PUT'],
                deleteNotification: ['/api/notifications/:id', 'DELETE'],
            },
            clients: {
                getAllClients: ['/api/clients', 'GET'],
                getClientById: ['/api/clients/:id', 'GET'],
                createClient: ['/api/clients', 'POST'],
                updateClient: ['/api/clients/:id', 'PUT'],
                deleteClient: ['/api/clients/:id', 'DELETE'],
            },
            incomes: {
                getAllIncomes: ['/api/incomes', 'GET'],
                getIncomeById: ['/api/incomes/:id', 'GET'],
                createIncome: ['/api/incomes', 'POST'],
                updateIncome: ['/api/incomes/:id', 'PUT'],
                deleteIncome: ['/api/incomes/:id', 'DELETE'],
            },
            users: {
                getAllUsers: ['/api/users', 'GET'],
                getUserById: ['/api/users/:id', 'GET'],
                createUser: ['/api/users', 'POST'],
                updateUser: ['/api/users/:id', 'PUT'],
                deleteUser: ['/api/users/:id', 'DELETE'],
            },
            dashboard: {
                getAllDashboard: ['/api/dashboard', 'GET'],
                getDashboardById: ['/api/dashboard/:id', 'GET'],
                createDashboard: ['/api/dashboard', 'POST'],
                updateDashboard: ['/api/dashboard/:id', 'PUT'],
                deleteDashboard: ['/api/dashboard/:id', 'DELETE'],
            },
            roles: {
                getAllRoles: ['/api/roles', 'GET'],
                getRoleById: ['/api/roles/:id', 'GET'],
                createRole: ['/api/roles', 'POST'],
                updateRole: ['/api/roles/:id', 'PUT'],
                deleteRole: ['/api/roles/:id', 'DELETE'],
            },
            system_users: {
                getAllSystemUsers: ['/api/system_users', 'GET'],
                getSystemUserById: ['/api/system_users/:id', 'GET'],
                createSystemUser: ['/api/system_users', 'POST'],
                updateSystemUser: ['/api/system_users/:id', 'PUT'],
                deleteSystemUser: ['/api/system_users/:id', 'DELETE'],
            }
        }
    });
});



// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    ApiResponse.error(res, err.message || 'حدث خطأ ما!', err.status || 500, err);
});

// Initialize Real-time Notifications
initSocket(server);
initRealtimeNotifier(sendNotificationToClients).catch(err => {
    console.error('❌ فشل تهيئة مراقب الإشعارات الفورية:', err);
});

server.listen(PORT, HOST, () => {
    console.log(`🚀 Server is running on http://${HOST}:${PORT}`);
});
