DROP DATABASE IF EXISTS `my_party_3`;

CREATE DATABASE IF NOT EXISTS `my_party_3` 
    DEFAULT CHARACTER SET utf8mb4 -- نوع الترميز
    COLLATE utf8mb4_general_ci; -- نوع الترتيب
USE `my_party_3`;

-- =====================================================
-- إنشاء الجداول الأساسية
-- =====================================================

-- جدول الأدوار (تم إضافة عمود deleted_at)
CREATE TABLE IF NOT EXISTS `Roles` (
    `role_name` VARCHAR(50) NOT NULL PRIMARY KEY, -- اسم الدور
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الدور
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الدور
    `deleted_at` TIMESTAMP NULL DEFAULT NULL -- تاريخ حذف الدور
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- إضافة الأدوار
INSERT IGNORE INTO `Roles` (`role_name`) VALUES 
    ('admin'), ('coordinator'), ('supplier'), ('client');

-- جدول تفاصيل الأدوار (الحقول المسموح بها لكل دور)
CREATE TABLE IF NOT EXISTS `Role_Details` (
    `detail_name` VARCHAR(255) NOT NULL, -- اسم التفصيل
    `role_name` VARCHAR(50) NOT NULL, -- اسم الدور
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء التفصيل
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث التفصيل
    PRIMARY KEY (`detail_name`, `role_name`), -- مفتاح أساسي
    FOREIGN KEY (`role_name`) REFERENCES `Roles`(`role_name`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف الدور يتم حذف التفاصيل
    INDEX `idx_role_name` (`role_name`) -- فهرس على اسم الدور
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- إضافة التفاصيل لكل دور
INSERT IGNORE INTO `Role_Details` (`detail_name`, `role_name`) VALUES 
    ('address', 'supplier'), ('notes', 'supplier'),
    ('address', 'client');

-- جدول الصلاحيات
CREATE TABLE IF NOT EXISTS `Permissions` (
    `permission_name` VARCHAR(100) NOT NULL PRIMARY KEY, -- اسم الصلاحية
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الصلاحية
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الصلاحية
    `deleted_at` TIMESTAMP NULL DEFAULT NULL -- تاريخ حذف الصلاحية
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- إضافة الصلاحيات
INSERT IGNORE INTO `Permissions` (`permission_name`) VALUES 
    ('create_admin_user'), ('edit_admin_user'), ('delete_admin_user'), 
    ('create_coordinator_user'), ('edit_coordinator_user'), ('delete_coordinator_user'), 
    ('create_supplier_user'), ('edit_supplier_user'), ('delete_supplier_user'), 
    ('create_client_user'), ('edit_client_user'), ('delete_client_user'), 

    ('create_event'), ('edit_event'), ('delete_event'), 
    ('assign_task'), ('rate_task'), ('view_reports');

-- جدول صلاحيات الأدوار
CREATE TABLE IF NOT EXISTS `Role_Permissions` (
    `role_name` VARCHAR(50) NOT NULL, -- اسم الدور
    `permission_name` VARCHAR(100) NOT NULL, -- اسم الصلاحية
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الصلاحية
    PRIMARY KEY (`role_name`, `permission_name`), -- مفتاح أساسي
    FOREIGN KEY (`role_name`) REFERENCES `Roles`(`role_name`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف الدور يتم حذف الصلاحيات
    FOREIGN KEY (`permission_name`) REFERENCES `Permissions`(`permission_name`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف الصلاحية يتم حذف الصلاحيات
    INDEX `idx_permission_name` (`permission_name`) -- فهرس على اسم الصلاحية
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- إضافة كل الصلاحيات للادمن
INSERT IGNORE INTO `Role_Permissions` (`role_name`, `permission_name`)
        SELECT r.`role_name`, p.`permission_name`
            FROM `Roles` r CROSS JOIN `Permissions` p
            WHERE r.`role_name` = 'admin' AND p.`deleted_at` IS NULL;

-- إضافة الصلاحيات لكل دور
INSERT IGNORE INTO `Role_Permissions` (`role_name`, `permission_name`)
    VALUES
        ('coordinator', 'create_coordinator_user'), ('coordinator', 'edit_coordinator_user'), ('coordinator', 'delete_coordinator_user'),
        ('coordinator', 'create_client_user'), ('coordinator', 'edit_client_user'), ('coordinator', 'delete_client_user'),
        ('coordinator', 'create_event'), ('coordinator', 'edit_event'), ('coordinator', 'delete_event'),
        ('coordinator', 'assign_task'), ('coordinator', 'rate_task'), ('coordinator', 'view_reports'),

        ('supplier', 'create_supplier_user'), ('supplier', 'edit_supplier_user'), ('supplier', 'delete_supplier_user');

-- جدول المستخدمين الأساسي
CREATE TABLE IF NOT EXISTS `Users` (
    `user_id` INT PRIMARY KEY AUTO_INCREMENT, -- رقم المستخدم
    `role_name` VARCHAR(50) NOT NULL, -- اسم الدور

    `full_name` VARCHAR(255) NOT NULL, -- اسم المستخدم
    `phone_number` VARCHAR(20) NULL UNIQUE DEFAULT NULL, -- رقم الهاتف
    `img_url` TEXT NULL DEFAULT NULL, -- رابط الصورة
    `email` VARCHAR(255) NULL UNIQUE DEFAULT NULL, -- البريد الإلكتروني
    `password` VARCHAR(255) NULL DEFAULT NULL, -- كلمة المرور

    `is_active` BOOLEAN DEFAULT FALSE, -- هل المستخدم نشط
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء المستخدم
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث المستخدم
    `deleted_at` TIMESTAMP NULL DEFAULT NULL, -- تاريخ حذف المستخدم
    FOREIGN KEY (`role_name`) REFERENCES `Roles`(`role_name`), -- مفتاح خارجي عند حذف الدور يتم حذف المستخدمين
    INDEX `idx_role_name` (`role_name`), -- فهرس على اسم الدور
    INDEX `idx_is_active` (`is_active`) -- فهرس على حالة المستخدم
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- إضافة المستخدمين مع بياناتهم
INSERT IGNORE INTO `Users` (`role_name`, `full_name`, `phone_number`, `img_url`, `email`, `password`, `is_active`)
    VALUES 
        ('admin', 'admin', '773936481', 'https://i.pravatar.cc/150?u=coordinator', 'admin@myparty.com', '123456', 1), 
        ('coordinator', 'أحمد السقا', '714212208', 'https://i.pravatar.cc/150?u=coordinator', 'ahmed@myparty.com', '123456', 1),
        ('coordinator', 'سعد الهندي', '714332208', 'https://i.pravatar.cc/150?u=coordinator', 'sadalh@myparty.com', '123456', 1),
        
        ('supplier', 'سامي الذهبي', '711282993', 'https://i.pravatar.cc/150?u=coordinator', 'sami@myparty.com', '123456', 1),
        ('supplier', 'خالد السامعي', '773887987', 'https://i.pravatar.cc/150?u=coordinator', 'khaled@myparty.com', '123456', 1),
        ('supplier', 'غرام العبسي', '775653456', 'https://i.pravatar.cc/150?u=coordinator', 'gram@myparty.com', '123456', 1),
        ('supplier', 'أكرم الخطيب', '883214567', 'https://i.pravatar.cc/150?u=coordinator', 'akram@myparty.com', '123456', 1), 
        
        ('client', 'هاني الزبادي', '712564789', 'https://i.pravatar.cc/150?u=coordinator', 'hani@myparty.com', NULL, 0),
        ('client', 'أيمن الحاتمي', '712785430', 'https://i.pravatar.cc/150?u=coordinator', 'ayman@myparty.com', NULL, 0),
        ('client', 'مرام علي', '712089543', 'https://i.pravatar.cc/150?u=coordinator', 'maram@myparty.com', NULL, 0),
        ('client', 'فوزية هاني', '7120564348', 'https://i.pravatar.cc/150?u=coordinator', 'fozih@myparty.com', NULL, 0);

-- جدول قيم تفاصيل المستخدمين
CREATE TABLE IF NOT EXISTS `User_Detail_Values` (
    `user_id` INT NOT NULL, -- معرف المستخدم
    `detail_name` VARCHAR(255) NOT NULL, -- اسم التفصيل
    `role_name` VARCHAR(50) NOT NULL, -- اسم الدور
    `detail_value` TEXT NULL, -- قيمة التفصيل
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء التفصيل
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث التفصيل
    PRIMARY KEY (`user_id`, `detail_name`), -- مفتاح أساسي
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف المستخدم يتم حذف التفاصيل
    FOREIGN KEY (`detail_name`, `role_name`) REFERENCES `Role_Details`(`detail_name`, `role_name`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف التفصيل يتم حذف التفاصيل
    INDEX `idx_detail_name` (`detail_name`), -- فهرس على اسم التفصيل
    INDEX `idx_user_id` (`user_id`) -- فهرس على معرف المستخدم
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- إضافة قيم تفاصيل المستخدمين
INSERT IGNORE INTO `User_Detail_Values` (`user_id`, `role_name`, `detail_name`, `detail_value`)
    VALUES 
        (4, 'supplier', 'address', 'صنعاء'), (3, 'supplier', 'notes', ''), 
        (5, 'supplier', 'address', 'إب'), (4, 'supplier', 'notes', ''), 
        (6, 'supplier', 'address', 'تعز'), (5, 'supplier', 'notes', ''), 
        (7, 'supplier', 'address', 'عدن'), (6, 'supplier', 'notes', ''), 
        (8, 'client', 'address', 'صنعاء'),
        (9, 'client', 'address', 'إب'),
        (10, 'client', 'address', 'تعز'),
        (11, 'client', 'address', 'عدن');


CREATE TABLE IF NOT EXISTS `Coordinator_Clients` (
    `coordinator_email` VARCHAR(255), 
    `client_id` INT NOT NULL,

    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء المستخدم
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث المستخدم
    `deleted_at` TIMESTAMP NULL DEFAULT NULL, -- تاريخ حذف المستخدم

    PRIMARY KEY (`coordinator_email`, `client_id`),
    CONSTRAINT user_CE FOREIGN KEY (`coordinator_email`) REFERENCES `Users`(`email`) ON DELETE CASCADE,
    CONSTRAINT user_CL FOREIGN KEY (`client_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE
)
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO `Coordinator_Clients` (`coordinator_email`, `client_id`)
    VALUES 
        ('ahmed@myparty.com', 8), ('ahmed@myparty.com', 9), 
        ('sadalh@myparty.com', 10), ('sadalh@myparty.com', 11);


-- جدول الأحداث (Events)
CREATE TABLE IF NOT EXISTS `Events` (
    `event_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف الحدث
    `event_name` VARCHAR(255) NOT NULL, -- اسم الحدث
    `description` TEXT NULL, -- وصف الحدث
    `location` VARCHAR(255) NULL, -- موقع الحدث
    `budget` DECIMAL(10,2) DEFAULT 0.00, -- ميزانية الحدث
    `event_date` DATE NOT NULL, -- تاريخ الحدث
    `client_id` INT NOT NULL, -- معرف العميل
    `coordinator_id` INT NOT NULL, -- معرف المنسق
    `status` ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING', -- حالة الحدث
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الحدث
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الحدث
    `deleted_at` TIMESTAMP NULL, -- تاريخ حذف الحدث
    FOREIGN KEY (`client_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف العميل يتم حذف الحدث
    FOREIGN KEY (`coordinator_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف المنسق يتم حذف الحدث
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- إضافة قيم الأحداث
INSERT IGNORE INTO `Events` (`event_name`, `description`, `location`, `budget`, `event_date`, `client_id`, `coordinator_id`, `status`) 
    VALUES 
        ('حفل تخرج', 'حفل تخرج الدفعة الأولى في قسم ال IT', 'صالة الملكة أروى', 1050, '2026-04-15', 7, 2, 'IN_PROGRESS'),
        ('حفل زفاف', 'حفل زفاف العروسين', 'صالة الذهب', 1050, '2026-04-01', 8, 2, 'PENDING'),
        ('جلسة ندوية', 'جلسة ندوية علمية', 'قاعة المؤتمرات', 1050, '2026-03-31', 9, 2, 'IN_PROGRESS'),
        ('حفل تخرج', 'حفل تخرج الدفعة الثانية في قسم ال IT', 'قاعة التاج', 1050, '2026-04-08', 10, 2, 'PENDING'),
        ('حفل زفاف', 'حفل زفاف العروسين', 'صالة النخبة', 1050, '2026-04-05', 7, 2, 'IN_PROGRESS'),
        ('حفل تخرج', 'حفل تخرج الدفعة الثالثة في قسم ال IT', 'قاعة التاج', 1050, '2026-04-03', 8, 2, 'PENDING'),
        ('حفل زفاف', 'حفل زفاف العروسين', 'صالة الذهب', 1050, '2026-04-02', 9, 2, 'IN_PROGRESS');
    
-- جدول الخدمات
CREATE TABLE IF NOT EXISTS `Services` (
    `service_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف الخدمة
    `service_name` VARCHAR(100) NOT NULL, -- اسم الخدمة
    `description` TEXT NULL, -- وصف الخدمة
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الخدمة
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP -- تاريخ تحديث الخدمة
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- إضافة قيم الخدمات
INSERT IGNORE INTO `Services` (`service_name`, `description`) 
    VALUES 
        ('خدمة التغذية', 'خدمة تقديم الطعام والمشروبات'),
        ('خدمة الصوتيات', 'خدمة تقديم الصوتيات'),
        ('خدمة الديكور', 'خدمة تقديم الديكور'),
        ('خدمة التصوير', 'خدمة تقديم التصوير'),
        ('خدمة تنظيم الفعاليات', 'خدمة تنظيم الفعاليات'),
        ('خدمة الضيافة', 'خدمة تقديم الضيافة'),
        ('خدمة الأمن', 'خدمة توفير الأمن'),
        ('خدمة النقل', 'خدمة توفير النقل'),
        ('خدمة الإضاءة', 'خدمة توفير الإضاءة'),
        ('خدمة التنسيق', 'خدمة توفير التنسيق');

-- جدول خدمات الموردين
CREATE TABLE IF NOT EXISTS `Supplier_Services` (
    `supplier_id` INT NOT NULL, -- معرف المورد
    `service_id` INT NOT NULL, -- معرف الخدمة
    PRIMARY KEY (`supplier_id`, `service_id`), -- مفتاح أساسي
    FOREIGN KEY (`supplier_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف المورد يتم حذف الخدمة
    FOREIGN KEY (`service_id`) REFERENCES `Services`(`service_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف الخدمة يتم حذف الخدمة
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- إضافة قيم خدمات الموردين (تم تصحيح الخطأ المزدوج)
INSERT IGNORE INTO `Supplier_Services` (`supplier_id`, `service_id`) 
    VALUES 
        (3, 1), (3, 2), (3, 9), (3, 10),
        (4, 3), (4, 4), (4, 9), (4, 10),
        (5, 5), (5, 6), (5, 9), (5, 10),
        (6, 7), (6, 8), (6, 9), (6, 10);

-- جدول المهام (تم إضافة عمود notes)
CREATE TABLE IF NOT EXISTS `Tasks` (
    `task_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف المهمة
    `event_id` INT NOT NULL, -- معرف الحدث
    `coordinator_id` INT NOT NULL, -- معرف المنسق
    `status` ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING', -- حالة المهمة
    `type_task` VARCHAR(255) NULL, -- نوع المهمة
    `date_start` DATE NULL, -- تاريخ بدء المهمة
    `date_due` DATE NULL, -- تاريخ انتهاء المهمة
    `date_completion` TIMESTAMP NULL, -- تاريخ إكمال المهمة
    `notes` TEXT NULL, -- ملاحظات المهمة (تمت الإضافة)
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء المهمة
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث المهمة
    FOREIGN KEY (`event_id`) REFERENCES `Events`(`event_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف الحدث يتم حذف المهمة
    FOREIGN KEY (`coordinator_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف المنسق يتم حذف المهمة
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- جدول تعيين المهام
CREATE TABLE IF NOT EXISTS `Task_Assigns` (
    `task_assign_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف تعيين المهمة
    `task_id` INT NOT NULL, -- معرف المهمة
    `coordinator_id` INT NOT NULL,  -- المنسق الذي قام بالتعيين
    `user_assign_id` INT NOT NULL,  -- المستخدم المعين (منسق آخر أو مورد)
    `description` TEXT NULL, -- وصف تعيين المهمة
    `cost` DECIMAL(10,2) DEFAULT 0.00, -- تكلفة تعيين المهمة
    `notes` TEXT NULL, -- ملاحظات تعيين المهمة
    `url_image` VARCHAR(255) NULL, -- رابط الصورة لتعيين المهمة
    `reminder_type` ENUM('INTERVAL', 'BEFORE_DUE') NULL, -- نوع التذكير لتعيين المهمة
    `reminder_value` INT NULL, -- قيمة التذكير لتعيين المهمة
    `reminder_unit` ENUM('MINUTE', 'HOUR', 'DAY') NULL, -- وحدة التذكير لتعيين المهمة
    FOREIGN KEY (`task_id`) REFERENCES `Tasks`(`task_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف المهمة يتم حذف تعيين المهمة
    FOREIGN KEY (`coordinator_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف المنسق يتم حذف تعيين المهمة
    FOREIGN KEY (`user_assign_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف المستخدم يتم حذف تعيين المهمة
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- جدول تقييم المهام
CREATE TABLE IF NOT EXISTS `Ratings_Task` (
    `rating_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف التقييم
    `task_id` INT NOT NULL, -- معرف المهمة (مرتبط بـ Task_Assigns)
    `coordinator_id` INT NOT NULL, -- معرف المنسق
    `value_rating` INT NOT NULL CHECK (`value_rating` BETWEEN 1 AND 5), -- قيمة التقييم
    `comment` TEXT NULL, -- تعليق التقييم
    `rated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التقييم
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء التقييم
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث التقييم
    FOREIGN KEY (`task_id`) REFERENCES `Task_Assigns`(`task_assign_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف تعيين المهمة يتم حذف التقييم
    FOREIGN KEY (`coordinator_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف المنسق يتم حذف التقييم
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS `Notifications` (
    `notification_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف الإشعار
    `user_id` INT NULL DEFAULT NULL, -- معرف المستخدم
    `task_id` INT NULL DEFAULT NULL, -- معرف المهمة (Task_Assigns)
    `type` VARCHAR(255) NOT NULL, -- نوع الإشعار
    `title` VARCHAR(255) NOT NULL, -- عنوان الإشعار
    `message` TEXT NOT NULL, -- رسالة الإشعار
    `is_read` BOOLEAN DEFAULT FALSE, -- حالة قراءة الإشعار
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الإشعار
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الإشعار
    FOREIGN KEY (`task_id`) REFERENCES `Task_Assigns`(`task_assign_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف تعيين المهمة يتم حذف الإشعار
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف المستخدم يتم حذف الإشعار
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- جدول الإيرادات
CREATE TABLE IF NOT EXISTS `Incomes` (
    `income_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف الإيراد
    `event_id` INT NOT NULL, -- معرف الحدث
    `amount` DECIMAL(10,2) NOT NULL, -- قيمة الإيراد
    `payment_method` VARCHAR(50) NULL, -- طريقة الدفع
    `payment_date` DATE NOT NULL, -- تاريخ الدفع
    `url_image` VARCHAR(255) NULL, -- رابط الصورة
    `description` TEXT NULL, -- وصف الإيراد
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الإيراد
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الإيراد
    FOREIGN KEY (`event_id`) REFERENCES `Events`(`event_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف الحدث يتم حذف الإيراد
    ) 
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- =====================================================
-- إنشاء الدوال (Functions)
-- =====================================================

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fun_role_has_detail`(
    `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN 
        RETURN EXISTS (
            SELECT 1 FROM `Role_Details` 
            WHERE `detail_name` = p_detail_name AND `role_name` = p_role_name
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_role_has_permission`(
    `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
    `p_permission_name` VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
    BEGIN
        RETURN EXISTS(
            SELECT 1 FROM `Role_Permissions` rp
            WHERE rp.`role_name` = p_role_name AND rp.`permission_name` = p_permission_name
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_role_exists`(
    `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN EXISTS(
            SELECT 1 FROM `Roles` WHERE `role_name` = p_role_name AND `deleted_at` IS NULL
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_has_role`(
    `p_user_id` INT,
    `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci 
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
    BEGIN
        RETURN EXISTS(
            SELECT 1 FROM `Users` 
            WHERE `user_id` = p_user_id AND `role_name` = p_role_name AND `deleted_at` IS NULL
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_get_rolename`(
    `p_user_conditions` JSON
    ) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA
    BEGIN
        DECLARE v_user_id INT ;
        DECLARE v_full_name VARCHAR(255);
        DECLARE v_phone VARCHAR(20);
        DECLARE v_email VARCHAR(255);
        DECLARE v_password VARCHAR(255);
        DECLARE v_img_url TEXT;
        DECLARE v_role_name VARCHAR(50);
        DECLARE v_deleted_at TIMESTAMP;

        SET v_user_id = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.user_id')); 
        SET v_full_name = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.full_name')); 
        SET v_phone = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.phone_number')); 
        SET v_email = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.email')); 
        SET v_password = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.password')); 
        SET v_img_url = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.img_url')); 
    
        
        
        SET @is_all_null =  v_user_id IS NULL AND 
                            v_full_name IS NULL AND 
                            v_phone IS NULL AND 
                            v_email IS NULL AND 
                            v_password IS NULL AND 
                            v_img_url IS NULL;
        SELECT `role_name`, `deleted_at` INTO v_role_name, v_deleted_at FROM `Users` 
        WHERE NOT @is_all_null AND (
                (v_user_id IS NULL OR `user_id` = v_user_id) AND 
                (v_full_name IS NULL OR `full_name` = v_full_name) AND 
                (v_phone IS NULL OR `phone_number` = v_phone) AND 
                (v_email IS NULL OR `email` = v_email) AND 
                (v_password IS NULL OR `password` = v_password) AND 
                (v_img_url IS NULL OR `img_url` = v_img_url)
            )
            LIMIT 1;

        IF v_deleted_at IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is deleted';
        END IF;
        RETURN v_role_name;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost'  FUNCTION `fn_user_has_permission`(
    `p_user_id` INT, 
    `p_permission_name` VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN EXISTS (
            SELECT 1 FROM `Role_Permissions` rp
            JOIN `Permissions` p ON rp.`permission_name` = p.`permission_name`
            WHERE rp.`role_name` = (SELECT `role_name` FROM `Users` WHERE `user_id` = p_user_id AND `deleted_at` IS NULL LIMIT 1) 
            AND rp.`permission_name` = p_permission_name
            AND p.`deleted_at` IS NULL
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_allPermissions`(
    `p_user_conditions` JSON
    ) RETURNS JSON DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
    BEGIN
        RETURN CONCAT('["', (
            SELECT GROUP_CONCAT(`permission_name` SEPARATOR '","') 
            FROM `Role_Permissions` rp
            WHERE rp.`role_name` = fn_user_get_rolename(p_user_conditions)
        ), '"]');
    END $$ 
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_allDetailes`(
    `p_user_id` INT
    ) RETURNS JSON DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
    BEGIN
        RETURN CONCAT('{', (
            SELECT GROUP_CONCAT(CONCAT('"', ud.`detail_name`, '": "', ud.`detail_value`, '"') SEPARATOR ',') 
            FROM `User_Detail_Values` ud
            WHERE ud.`user_id` = p_user_id
        ), '}');
    END $$ 
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_has_detail`(
    `p_user_conditions` JSON,
    `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci 
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN EXISTS(
            SELECT 1 FROM `Role_Details` rd
            WHERE rd.`role_name` = fn_user_get_rolename(p_user_conditions) AND rd.`detail_name` = p_detail_name
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_column_details`(
    ) RETURNS JSON DETERMINISTIC READS SQL DATA
    BEGIN 
        DECLARE ret TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        SELECT GROUP_CONCAT(DISTINCT `detail_name` SEPARATOR '": [], "') INTO ret FROM `Role_Details`;
        IF ret IS NULL OR ret = '' THEN 
            RETURN '{"user_id": [], "is_active": [], "role_name": [], "full_name": [], "phone_number": [], "img_url": [], "email": [], "password": [], "permissions": [], "created_at": [], "updated_at": [], "deleted_at": []}'; 
        END IF;
        RETURN CONCAT(
            '{"user_id": [], "is_active": [], "role_name": [], "full_name": [], "phone_number": [], "img_url": [], "email": [], "password": [], "permissions": [], "', 
            ret, 
            '": [], "created_at": [], "updated_at": [], "deleted_at": []}'
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_detail_exists`(
    `p_user_id` INT,
    `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN 
        RETURN EXISTS (
            SELECT 1 FROM `User_Detail_Values` 
            WHERE `user_id` = p_user_id AND `detail_name` = p_detail_name
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost'  FUNCTION `fn_user_get_detail`(
    `p_user_id` INT, 
    `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN (
            SELECT `detail_value` FROM `User_Detail_Values`
            WHERE `user_id` = p_user_id AND `detail_name` = p_detail_name LIMIT 1
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_is_actived`(
    `p_user_id` INT
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN EXISTS (
            SELECT 1 FROM `Users` WHERE `user_id` = p_user_id AND `is_active` = TRUE
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_is_deleted`(
    `p_user_id` INT
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN EXISTS (
            SELECT 1 FROM `Users` WHERE `user_id` = p_user_id AND `deleted_at` IS NOT NULL
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_total_income`(
    `p_event_id` INT
    ) RETURNS DECIMAL(10,2) DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN (
            SELECT IFNULL(SUM(`amount`), 0) 
            FROM `Incomes` WHERE `event_id` = p_event_id
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_total_expenses`(
    `p_event_id` INT
    ) RETURNS DECIMAL(10,2) DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN (
            SELECT IFNULL(SUM(`cost`), 0) 
            FROM `Tasks` t 
            LEFT JOIN `Task_Assigns` ta ON t.`task_id` = ta.`task_id`
            WHERE t.`event_id` = p_event_id
        );
    END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_net_profit`(
    `p_event_id` INT
    ) RETURNS DECIMAL(10,2) DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN fn_event_total_income(p_event_id) - fn_event_total_expenses(p_event_id);
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_overdue_tasks`(
    `p_event_id` INT
    ) RETURNS INT DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN (
            SELECT COUNT(*) 
            FROM `Tasks`
            WHERE `event_id` = p_event_id 
            AND `status` NOT IN ('COMPLETED', 'CANCELLED')
            AND `date_due` < CURDATE()
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_getKeyOrIndex_array`(
    `p_index` INT, 
    `p_key` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
    `p_keyOrIndex` ENUM('index','key') CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC NO SQL
    BEGIN 
        IF p_keyOrIndex = 'index' THEN 
            RETURN CONCAT('$[', p_index, ']'); 
        ELSEIF p_keyOrIndex = 'key' THEN 
            RETURN CONCAT('$.', p_key); 
        END IF; 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid key or index'; 
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_supplier_avg_rating`(
    `p_supplier_id` INT
    ) RETURNS DECIMAL(3,2) DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN IFNULL((
            SELECT ROUND(AVG(r.`value_rating`), 2) 
            FROM `Ratings_Task` r
            JOIN `Task_Assigns` t ON r.`task_id` = t.`task_assign_id`
            WHERE t.`user_assign_id` = p_supplier_id
        ), 0);
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost'  FUNCTION `fn_array_at`(
    `p_keys` JSON,
    `p_index` INT 
    ) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN JSON_UNQUOTE(JSON_EXTRACT(p_keys, CONCAT('$[', p_index, ']')));
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost'  FUNCTION `fn_json_get`(
    `p_details` JSON,
    `p_key` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci 
    ) RETURNS Text CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN JSON_UNQUOTE(JSON_EXTRACT(p_details, CONCAT('$.', p_key)));
    END $$
DELIMITER ;

-- =====================================================
-- إنشاء طرق العرض (Views)
-- =====================================================

CREATE OR REPLACE VIEW `vw_get_all_usersWithPermissionsAndDetailes` AS 
    SELECT 
        `u`.`user_id`, `u`.`role_name`, `u`.`is_active`,
        `fn_user_allPermissions`(CONCAT('{"user_id":', u.`user_id`, '}')) AS `permissions`, 
        `fn_user_allDetailes`(`u`.`user_id`) AS `detailes`,
        `u`.`created_at`, `u`.`updated_at`, `u`.`deleted_at`
    FROM `Users` `u`;

-- عرض المستخدمين النشطين (استخدام الأعمدة المباشرة)
CREATE OR REPLACE VIEW `vw_users_active` AS
    SELECT 
        u.`user_id`,
        u.`role_name`,
        u.`is_active`,
        u.`full_name`,
        u.`phone_number`,
        u.`email`,
        u.`created_at`,
        u.`updated_at`
    FROM `Users` u
    WHERE u.`deleted_at` IS NULL;

-- عرض المشرفين
CREATE OR REPLACE VIEW `vw_get_all_admins` AS
    SELECT 
        `u`.`user_id` AS `user_id`,
        `u`.`role_name`,
        `u`.`img_url` AS `img_url`,
        `u`.`is_active`,
        (`u`.`deleted_at` IS NOT NULL) AS `is_deleted`,
        `u`.`email` AS `email`,
        `u`.`password` AS `password`,
        `u`.`created_at` AS `created_at`,
        `u`.`updated_at` AS `updated_at`
    FROM `Users` `u` WHERE `u`.`role_name` = 'admin';

-- عرض المنسقين
CREATE OR REPLACE VIEW `vw_get_all_coordinators` AS
    SELECT 
        `u`.`user_id` AS `user_id`,
        `u`.`role_name` AS `role_name`,
        `u`.`img_url` AS `img_url`,
        `u`.`is_active` AS `is_active`,
        (`u`.`deleted_at` IS NOT NULL) AS `is_deleted`,
        `u`.`email` AS `email`,
        `u`.`password` AS `password`,
        `u`.`full_name` AS `full_name`,
        `u`.`phone_number` AS `phone_number`,
        `u`.`created_at` AS `created_at`,
        `u`.`updated_at` AS `updated_at`
    FROM `Users` `u` WHERE `u`.`role_name` = 'coordinator';

-- عرض الموردين
CREATE OR REPLACE VIEW `vw_get_all_suppliers` AS
    SELECT 
        `u`.`user_id` AS `user_id`,
        `u`.`role_name` AS `role_name`,
        `u`.`img_url` AS `img_url`,
        `u`.`is_active` AS `is_active`,
        (`u`.`deleted_at` IS NOT NULL) AS `is_deleted`,
        `u`.`email` AS `email`,
        `u`.`password` AS `password`,
        `u`.`full_name` AS `full_name`,
        `u`.`phone_number` AS `phone_number`,
        `fn_user_get_detail`(`u`.`user_id`,'address') AS `address`,
        `fn_user_get_detail`(`u`.`user_id`,'notes') AS `notes`,
        (
            SELECT ROUND(AVG(r.`value_rating`), 1) 
            FROM `Ratings_Task` r
            JOIN `Task_Assigns` ta ON r.`task_id` = ta.`task_assign_id`
            WHERE ta.`user_assign_id` = u.`user_id`
        ) AS `average_rating`,
        `u`.`created_at` AS `created_at`,
        `u`.`updated_at` AS `updated_at`
        FROM `Users` `u` WHERE `u`.`role_name` = 'supplier';

-- عرض العملاء
CREATE OR REPLACE VIEW `vw_get_all_clients` AS
    SELECT 
        `u`.`user_id` AS `user_id`,
        `u`.`role_name` AS `role_name`,
        `u`.`img_url` AS `img_url`,
        `u`.`is_active` AS `is_active`,
        (`u`.`deleted_at` IS NOT NULL) AS `is_deleted`,
        `u`.`email` AS `email`,
        `u`.`full_name` AS `full_name`,
        `u`.`phone_number` AS `phone_number`,
        `fn_user_get_detail`(`u`.`user_id`,'address') AS `address`,
        `u`.`created_at` AS `created_at`,
        `u`.`updated_at` AS `updated_at`
        FROM `Users` `u` WHERE `u`.`role_name` = 'client';

-- عرض الأدوار مع الصلاحيات
CREATE OR REPLACE VIEW `vw_roles_permissions` AS
    SELECT 
        r.`role_name`,
        r.`created_at` AS `role_created_at`,
        p.`permission_name`,
        p.`created_at` AS `permission_created_at`
    FROM `Roles` r
    LEFT JOIN `Role_Permissions` rp ON r.`role_name` = rp.`role_name`
    LEFT JOIN `Permissions` p ON rp.`permission_name` = p.`permission_name` AND p.`deleted_at` IS NULL
    WHERE r.`deleted_at` IS NULL;

-- عرض جميع تفاصيل المستخدمين
CREATE OR REPLACE VIEW `vw_user_all_details` AS
    SELECT 
        u.`user_id`,
        u.`role_name`,
        u.`is_active`,
        ud.`detail_name`,
        ud.`detail_value`
    FROM `Users` u
    LEFT JOIN `User_Detail_Values` ud ON u.`user_id` = ud.`user_id`
    WHERE u.`deleted_at` IS NULL;


CREATE OR REPLACE VIEW `vw_home_stats` AS
        SELECT
        (SELECT COUNT(*) FROM `Events` WHERE `deleted_at` IS NULL) AS total_events,
        (SELECT COUNT(*) FROM `Events` WHERE `status` = 'PENDING' AND `deleted_at` IS NULL) AS pending_events,
        (SELECT COUNT(*) FROM `Events` WHERE `status` = 'IN_PROGRESS' AND `deleted_at` IS NULL) AS in_progress_events,
        (SELECT COUNT(*) FROM `Events` WHERE `status` = 'COMPLETED' AND `deleted_at` IS NULL) AS completed_events,
        (SELECT COUNT(*) FROM `Events` WHERE `status` = 'CANCELLED' AND `deleted_at` IS NULL) AS cancelled_events,
        (SELECT COUNT(*) FROM `Tasks`) AS total_tasks,
        (SELECT COUNT(*) FROM `Tasks` WHERE `status` = 'PENDING') AS pending_tasks,
        (SELECT COUNT(*) FROM `Tasks` WHERE `status` = 'IN_PROGRESS') AS in_progress_tasks,
        (SELECT COUNT(*) FROM `Tasks` WHERE `status` = 'COMPLETED') AS completed_tasks,
        (SELECT COUNT(*) FROM `Tasks` WHERE `status` = 'CANCELLED') AS cancelled_tasks,
        (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'client' AND `deleted_at` IS NULL) AS total_clients,
        (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'coordinator' AND `deleted_at` IS NULL) AS total_coordinators,
        (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'supplier' AND `deleted_at` IS NULL) AS total_suppliers;


CREATE OR REPLACE VIEW `vw_report_stats` AS
    SELECT
    (SELECT COUNT(*) FROM `Events` WHERE `status` NOT IN ('COMPLETED', 'CANCELLED') AND `deleted_at` IS NULL) AS active_events,
    (SELECT IFNULL(SUM(`amount`), 0) FROM `Incomes`) AS total_revenue,
    (SELECT IFNULL(SUM(`cost`), 0) FROM `Task_Assigns`) AS total_expenses;


CREATE OR REPLACE VIEW `vw_monthly_income` AS
    SELECT
    DATE_FORMAT(`payment_date`, '%Y-%m') AS month,
    SUM(`amount`) AS total_income
    FROM `Incomes`
    GROUP BY DATE_FORMAT(`payment_date`, '%Y-%m')
    ORDER BY month DESC
    LIMIT 12;

-- عرض الأحداث مع التفاصيل (استخدام الأعمدة المباشرة)
CREATE OR REPLACE VIEW `vw_events_detailed` AS
    SELECT 
        e.`event_id`,
        e.`event_name`,
        e.`description`,
        e.`event_date`,
        e.`location`,
        e.`budget` AS `planned_budget`,
        e.`status` AS `event_status`,
        c.`full_name` AS `client_name`,
        c.`phone_number` AS `client_phone`,
        co.`full_name` AS `coordinator_name`,
        co.`phone_number` AS `coordinator_phone`,
        COALESCE((SELECT SUM(`amount`) FROM `Incomes` WHERE `event_id` = e.`event_id`), 0) AS `total_income`,
        COALESCE((SELECT SUM(`cost`) FROM `Task_Assigns` ta JOIN `Tasks` t ON ta.`task_id` = t.`task_id` WHERE t.`event_id` = e.`event_id`), 0) AS `total_expenses`,
        COALESCE((SELECT SUM(`amount`) FROM `Incomes` WHERE `event_id` = e.`event_id`), 0) - 
        COALESCE((SELECT SUM(`cost`) FROM `Task_Assigns` ta JOIN `Tasks` t ON ta.`task_id` = t.`task_id` WHERE t.`event_id` = e.`event_id`), 0) AS `net_profit`,
        (SELECT COUNT(*) FROM `Tasks` WHERE `event_id` = e.`event_id`) AS `total_tasks`,
        (SELECT COUNT(*) FROM `Tasks` WHERE `event_id` = e.`event_id` AND `status` = 'COMPLETED') AS `completed_tasks`,
        CONCAT(
            ROUND(
                100 * (SELECT COUNT(*) FROM `Tasks` WHERE `event_id` = e.`event_id` AND `status` = 'COMPLETED') 
                / NULLIF((SELECT COUNT(*) FROM `Tasks` WHERE `event_id` = e.`event_id`), 0), 
            2), '%'
        ) AS `completion_percentage`,
        e.deleted_at,
       (e.`deleted_at` IS NOT NULL) AS `is_deleted`
    FROM `Events` e
    LEFT JOIN `Users` c ON e.`client_id` = c.`user_id`
    LEFT JOIN `Users` co ON e.`coordinator_id` = co.`user_id`;

-- عرض المهام الكامل (استخدام الأعمدة المباشرة)
CREATE OR REPLACE VIEW `vw_tasks_full` AS
    SELECT 
        ta.`task_assign_id`,
        t.`task_id`,
        t.`event_id`,
        e.`event_name`,
        creator.`full_name` AS `task_creator_name`,
        creator.`user_id` AS `task_creator_id`,
        CASE 
            WHEN fn_user_has_role(ta.`user_assign_id`, 'coordinator') THEN 'coordinator'
            WHEN fn_user_has_role(ta.`user_assign_id`, 'supplier') THEN 'supplier'
            ELSE 'unknown'
        END AS `assignment_type`,
        assignee.`full_name` AS `assignee_name`,
        assignee.`user_id` AS `assignee_id`,
        ta.`description` AS `task_description`,
        ta.`cost`,
        t.`status`,
        t.`type_task`,
        t.`date_start`,
        t.`date_due`,
        t.`date_completion`,
        ta.`notes`,
        ta.`url_image`,
        r.`value_rating` AS `rating_value`,
        r.`comment` AS `rating_comment`
    FROM `Task_Assigns` ta
    INNER JOIN `Tasks` t ON ta.`task_id` = t.`task_id`
    LEFT JOIN `Events` e ON t.`event_id` = e.`event_id`
    LEFT JOIN `Users` creator ON t.`coordinator_id` = creator.`user_id`
    LEFT JOIN `Users` assignee ON ta.`user_assign_id` = assignee.`user_id`
    LEFT JOIN `Ratings_Task` r ON ta.`task_assign_id` = r.`task_id`;

-- عرض أداء الموردين (استخدام الأعمدة المباشرة)
CREATE OR REPLACE VIEW `vw_supplier_performance` AS
    SELECT 
        u.`user_id` AS `supplier_id`,
        u.`full_name` AS `supplier_name`,
        (SELECT GROUP_CONCAT(s.`service_name` SEPARATOR ', ') 
            FROM `Supplier_Services` ss 
            JOIN `Services` s ON ss.`service_id` = s.`service_id` 
            WHERE ss.`supplier_id` = u.`user_id`) AS `services_provided`,
        (SELECT COUNT(DISTINCT ta.`task_id`)
            FROM `Task_Assigns` ta
            JOIN `Tasks` t ON ta.`task_id` = t.`task_id` AND t.`status` = 'COMPLETED'
            WHERE ta.`user_assign_id` = u.`user_id`) AS `tasks_completed`,
        (SELECT ROUND(AVG(r.`value_rating`), 2)
            FROM `Task_Assigns` ta
            JOIN `Tasks` t ON ta.`task_id` = t.`task_id` AND t.`status` = 'COMPLETED'
            LEFT JOIN `Ratings_Task` r ON ta.`task_assign_id` = r.`task_id`
            WHERE ta.`user_assign_id` = u.`user_id` AND r.`rating_id` IS NOT NULL) AS `avg_rating`,
        (SELECT COUNT(r.`rating_id`)
            FROM `Task_Assigns` ta
            JOIN `Tasks` t ON ta.`task_id` = t.`task_id` AND t.`status` = 'COMPLETED'
            JOIN `Ratings_Task` r ON ta.`task_assign_id` = r.`task_id`
            WHERE ta.`user_assign_id` = u.`user_id`) AS `total_ratings`
    FROM `Users` u
    WHERE u.`role_name` = 'supplier' AND u.`deleted_at` IS NULL;

-- عرض أداء المنسقين (استخدام الأعمدة المباشرة)
CREATE OR REPLACE VIEW `vw_coordinator_performance` AS
    SELECT 
        u.`user_id` AS `coordinator_id`,
        u.`full_name` AS `coordinator_name`,
        COUNT(DISTINCT e.`event_id`) AS `events_managed`,
        COUNT(DISTINCT t.`task_id`) AS `total_tasks_assigned`,
        COUNT(DISTINCT CASE WHEN t.`status` = 'COMPLETED' THEN t.`task_id` END) AS `tasks_completed`,
        (SELECT ROUND(AVG(r.`value_rating`), 2) 
        FROM `Ratings_Task` r 
        WHERE r.`coordinator_id` = u.`user_id`) AS `avg_rating_given`
    FROM `Users` u
    LEFT JOIN `Events` e ON u.`user_id` = e.`coordinator_id`
    LEFT JOIN `Tasks` t ON e.`event_id` = t.`event_id`
    WHERE u.`role_name` = 'coordinator' AND u.`deleted_at` IS NULL
    GROUP BY u.`user_id`;

-- عرض الإشعارات (استخدام الأعمدة المباشرة)
CREATE OR REPLACE VIEW `vw_notifications` AS
    SELECT 
        n.`notification_id`,
        n.`task_id`,
        NULL AS `task_type`,
        n.`type` AS `notification_type`,
        n.`title`,
        n.`message`,
        n.`is_read`,
        n.`created_at`,
        CASE 
            WHEN fn_user_has_role(n.`user_id`, 'coordinator') THEN 'Coordinator'
            WHEN fn_user_has_role(n.`user_id`, 'supplier') THEN 'Supplier'
            ELSE 'Unknown'
        END AS `recipient_type`,
        u.`full_name` AS `recipient_name`
    FROM `Notifications` n
    LEFT JOIN `Users` u ON n.`user_id` = u.`user_id`
    WHERE n.`user_id` IS NOT NULL;

-- =====================================================
-- إنشاء الإجراءات المخزنة (Stored Procedures)
-- =====================================================

DELIMITER $$
CREATE PROCEDURE `sp_get_user_by_id`(
    IN `p_user_id` INT
    )
    BEGIN 
        DECLARE sql_query TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        SET sql_query = CONCAT(
            'SELECT * FROM vw_get_all_', fn_user_get_rolename(CONCAT('{"user_id":', p_user_id, '}')), 's WHERE user_id = ', p_user_id
        );
        PREPARE stmt FROM sql_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_get_user_by_email`(
    IN `p_email` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
    BEGIN 
        DECLARE sql_query TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        SET sql_query = CONCAT(
            'SELECT * FROM vw_get_all_', fn_user_get_rolename(CONCAT('{"email":"', p_email, '"}')), 's WHERE `email` = ''', p_email, ''''
        );
        PREPARE stmt FROM sql_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_login_user`(
    IN `p_email` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
    BEGIN 
        DECLARE v_user_id INT;
        DECLARE v_user_is_active BOOLEAN;
        DECLARE v_user_is_deleted BOOLEAN;
        DECLARE v_user_password_hash VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        
        SELECT `user_id`, `is_active`, `deleted_at` IS NOT NULL, `password` 
            INTO v_user_id, v_user_is_active, v_user_is_deleted, v_user_password_hash 
        FROM `Users` WHERE `email` = p_email;
        
        IF v_user_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        END IF;
        
        IF NOT v_user_is_active THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الحساب غير نشط';
        ELSEIF v_user_is_deleted THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الحساب محذوف';
        ELSEIF v_user_password_hash IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'مستخدم غير موجود أو حساب غير مدعوم';
        END IF;

        CALL sp_get_user_by_id(v_user_id);
    END$$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE `sp_create_user`(
    IN `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_full_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_phone_number` VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_img_url` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_email` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_password` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_bin,
    IN `p_details` JSON
    ) DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
    BEGIN 
        DECLARE v_user_id INT;
        DECLARE v_detail_name VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_detail_value TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_i INT DEFAULT 0;
        DECLARE v_keys JSON DEFAULT JSON_KEYS(p_details);
        DECLARE v_total INT DEFAULT JSON_LENGTH(v_keys);
        DECLARE v_error_msg TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_coordinator_email VARCHAR(255) DEFAULT NULL; 

        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

        IF NOT fn_role_exists(p_role_name) OR p_role_name = 'admin' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'يرجى التاكد من دور الحياب';
        END IF;
        IF p_role_name = 'client' THEN
            IF p_password IS NOT NULL THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'العميل لا يمتلك حقل كلمة المرور';
            END IF;
            
            SET v_coordinator_email = fn_json_get(p_details, 'coordinator_email');
        
            -- التحقق من وجود coordinator_email
            IF v_coordinator_email IS NULL THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'يجب أن يتم إنشاء العميل من قبل منسق';
            END IF;
        END IF;

        START TRANSACTION;
        INSERT INTO `Users` (`role_name`, `full_name`, `phone_number`, `img_url`, `email`, `password`) 
            VALUES (p_role_name, p_full_name, p_phone_number, p_img_url, p_email, IF(p_role_name = 'client', NULL, p_password));
        SET v_user_id = LAST_INSERT_ID();

         IF p_role_name = 'client' THEN
            INSERT INTO `Coordinator_Clients` (`coordinator_email`, `client_id`) 
            VALUES (v_coordinator_email, v_user_id);
        END IF;
        
        
        WHILE v_i < v_total DO
            SET v_detail_name = fn_array_at(v_keys, v_i);
            IF v_detail_name != 'coordinator_email' THEN 
                SET v_detail_value = fn_json_get(p_details, v_detail_name);

                IF NOT fun_role_has_detail(v_detail_name, p_role_name) THEN  
                    SET v_error_msg = CONCAT('Detail "', v_detail_name, '" not allowed for this role');
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
                END IF;

                INSERT INTO `User_Detail_Values` (`user_id`, `detail_name`, `role_name`, `detail_value`)
                    VALUES (v_user_id, v_detail_name, p_role_name, v_detail_value);
             END IF;
            SET v_i = v_i + 1;
        END WHILE;

        IF p_role_name != 'client' THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (1, 'create user', 'تم إنشاء حساب جديد', CONCAT('تم إنشاء حساب ', p_role_name, ' جديد رقم ', v_user_id, ' يرجى الموافقة عليه لتفعيله'));
        END IF;
        COMMIT;

        CALL sp_get_user_by_id(v_user_id);
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE `sp_update_user`(
    IN `p_user_id` INT,
    IN `p_full_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_phone_number` VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_img_url` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_email` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_details` JSON 
    ) DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
    BEGIN
        DECLARE v_role_name VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_detail_name VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_detail_value TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_i INT DEFAULT 0;
        DECLARE v_keys JSON DEFAULT JSON_KEYS(p_details);
        DECLARE v_total INT DEFAULT JSON_LENGTH(v_keys);
        DECLARE v_coordinator_email VARCHAR(255) DEFAULT NULL; 
        DECLARE v_error_msg TEXT;

        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

        SELECT `role_name` INTO v_role_name FROM `Users` WHERE `user_id` = p_user_id AND `deleted_at` IS NULL;
        IF v_role_name IS NULL OR v_role_name = 'admin' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or deleted';
        END IF;

        IF v_role_name = 'admin' THEN
            SET v_coordinator_email = fn_json_get(p_details, 'coordinator_email');

            IF v_coordinator_email IS NULL THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'يجب أن يتم إنشاء العميل من قبل منسق';
            END IF;
        END IF;

        START TRANSACTION;
        UPDATE `Users` SET 
            `full_name` = p_full_name, 
            `phone_number` = p_phone_number, 
            `img_url` = p_img_url, 
            `email` = p_email WHERE `user_id` = p_user_id;

        WHILE v_i < v_total DO
            SET v_detail_name = fn_array_at(v_keys, v_i);
            IF v_detail_name != 'coordinator_email' THEN
                SET v_detail_value = fn_json_get(p_details, v_detail_name);

                IF NOT fn_user_detail_exists(p_user_id, v_detail_name) THEN
                    IF NOT fun_role_has_detail(v_detail_name, v_role_name) THEN 
                        SET v_error_msg = CONCAT('Detail "', v_detail_name, '" not allowed for this role');
                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
                    END IF;

                    INSERT INTO `User_Detail_Values` (`user_id`, `detail_name`, `role_name`, `detail_value`)
                        VALUES (p_user_id, v_detail_name, v_role_name, v_detail_value);
                ELSE
                    UPDATE `User_Detail_Values`
                        SET `detail_value` = v_detail_value
                        WHERE `user_id` = p_user_id AND `detail_name` = v_detail_name;
                END IF;
            END IF;
            SET v_i = v_i + 1;
        END WHILE;
        COMMIT;
        CALL sp_get_user_by_id(p_user_id);
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE `sp_delete_user`(
    IN `p_user_id` INT
    ) DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
    BEGIN
        UPDATE `Users` SET `deleted_at` = CURRENT_TIMESTAMP WHERE `user_id` = p_user_id;
        SELECT p_user_id AS user_id;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE `sp_restore_user`(
    IN `p_user_id` INT
    ) DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
    BEGIN
        IF EXISTS (SELECT 1 FROM `Users` WHERE `user_id` = p_user_id) THEN
            IF fn_user_is_deleted(p_user_id) THEN
                UPDATE `Users` SET `deleted_at` = NULL WHERE `user_id` = p_user_id;
                SELECT p_user_id AS user_id;
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is already active';
            END IF;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE `sp_set_user_active`(
    IN `p_user_id` INT, 
    IN `p_active` BOOLEAN
    ) DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
    BEGIN
        IF EXISTS (
                SELECT 1 FROM `Users` WHERE 
                    `user_id` = p_user_id AND 
                    `deleted_at` IS NULL AND 
                    `role_name` = 'client'
            ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
        END IF;

        UPDATE `Users` SET `is_active` = p_active WHERE `user_id` = p_user_id AND `deleted_at` IS NULL;
        SELECT p_user_id AS user_id;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE `sp_add_permission_to_role`(
    IN `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
    IN `p_permission_name` VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM `Roles` WHERE `role_name` = p_role_name AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Role not found';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM `Permissions` WHERE `permission_name` = p_permission_name AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission not found';
        END IF;

        INSERT INTO `Role_Permissions` (`role_name`, `permission_name`) VALUES (p_role_name, p_permission_name);
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE `sp_remove_permission_from_role`(
    IN `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
    IN `p_permission_name` VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
    BEGIN
        DELETE FROM `Role_Permissions` WHERE `role_name` = p_role_name AND `permission_name` = p_permission_name;
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_event_full`(
    IN `p_client_id` INT,
    IN `p_coordinator_id` INT,
    IN `p_name_event` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_description` TEXT,
    IN `p_event_date` DATE,
    IN `p_location` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_budget` DECIMAL(10,2),
    IN `p_status` ENUM('PENDING', 'IN_PROGRESS','COMPLETED','CANCELLED') CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_tasks_json` JSON
    )
    BEGIN
        DECLARE v_event_id INT;
        DECLARE v_counter INT DEFAULT 0;
        DECLARE v_total INT;
        DECLARE v_task JSON;
        
        DECLARE v_type_task VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_task_status VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_task_date_start DATE;
        DECLARE v_task_date_due DATE;
        DECLARE v_assign_user_id INT;
        DECLARE v_assign_description TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_assign_cost DECIMAL(10,2);
        DECLARE v_assign_notes TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_assign_url_image VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_assign_reminder_type VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_assign_reminder_value INT;
        DECLARE v_assign_reminder_unit VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        
        DECLARE v_task_id INT;

        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;
        
        START TRANSACTION;
        
        IF NOT fn_user_has_role(p_client_id, 'client') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Client must have client role';
        END IF;
        
        IF NOT fn_user_has_role(p_coordinator_id, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coordinator must have coordinator role';
        END IF;
        
        INSERT INTO `Events` (
            `client_id`, 
            `coordinator_id`, 
            `event_name`, 
            `description`, 
            `event_date`, 
            `location`, 
            `budget`, 
            `status`
        ) VALUES (
            p_client_id, 
            p_coordinator_id, 
            p_name_event, 
            p_description,
            p_event_date, 
            p_location, 
            p_budget, 
            p_status
        );
        
        SET v_event_id = LAST_INSERT_ID();
        
        IF p_tasks_json IS NOT NULL AND JSON_VALID(p_tasks_json) THEN
            SET v_total = JSON_LENGTH(p_tasks_json);
            
            WHILE v_counter < v_total DO
                SET v_task = JSON_EXTRACT(p_tasks_json, CONCAT('$[', v_counter, ']'));
                
                SET v_type_task = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.type_task'));
                SET v_task_status = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.task_status'));
                SET v_task_date_start = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.task_date_start'));
                SET v_task_date_due = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.task_date_due'));
                SET v_assign_user_id = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.assign_user_id'));
                SET v_assign_description = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.assign_description'));
                SET v_assign_cost = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.assign_cost')), 0);
                SET v_assign_notes = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.assign_notes'));
                SET v_assign_url_image = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.assign_url_image'));
                SET v_assign_reminder_type = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.assign_reminder_type'));
                SET v_assign_reminder_value = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.assign_reminder_value'));
                SET v_assign_reminder_unit = JSON_UNQUOTE(JSON_EXTRACT(v_task, '$.assign_reminder_unit'));
                
                IF NOT (fn_user_has_role(v_assign_user_id, 'coordinator') OR fn_user_has_role(v_assign_user_id, 'supplier')) THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Assigned user must be a coordinator or supplier';
                END IF;
                
                INSERT INTO `Tasks` (
                    `event_id`,
                    `coordinator_id`,
                    `status`,
                    `type_task`,
                    `date_start`,
                    `date_due`
                ) VALUES (
                    v_event_id,
                    p_coordinator_id,
                    IFNULL(v_task_status, 'PENDING'),
                    v_type_task,
                    v_task_date_start,
                    v_task_date_due
                );
                
                SET v_task_id = LAST_INSERT_ID();
                
                INSERT INTO `Task_Assigns` (
                    `task_id`,
                    `coordinator_id`,
                    `user_assign_id`,
                    `description`,
                    `cost`,
                    `notes`,
                    `url_image`,
                    `reminder_type`,
                    `reminder_value`,
                    `reminder_unit` 
                ) VALUES (
                    v_task_id,
                    p_coordinator_id,
                    v_assign_user_id,
                    v_assign_description,
                    v_assign_cost,
                    v_assign_notes,
                    v_assign_url_image,
                    v_assign_reminder_type,
                    v_assign_reminder_value,
                    v_assign_reminder_unit
                );
                
                SET v_counter = v_counter + 1;
            END WHILE;
        END IF;
        
        COMMIT;
        
        SELECT * FROM `Events` WHERE `event_id` = v_event_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_task_status`(
    IN `p_task_id` INT,
    IN `p_new_status` ENUM(
        'PENDING',
        'IN_PROGRESS',
        'UNDER_REVIEW'
        'COMPLETED',
        'CANCELLED'
    ) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_notes` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
    BEGIN
        DECLARE v_old_status VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
        DECLARE v_event_id INT;
        DECLARE v_coordinator_id INT;
        
        SELECT `status`, `event_id`, `coordinator_id`
            INTO v_old_status, v_event_id, v_coordinator_id
            FROM `Tasks` 
            WHERE `task_id` = p_task_id;
        
        UPDATE `Tasks`
            SET `status` = p_new_status,
                `notes` = IF(p_notes IS NOT NULL, 
                            CONCAT(IFNULL(`notes`, ''), '\n', p_notes), 
                            `notes`),
                `date_completion` = IF(p_new_status = 'COMPLETED', NOW(), `date_completion`)
            WHERE `task_id` = p_task_id;
        
        IF p_new_status IN ('COMPLETED', 'CANCELLED') THEN
            INSERT INTO `Notifications` (`user_id`, `task_id`, `type`, `title`, `message`)
            SELECT v_coordinator_id, p_task_id, 
                CONCAT('TASK_', p_new_status),
                CONCAT('تم ', IF(p_new_status='COMPLETED', 'إكمال', 'إلغاء'), ' مهمة'),
                CONCAT('المهمة رقم ', p_task_id, ' في الحدث ', 
                        (SELECT `event_name` FROM `Events` WHERE `event_id` = v_event_id), 
                        ' قد ', IF(p_new_status='COMPLETED', 'اكتملت', 'ألغيت'), '.')
            FROM DUAL
            WHERE NOT EXISTS (
                SELECT 1 FROM `Notifications` 
                WHERE `user_id` = v_coordinator_id 
                AND `task_id` = p_task_id 
                AND `type` = CONCAT('TASK_', p_new_status)
            );
            
            INSERT INTO `Notifications` (`user_id`, `task_id`, `type`, `title`, `message`)
            SELECT ta.`user_assign_id`, p_task_id,
                CONCAT('TASK_', p_new_status),
                CONCAT('تم ', IF(p_new_status='COMPLETED', 'إكمال', 'إلغاء'), ' مهمة'),
                CONCAT('المهمة رقم ', p_task_id, ' في الحدث ', 
                        (SELECT `event_name` FROM `Events` WHERE `event_id` = v_event_id), 
                        ' قد ', IF(p_new_status='COMPLETED', 'اكتملت', 'ألغيت'), '.')
            FROM `Task_Assigns` ta
            WHERE ta.`task_id` = p_task_id
            AND ta.`user_assign_id` != v_coordinator_id
            AND NOT EXISTS (
                SELECT 1 FROM `Notifications` n
                WHERE n.`user_id` = ta.`user_assign_id`
                    AND n.`task_id` = p_task_id
                    AND n.`type` = CONCAT('TASK_', p_new_status)
            );
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_add_task_rating`(
    IN `p_task_id` INT,
    IN `p_coordinator_id` INT,
    IN `p_value_rating` INT,
    IN `p_comment` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
   BEGIN
       DECLARE v_event_id INT;
       DECLARE v_task_assign_id INT;
       DECLARE v_assigned_user_id INT;
       DECLARE v_actual_coordinator_id INT;


       SELECT ta.`task_assign_id`, t.`event_id`, ta.`user_assign_id`, t.`coordinator_id`
           INTO v_task_assign_id, v_event_id, v_assigned_user_id, v_actual_coordinator_id
       FROM `Tasks` t
       LEFT JOIN `Task_Assigns` ta ON t.`task_id` = ta.`task_id`
       WHERE t.`task_id` = p_task_id AND t.`status` = 'COMPLETED'
       LIMIT 1;


       IF v_task_assign_id IS NULL THEN
           SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تقييم مهمة غير مكتملة أو لم يتم إسنادها.';
       END IF;

       -- Fallback to the task's coordinator if backend passes NULL
       SET v_actual_coordinator_id = COALESCE(p_coordinator_id, v_actual_coordinator_id);


       IF NOT EXISTS (
           SELECT 1 FROM `Events` e
           WHERE e.`event_id` = v_event_id AND e.`coordinator_id` = v_actual_coordinator_id
       ) AND NOT EXISTS (
           SELECT 1 FROM `Tasks` t 
           WHERE t.`task_id` = p_task_id AND t.`coordinator_id` = v_actual_coordinator_id
       ) THEN
           SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ليس لديك صلاحية تقييم هذه المهمة.';
       END IF;


       INSERT INTO `Ratings_Task` (`task_id`, `coordinator_id`, `value_rating`, `comment`)
       VALUES (v_task_assign_id, v_actual_coordinator_id, p_value_rating, p_comment);


       IF v_assigned_user_id IS NOT NULL THEN
           INSERT INTO `Notifications` (`user_id`, `task_id`, `type`, `title`, `message`)
           VALUES (
               v_assigned_user_id,
               v_task_assign_id,
               'NEW_RATING',
               'تقييم جديد',
               CONCAT('تم تقييم مهمتك بـ ', p_value_rating, ' نجوم.')
           );
       END IF;
   END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_generate_reminders`()
    BEGIN
        INSERT INTO `Notifications` (`user_id`, `task_id`, `type`, `title`, `message`)
        SELECT 
            ta.`user_assign_id` AS `user_id`,
            ta.`task_assign_id` AS `task_id`,
            'TASK_REMINDER' AS `type`,
            'تذكير بمهمة' AS `title`,
            CONCAT('المهمة رقم ', t.`task_id`, ' مستحقة في ', t.`date_due`) AS `message`
        FROM `Tasks` t
        JOIN `Task_Assigns` ta ON t.`task_id` = ta.`task_id`
        WHERE t.`status` NOT IN ('COMPLETED', 'CANCELLED')
        AND t.`date_due` BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)
        AND NOT EXISTS (
            SELECT 1 FROM `Notifications` n
            WHERE n.`task_id` = ta.`task_assign_id`
                AND n.`type` = 'TASK_REMINDER'
                AND DATE(n.`created_at`) = CURDATE()
        );
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_financial_report`(
    IN `p_start_date` DATE,
    IN `p_end_date` DATE
    )
    BEGIN
        SELECT 
            e.`event_id`,
            e.`event_name`,
            e.`event_date`,
            COALESCE(inc.`total_income`, 0) AS `total_income`,
            COALESCE(exp.`total_expenses`, 0) AS `total_expenses`,
            COALESCE(inc.`total_income`, 0) - COALESCE(exp.`total_expenses`, 0) AS `profit`
        FROM `Events` e
        LEFT JOIN (
            SELECT `event_id`, SUM(`amount`) AS `total_income`
            FROM `Incomes`
            WHERE `payment_date` BETWEEN p_start_date AND p_end_date
            GROUP BY `event_id`
        ) inc ON e.`event_id` = inc.`event_id`
        LEFT JOIN (
            SELECT t.`event_id`, SUM(ta.`cost`) AS `total_expenses`
            FROM `Tasks` t
            JOIN `Task_Assigns` ta ON t.`task_id` = ta.`task_id`
            WHERE t.`date_completion` BETWEEN p_start_date AND p_end_date
            GROUP BY t.`event_id`
        ) exp ON e.`event_id` = exp.`event_id`
        WHERE e.`event_date` BETWEEN p_start_date AND p_end_date;

        SELECT 
            COALESCE(SUM(i.`amount`), 0) AS `grand_total_income`,
            COALESCE(SUM(ta.`cost`), 0) AS `grand_total_expenses`,
            COALESCE(SUM(i.`amount`), 0) - COALESCE(SUM(ta.`cost`), 0) AS `grand_profit`
        FROM `Events` e
        LEFT JOIN `Incomes` i ON e.`event_id` = i.`event_id` AND i.`payment_date` BETWEEN p_start_date AND p_end_date
        LEFT JOIN `Tasks` t ON e.`event_id` = t.`event_id` AND t.`date_completion` BETWEEN p_start_date AND p_end_date
        LEFT JOIN `Task_Assigns` ta ON t.`task_id` = ta.`task_id`
        WHERE e.`event_date` BETWEEN p_start_date AND p_end_date;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_change_password`(
    IN `p_user_id` INT,
    IN `p_old_password` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_new_password` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
    BEGIN
        IF EXISTS(
            SELECT 1 FROM `Users` WHERE `user_id` = p_user_id AND `password` = p_old_password
        ) THEN
            UPDATE `Users` SET `password` = p_new_password, `updated_at` = NOW()
                WHERE `user_id` = p_user_id;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'كلمة المرور القديمة غير صحيحة.';
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_cancel_event`(
    IN `p_event_id` INT,
    IN `p_reason` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;
        
        START TRANSACTION;
        
        UPDATE `Events` 
            SET `status` = 'CANCELLED',
                `description` = CONCAT(IFNULL(`description`, ''), '\nالإلغاء: ', p_reason)
            WHERE `event_id` = p_event_id;
        
        UPDATE `Tasks`
            SET `status` = 'CANCELLED', 
                `notes` = CONCAT(IFNULL(`notes`, ''), '\nألغيت بسبب إلغاء الحدث: ', p_reason)
            WHERE `event_id` = p_event_id AND `status` NOT IN ('COMPLETED', 'CANCELLED');
        
        INSERT INTO `Notifications` (`user_id`, `task_id`, `type`, `title`, `message`)
            SELECT `coordinator_id`, NULL, 'EVENT_CANCELLED', 'تم إلغاء حدث',
                CONCAT('الحدث ', `event_name`, ' تم إلغاؤه. السبب: ', p_reason)
            FROM `Events`
            WHERE `event_id` = p_event_id;
        
        COMMIT;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_event`(
    IN `p_event_id` INT,
    IN `p_event_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_description` TEXT,
    IN `p_event_date` DATE,
    IN `p_location` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_budget` DECIMAL(10,2),
    IN `p_status` ENUM('PENDING','IN_PROGRESS','COMPLETED','CANCELLED') CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
    BEGIN
        UPDATE `Events`
            SET `event_name` = IFNULL(p_event_name, `event_name`),
                `description` = IFNULL(p_description, `description`),
                `event_date` = IFNULL(p_event_date, `event_date`),
                `location` = IFNULL(p_location, `location`),
                `budget` = IFNULL(p_budget, `budget`),
                `status` = IFNULL(p_status, `status`),
                `updated_at` = NOW()
            WHERE `event_id` = p_event_id;
        
        SELECT * FROM `Events` WHERE `event_id` = p_event_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_event`(
    IN `p_event_id` INT
    )
    BEGIN
        UPDATE `Events` SET `deleted_at` = NOW() WHERE `event_id` = p_event_id;
        SELECT p_event_id AS event_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_service`(
    IN `p_service_name` VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_description` TEXT
    )
    BEGIN
        INSERT INTO `Services` (`service_name`, `description`) 
        VALUES (p_service_name, p_description);
        SELECT * FROM `Services` WHERE `service_id` = LAST_INSERT_ID();
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_service`(
    IN `p_service_id` INT,
    IN `p_service_name` VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_description` TEXT
    )
    BEGIN
        UPDATE `Services`
            SET `service_name` = IFNULL(p_service_name, `service_name`),
                `description` = IFNULL(p_description, `description`),
                `updated_at` = NOW()
            WHERE `service_id` = p_service_id;
        SELECT * FROM `Services` WHERE `service_id` = p_service_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_service`(
    IN `p_service_id` INT
    )
    BEGIN
        DELETE FROM `Services` WHERE `service_id` = p_service_id;
        SELECT p_service_id AS service_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_income`(
    IN `p_event_id` INT,
    IN `p_amount` DECIMAL(10,2),
    IN `p_description` TEXT,
    IN `p_payment_date` DATE,
    IN `p_payment_method` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_url_image` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
    BEGIN
        INSERT INTO `Incomes` (`event_id`, `amount`, `description`, `payment_date`, `payment_method`, `url_image`)
        VALUES (p_event_id, p_amount, p_description, p_payment_date, p_payment_method, p_url_image);
        SELECT * FROM `Incomes` WHERE `income_id` = LAST_INSERT_ID();
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_income`(
    IN `p_income_id` INT,
    IN `p_amount` DECIMAL(10,2),
    IN `p_description` TEXT,
    IN `p_payment_date` DATE,
    IN `p_payment_method` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_url_image` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
    BEGIN
        UPDATE `Incomes`
            SET `amount` = IFNULL(p_amount, `amount`),
                `description` = IFNULL(p_description, `description`),
                `payment_date` = IFNULL(p_payment_date, `payment_date`),
                `payment_method` = IFNULL(p_payment_method, `payment_method`),
                `url_image` = IFNULL(p_url_image, `url_image`),
                `updated_at` = NOW()
            WHERE `income_id` = p_income_id;
        SELECT * FROM `Incomes` WHERE `income_id` = p_income_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_income`(
    IN `p_income_id` INT
    )
    BEGIN
        DELETE FROM `Incomes` WHERE `income_id` = p_income_id;
        SELECT p_income_id AS income_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_task`(
    IN `p_event_id` INT,
    IN `p_coordinator_id` INT,
    IN `p_type_task` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_status` ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_date_start` DATE,
    IN `p_date_due` DATE,
    IN `p_assign_user_id` INT,
    IN `p_assign_description` TEXT,
    IN `p_assign_cost` DECIMAL(10,2),
    IN `p_assign_notes` TEXT,
    IN `p_assign_url_image` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
    BEGIN
        DECLARE v_task_id INT;
        DECLARE v_task_assign_id INT;
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;
        
        START TRANSACTION;
        
        INSERT INTO `Tasks` (`event_id`, `coordinator_id`, `type_task`, `status`, `date_start`, `date_due`)
        VALUES (p_event_id, p_coordinator_id, p_type_task, IFNULL(p_status, 'PENDING'), p_date_start, p_date_due);
        
        SET v_task_id = LAST_INSERT_ID();
        
        INSERT INTO `Task_Assigns` (`task_id`, `coordinator_id`, `user_assign_id`, `description`, `cost`, `notes`, `url_image`)
        VALUES (v_task_id, p_coordinator_id, p_assign_user_id, p_assign_description, p_assign_cost, p_assign_notes, p_assign_url_image);
        SET v_task_assign_id = LAST_INSERT_ID();
        
        COMMIT;
        
        SELECT * FROM `vw_tasks_full` WHERE `task_id` = v_task_id AND `task_assign_id` = v_task_assign_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_task`(
    IN `p_task_id` INT,
    IN `p_type_task` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_status` ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_date_start` DATE,
    IN `p_date_due` DATE,
    IN `p_assign_description` TEXT,
    IN `p_assign_cost` DECIMAL(10,2),
    IN `p_assign_notes` TEXT,
    IN `p_assign_url_image` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    )
    BEGIN
        START TRANSACTION;
        
        UPDATE `Tasks`
            SET `type_task` = IFNULL(p_type_task, `type_task`),
                `status` = IFNULL(p_status, `status`),
                `date_start` = IFNULL(p_date_start, `date_start`),
                `date_due` = IFNULL(p_date_due, `date_due`),
                `updated_at` = NOW()
            WHERE `task_id` = p_task_id;
            
        UPDATE `Task_Assigns`
            SET `description` = IFNULL(p_assign_description, `description`),
                `cost` = IFNULL(p_assign_cost, `cost`),
                `notes` = IFNULL(p_assign_notes, `notes`),
                `url_image` = IFNULL(p_assign_url_image, `url_image`)
            WHERE `task_id` = p_task_id;
            
        COMMIT;
        
        SELECT * FROM `vw_tasks_full` WHERE `task_id` = p_task_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_task`(
    IN `p_task_id` INT
    )
    BEGIN
        DELETE FROM `Tasks` WHERE `task_id` = p_task_id;
        SELECT p_task_id AS task_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_assign_service_to_supplier`(
    IN `p_supplier_id` INT,
    IN `p_service_id` INT
    )
    BEGIN
        INSERT IGNORE INTO `Supplier_Services` (`supplier_id`, `service_id`)
        VALUES (p_supplier_id, p_service_id);
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_remove_service_from_supplier`(
    IN `p_supplier_id` INT,
    IN `p_service_id` INT
    )
    BEGIN
        DELETE FROM `Supplier_Services` WHERE `supplier_id` = p_supplier_id AND `service_id` = p_service_id;
    END$$
DELIMITER ;

-- =====================================================
-- إنشاء المحفزات (Triggers)
-- =====================================================

DELIMITER $$
CREATE TRIGGER `trg_users_before_insert` BEFORE INSERT ON `Users`
    FOR EACH ROW 
    BEGIN
        IF NEW.`role_name` = 'client' AND NEW.`password` IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'can not insert password for client';
        ELSEIF NEW.`role_name` != 'client' AND (NEW.`password` IS NULL OR NEW.`email` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Required password and email for coordinator or supplier';
        END IF;

        IF EXISTS (
            SELECT 1 FROM `Users` 
            WHERE `email` = NEW.`email`
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists for another user';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_users_before_update` BEFORE UPDATE ON `Users`
    FOR EACH ROW
    BEGIN
        IF NEW.`role_name` = 'client' AND NEW.`password` IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'can not insert password for client';
        ELSEIF NEW.`role_name` != 'client' AND (NEW.`password` IS NULL OR NEW.`email` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Required password and email for coordinator or supplier';
        END IF;
        
        IF NEW.`email` != OLD.`email` THEN
            IF EXISTS (SELECT 1 FROM `Users` 
                WHERE `email` = NEW.`email` AND `user_id` != NEW.`user_id`
            ) THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists for another user';
            END IF;
        END IF;
    END $$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER `trg_coordinator_clients_before_insert` BEFORE INSERT ON `Coordinator_Clients`
    FOR EACH ROW 
    BEGIN
        DECLARE v_error_msg TEXT;
        IF NOT EXISTS(
            SELECT 1 FROM `Users` 
            WHERE `email` = NEW.`coordinator_email` AND `role_name` = 'coordinator' AND `deleted_at` IS NULL
        ) THEN
            SET v_error_msg =  CONCAT('لا يمكن أن يكون منشئ العميل إلا منسق ', ' ', NEW.`coordinator_email`);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
        ELSEIF NOT fn_user_has_role(NEW.`client_id`, 'client') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'يجب أن يكون دور الحساب الذي تريد إنشائه هو دور عميل';
        ELSEIF EXISTS(
            SELECT 1 FROM 
                `Coordinator_Clients` WHERE `coordinator_email` = NEW.`coordinator_email` AND 
                `client_id` = NEW.`client_id`
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن إنشاء هذا العميل لقد قمت بإنشائه مسبقا';
        END IF;
    END $$
DELIMITER ;



DELIMITER $$ 
CREATE TRIGGER `trg_supplier_services_before_insert` BEFORE INSERT ON `Supplier_Services`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`supplier_id`, 'supplier') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not a supplier';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_supplier_services_before_update` BEFORE UPDATE ON `Supplier_Services`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`supplier_id`, 'supplier') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not a supplier';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_tasks_before_insert` BEFORE INSERT ON `Tasks`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن إنشاء المهام من قبل غير المنسقين';
        END IF;
        IF NEW.`date_start` IS NOT NULL AND NEW.`date_start` < CURDATE() THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن إنشاء المهام في الماضي';
        END IF;
        IF NEW.`date_due` IS NOT NULL AND NEW.`date_start` IS NOT NULL AND NEW.`date_due` <= NEW.`date_start` THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن أن يكون تاريخ الانتهاء قبل تاريخ البدء';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_tasks_before_update` BEFORE UPDATE ON `Tasks`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تحديث المهام من قبل غير المنسقين';
        END IF;
        IF NEW.`date_start` IS NOT NULL AND NEW.`date_start` < CURDATE() THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تحديث المهام في الماضي';
        END IF;
        IF NEW.`date_due` IS NOT NULL AND NEW.`date_start` IS NOT NULL AND NEW.`date_due` <= NEW.`date_start` THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن أن يكون تاريخ الانتهاء قبل تاريخ البدء';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_task_assigns_before_insert` BEFORE INSERT ON `Task_Assigns`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SET @msg_error = CONCAT('لا يمكن تعيين المهام من قبل غير المنسقين رقم المنسق هو ', IFNULL(NEW.`coordinator_id`, 'NULL'));
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg_error;
        END IF;
        IF NOT (fn_user_has_role(NEW.`user_assign_id`, 'coordinator') OR fn_user_has_role(NEW.`user_assign_id`, 'supplier')) THEN
            SET @msg_error = CONCAT('لا يمكن تعيين المهام لغير المنسقين أو الموردين رقم المستخدم هو ', IFNULL(NEW.`user_assign_id`, 'NULL'));
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg_error;
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_task_assigns_before_update` BEFORE UPDATE ON `Task_Assigns`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SET @msg_error = CONCAT('لا يمكن تحديث تعيين المهام من قبل غير المنسقين رقم المنسق هو ', IFNULL(NEW.`coordinator_id`, 'NULL'));
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg_error;
        END IF;
        IF NOT (fn_user_has_role(NEW.`user_assign_id`, 'coordinator') OR fn_user_has_role(NEW.`user_assign_id`, 'supplier')) THEN
            SET @msg_error = CONCAT('لا يمكن تحديث تعيين المهام لغير المنسقين أو الموردين رقم المستخدم هو ', IFNULL(NEW.`user_assign_id`, 'NULL'));
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg_error;
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_ratings_task_before_insert` BEFORE INSERT ON `Ratings_Task`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rater must be a coordinator';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_ratings_task_before_update` BEFORE UPDATE ON `Ratings_Task`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rater must be a coordinator';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `trg_events_before_insert` BEFORE INSERT ON `Events`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`client_id`, 'client') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Client must have client role';
        END IF;
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coordinator must have coordinator role';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_events_before_update` BEFORE UPDATE ON `Events`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`client_id`, 'client') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Client must have client role';
        END IF;
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coordinator must have coordinator role';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `trg_incomes_before_insert` BEFORE INSERT ON `Incomes`
    FOR EACH ROW
    BEGIN
        IF NEW.`payment_date` > CURDATE() THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'تاريخ الدفع لا يمكن أن يكون في المستقبل.';
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `trg_task_assigns_after_insert` AFTER INSERT ON `Task_Assigns`
    FOR EACH ROW
    BEGIN
        DECLARE v_event_name VARCHAR(255);
        
        SELECT e.`event_name` INTO v_event_name
        FROM `Tasks` t
        JOIN `Events` e ON t.`event_id` = e.`event_id`
        WHERE t.`task_id` = NEW.`task_id`;
        
        INSERT INTO `Notifications` (
            `user_id`, 
            `task_id`, 
            `type`, 
            `title`, 
            `message`
        ) VALUES (
            NEW.`user_assign_id`,
            NEW.`task_assign_id`,
            'TASK_ASSIGNED',
            'مهمة جديدة',
            CONCAT('تم تعيينك لمهمة في حدث "', v_event_name, '"', 
                IF(NEW.`description` IS NOT NULL, CONCAT(': ', NEW.`description`), ''))
        );
    END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `trg_users_before_delete` BEFORE DELETE ON `Users`
    FOR EACH ROW
    BEGIN
        IF EXISTS (SELECT 1 FROM `Events` WHERE `coordinator_id` = OLD.`user_id`) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن حذف مستخدم مرتبط بأحداث كمنسق.';
        END IF;
        
        IF EXISTS (SELECT 1 FROM `Events` WHERE `client_id` = OLD.`user_id`) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن حذف مستخدم مرتبط بأحداث كعميل.';
        END IF;
        
        IF EXISTS (SELECT 1 FROM `Tasks` WHERE `coordinator_id` = OLD.`user_id`) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن حذف مستخدم مرتبط بمهام.';
        END IF;
        
        IF EXISTS (SELECT 1 FROM `Task_Assigns` WHERE `user_assign_id` = OLD.`user_id`) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن حذف مستخدم مرتبط بتعيينات مهام.';
        END IF;
        
        IF EXISTS (SELECT 1 FROM `Ratings_Task` WHERE `coordinator_id` = OLD.`user_id`) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن حذف مستخدم مرتبط بتقييمات.';
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `trg_ratings_before_insert` BEFORE INSERT ON `Ratings_Task`
    FOR EACH ROW
    BEGIN
        DECLARE v_task_status VARCHAR(20);
        
        SELECT t.`status` INTO v_task_status
        FROM `Tasks` t
        JOIN `Task_Assigns` ta ON t.`task_id` = ta.`task_id`
        WHERE ta.`task_assign_id` = NEW.`task_id`;
        
        IF v_task_status != 'COMPLETED' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تقييم مهمة غير مكتملة.';
        END IF;
    END$$
DELIMITER ;

DELIMITER ;





DELIMITER $$
CREATE PROCEDURE `sp_get_all_clintes_for_coordinator`(
    IN `p_coordinator_email` VARCHAR(255)
    )
    BEGIN
        IF NOT EXISTS(
            SELECT 1 FROM Users WHERE email = p_coordinator_email AND role_name = 'coordinator' AND deleted_at IS NULL
        ) THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المنسق غير موجود';
        END IF;
        SELECT valc.* 
            FROM coordinator_clients CoCl 
            JOIN vw_get_all_clients valc 
            WHERE valc.user_id = CoCl.client_id 
            AND CoCl.coordinator_email = p_coordinator_email;
    END $$

DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_home_stats_coordinator`(
    IN `p_coordinator_id` INT
    )
    BEGIN
        SELECT
            (SELECT COUNT(*) FROM `Events` WHERE `deleted_at` IS NULL AND `coordinator_id` = p_coordinator_id) AS total_events,
            (SELECT COUNT(*) FROM `Events` WHERE `status` IN ('PENDING', 'pending') AND `deleted_at` IS NULL AND `coordinator_id` = p_coordinator_id) AS pending_events,
            (SELECT COUNT(*) FROM `Events` WHERE `status` = 'IN_PROGRESS' AND `deleted_at` IS NULL AND `coordinator_id` = p_coordinator_id) AS in_progress_events,
            (SELECT COUNT(*) FROM `Events` WHERE `status` = 'COMPLETED' AND `deleted_at` IS NULL AND `coordinator_id` = p_coordinator_id) AS completed_events,
            (SELECT COUNT(*) FROM `Events` WHERE `status` = 'CANCELLED' AND `deleted_at` IS NULL AND `coordinator_id` = p_coordinator_id) AS cancelled_events,

            (SELECT COUNT(*) FROM `Tasks` WHERE `coordinator_id` = p_coordinator_id) AS total_tasks,
            (SELECT COUNT(*) FROM `Tasks` WHERE `status` = 'PENDING'  AND `coordinator_id` = p_coordinator_id) AS pending_tasks,
            (SELECT COUNT(*) FROM `Tasks` WHERE `status` = 'IN_PROGRESS' AND `coordinator_id` = p_coordinator_id) AS in_progress_tasks,
            (SELECT COUNT(*) FROM `Tasks` WHERE `status` = 'COMPLETED'  AND `coordinator_id` = p_coordinator_id) AS completed_tasks,
            (SELECT COUNT(*) FROM `Tasks` WHERE `status` = 'CANCELLED'  AND `coordinator_id` = p_coordinator_id) AS cancelled_tasks,

            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'client' AND `deleted_at` IS NULL) AS total_clients,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'coordinator' AND `deleted_at` IS NULL) AS total_coordinators,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'supplier' AND `deleted_at` IS NULL) AS total_suppliers;
            
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_get_suppliers_with_coordinator_rating`(
    IN `p_coordinator_id` INT
)
BEGIN
    SELECT 
        `u`.`user_id`,
        `u`.`role_name`,
        `u`.`img_url`,
        `u`.`is_active`,
        (`u`.`deleted_at` IS NOT NULL) AS `is_deleted`,
        `u`.`email`,
        `u`.`password`,
        `u`.`full_name`,
        `u`.`phone_number`,
        `fn_user_get_detail`(`u`.`user_id`,'address') AS `address`,
        `fn_user_get_detail`(`u`.`user_id`,'notes') AS `notes`,
        (
            SELECT ROUND(AVG(r.`value_rating`), 1) 
            FROM `Ratings_Task` r
            JOIN `Task_Assigns` ta ON r.`task_id` = ta.`task_assign_id`
            WHERE ta.`user_assign_id` = u.`user_id` 
              AND r.`coordinator_id` = p_coordinator_id
        ) AS `average_rating`,
        `u`.`created_at`,
        `u`.`updated_at`
    FROM `Users` `u`
    WHERE `u`.`role_name` = 'supplier' AND `u`.`deleted_at` IS NULL;
END$$
DELIMITER ;



-- Added for Supplier Services Proposal
CREATE TABLE IF NOT EXISTS `Service_Requests` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `supplier_id` INT NOT NULL,
  `service_name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `status` ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`supplier_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
