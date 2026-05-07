USE my_party_3;

-- ============================================================
-- 1. إضافة مستخدمين إضافيين (30+ في المجموع)
-- ============================================================

-- لدينا بالفعل:
-- admin: 1
-- coordinators: 2, (جدد من كود سابق) 11,12? سنعتمد على count
-- suppliers: 3,4,5,6, (جدد من كود سابق) 13,14,15?
-- clients: 7,8,9,10, (جدد) 16,17,18?

-- سنضيف 20 منسقًا إضافيًا، 20 موردًا، 20 عميلاً (للتأكد من العدد)
-- استخدام إجراء مؤقت أو حلقة، لكن هنا سنستخدم INSERT مع SELECT من جدول مؤقت

-- إنشاء جدول مؤقت للأسماء
DROP TEMPORARY TABLE IF EXISTS temp_names;
CREATE TEMPORARY TABLE temp_names (full_name VARCHAR(255));

INSERT INTO temp_names (full_name) VALUES
('أحمد محمد علي'), ('فاطمة عبدالله حسن'), ('علي صالح أحمد'), ('زينب ناصر علي'), ('محمد حسين إبراهيم'),
('نورة عبدالرحمن سعيد'), ('عبدالله عمر خالد'), ('منى طارق محمد'), ('خالد سعيد عبدالله'), ('سارة أحمد محمد'),
('ياسر محمود عبدالله'), ('لمى محمد رشاد'), ('أمجد عبدالله ناصر'), ('هناء علي يحيى'), ('نبيل صالح عبدالله'),
('رنا أحمد عبدالله'), ('طارق محمد عبدالله'), ('هيفاء علي عبدالله'), ('فهد محمد سعيد'), ('ريما خالد علي'),
('عمار محمد عبدالله'), ('شيماء عبدالله علي'), ('مصعب محمد عبدالله'), ('إيمان علي محمد'), ('سامر خالد عبدالله'),
('دينا محمد علي'), ('عاصم عبدالله ناصر'), ('هبة الله محمد'), ('ليث محمد عبدالله'), ('رغد خالد علي');

-- إضافة منسقين (role_name = coordinator)
INSERT INTO Users (role_name, full_name, phone_number, img_url, email, password, is_active)
SELECT 'coordinator', 
       full_name, 
       CONCAT('77', LPAD(FLOOR(RAND() * 10000000), 7, '0')) AS phone,
       CONCAT('https://i.pravatar.cc/150?u=coord_', RAND()) AS img_url,
       CONCAT(LOWER(REPLACE(full_name, ' ', '.')), '@myparty.com') AS email,
       '123456' AS password,
       IF(RAND() > 0.2, 1, 0) AS is_active
FROM temp_names
WHERE NOT EXISTS (SELECT 1 FROM Users WHERE role_name = 'coordinator' LIMIT 1) -- لتجنب التكرار
LIMIT 20;

-- إضافة موردين (role_name = supplier)
INSERT INTO Users (role_name, full_name, phone_number, img_url, email, password, is_active)
SELECT 'supplier', 
       full_name, 
       CONCAT('77', LPAD(FLOOR(RAND() * 10000000), 7, '0')) AS phone,
       CONCAT('https://i.pravatar.cc/150?u=supp_', RAND()) AS img_url,
       CONCAT(LOWER(REPLACE(full_name, ' ', '.')), '@supplier.com') AS email,
       '123456' AS password,
       IF(RAND() > 0.2, 1, 0) AS is_active
FROM temp_names
LIMIT 20;

-- إضافة عملاء (role_name = client)
INSERT INTO Users (role_name, full_name, phone_number, img_url, email, is_active)
SELECT 'client', 
       full_name, 
       CONCAT('77', LPAD(FLOOR(RAND() * 10000000), 7, '0')) AS phone,
       CONCAT('https://i.pravatar.cc/150?u=client_', RAND()) AS img_url,
       CONCAT(LOWER(REPLACE(full_name, ' ', '.')), '@client.com') AS email,
       IF(RAND() > 0.2, 1, 0) AS is_active
FROM temp_names
LIMIT 20;

DROP TEMPORARY TABLE temp_names;

-- الآن لدينا عدد كبير من المستخدمين (احسبهم لاحقًا)

-- ============================================================
-- 2. إضافة تفاصيل للمستخدمين الجدد (عنوان، ملاحظات)
-- ============================================================

-- للمنسقين والموردين والعملاء الجدد، نضيف عنوانًا عشوائيًا
-- نستخدم جدول مؤقت للعناوين
DROP TEMPORARY TABLE IF EXISTS temp_addresses;
CREATE TEMPORARY TABLE temp_addresses (addr VARCHAR(255));
INSERT INTO temp_addresses (addr) VALUES
('صنعاء - حدة'), ('عدن - خور مكسر'), ('تعز - صالة'), ('إب - مدينة إب'), ('الحديدة - المنظر'),
('المكلا'), ('سيئون'), ('ذمار'), ('عمران'), ('صعدة');

-- إضافة عنوان لكل مستخدم جديد (لمن ليس له عنوان بعد)
INSERT INTO User_Detail_Values (user_id, role_name, detail_name, detail_value)
SELECT u.user_id, u.role_name, 'address', 
       (SELECT addr FROM temp_addresses ORDER BY RAND() LIMIT 1)
FROM Users u
WHERE u.role_name IN ('coordinator', 'supplier', 'client')
  AND NOT EXISTS (SELECT 1 FROM User_Detail_Values ud WHERE ud.user_id = u.user_id AND ud.detail_name = 'address')
LIMIT 100;

-- إضافة ملاحظات للموردين الجدد (notes)
INSERT INTO User_Detail_Values (user_id, role_name, detail_name, detail_value)
SELECT u.user_id, u.role_name, 'notes', 
       CONCAT('ملاحظة رقم ', FLOOR(RAND()*1000))
FROM Users u
WHERE u.role_name = 'supplier'
  AND NOT EXISTS (SELECT 1 FROM User_Detail_Values ud WHERE ud.user_id = u.user_id AND ud.detail_name = 'notes')
LIMIT 30;

DROP TEMPORARY TABLE temp_addresses;

-- ============================================================
-- 3. إضافة خدمات إضافية (إذا لزم الأمر)
-- ============================================================

-- لدينا بالفعل 10 خدمات. سنضيف 20 خدمة أخرى ليصبح العدد 30+
INSERT INTO Services (service_name, description)
SELECT CONCAT('خدمة ', n), CONCAT('وصف الخدمة رقم ', n)
FROM (
    SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
) nums
WHERE NOT EXISTS (SELECT 1 FROM Services LIMIT 1)
LIMIT 20;

-- ============================================================
-- 4. ربط الموردين بالخدمات (30+ سجل)
-- ============================================================

-- لكل مورد، نربطه بعدد من الخدمات (1-5 خدمات)
-- نستخدم إجراء مؤقت لتوليد ارتباطات
DROP TEMPORARY TABLE IF EXISTS temp_suppliers;
CREATE TEMPORARY TABLE temp_suppliers (supplier_id INT);
INSERT INTO temp_suppliers SELECT user_id FROM Users WHERE role_name = 'supplier';

-- لكل مورد نضيف 2-5 خدمات عشوائية
-- سنستخدم حلقة بسيطة عبر INSERT SELECT مع RAND
-- نستخدم INSERT IGNORE لتجنب التكرار
INSERT IGNORE INTO Supplier_Services (supplier_id, service_id)
SELECT s.supplier_id, sv.service_id
FROM temp_suppliers s
CROSS JOIN (SELECT service_id FROM Services) sv
WHERE RAND() < 0.3   -- احتمالية 30% لإضافة الخدمة
  AND NOT EXISTS (SELECT 1 FROM Supplier_Services WHERE supplier_id = s.supplier_id AND service_id = sv.service_id)
LIMIT 500;   -- سيتم إضافة عدد كبير، لكن IGNORE سيمنع التكرار

DROP TEMPORARY TABLE temp_suppliers;

-- ============================================================
-- 5. إضافة أحداث كثيرة (30+)
-- ============================================================

-- نحتاج عملاء ومنسقين متاحين
SET @clients_list = (SELECT GROUP_CONCAT(user_id) FROM Users WHERE role_name = 'client' AND deleted_at IS NULL);
SET @coordinators_list = (SELECT GROUP_CONCAT(user_id) FROM Users WHERE role_name = 'coordinator' AND deleted_at IS NULL);

-- أحداث عشوائية
DROP TEMPORARY TABLE IF EXISTS temp_events;
CREATE TEMPORARY TABLE temp_events (event_name VARCHAR(255), description TEXT, location VARCHAR(255), budget DECIMAL(10,2), event_date DATE, status ENUM('PENDING','IN_PROGRESS','COMPLETED','CANCELLED'));
INSERT INTO temp_events (event_name, description, location, budget, event_date, status) VALUES
('حفل زفاف', 'حفل زفاف', 'صالة أروى', 2000, '2026-05-20', 'PENDING'),
('حفل تخرج', 'تخرج الجامعة', 'قاعة المؤتمرات', 1500, '2026-06-01', 'IN_PROGRESS'),
('مؤتمر تقني', 'مؤتمر الذكاء الاصطناعي', 'فندق موفنبيك', 5000, '2026-07-10', 'PENDING'),
('معرض فني', 'معرض تشكيلي', 'جاليري الفن', 800, '2026-05-15', 'COMPLETED'),
('ندوة صحية', 'التغذية السليمة', 'مركز المجتمع', 300, '2026-04-25', 'CANCELLED'),
('حفل عشاء', 'عشاء عمل', 'مطعم الفردوس', 1000, '2026-06-05', 'PENDING'),
('مهرجان موسيقي', 'حفل غنائي', 'المسرح الروماني', 3000, '2026-08-01', 'PENDING'),
('دورة تدريبية', 'دورة فوتوشوب', 'مركز تدريب', 500, '2026-05-10', 'COMPLETED'),
('افتتاح مشروع', 'افتتاح شركة', 'مقر الشركة', 2000, '2026-06-20', 'IN_PROGRESS'),
('حفلة عيد ميلاد', 'عيد ميلاد 30', 'منزل العائلة', 400, '2026-05-25', 'PENDING'),
('مسابقة رياضية', 'ماراثون', 'شارع الرئيسي', 1000, '2026-07-15', 'PENDING'),
('معرض كتاب', 'معرض الكتاب السنوي', 'قاعة المعارض', 1200, '2026-06-10', 'PENDING'),
('حفل خطوبة', 'حفل خطوبة', 'صالة الزفاف', 800, '2026-05-30', 'IN_PROGRESS'),
('مؤتمر طبي', 'مؤتمر الجراحة', 'فندق هوليدي إن', 4000, '2026-09-05', 'PENDING'),
('عرض أزياء', 'عرض أزياء خيري', 'فندق ماريوت', 1500, '2026-07-20', 'PENDING'),
('حفل عشاء خيري', 'جمع تبرعات', 'قاعة المؤتمرات', 2500, '2026-08-15', 'PENDING'),
('ندوة دينية', 'محاضرة إيمانية', 'مسجد النور', 200, '2026-05-05', 'COMPLETED'),
('حفلة موسيقية', 'فرقة محلية', 'المسرح الصيفي', 700, '2026-06-25', 'PENDING'),
('مهرجان طعام', 'مهرجان الأكلات الشعبية', 'حديقة السبعين', 1200, '2026-07-30', 'PENDING'),
('ورشة عمل', 'ريادة الأعمال', 'مركز الابتكار', 600, '2026-06-12', 'PENDING'),
('حفل زفاف', 'زفاف عائلي', 'صالة النخبة', 1800, '2026-05-28', 'IN_PROGRESS'),
('تخرج مدرسي', 'حفل تخرج طلاب', 'قاعة المدرسة', 500, '2026-06-02', 'PENDING'),
('مهرجان ثقافي', 'فعاليات ثقافية', 'مكتبة البلدية', 400, '2026-07-18', 'PENDING'),
('عرض مسرحي', 'مسرحية كوميدية', 'المسرح القومي', 800, '2026-08-22', 'PENDING'),
('مؤتمر استثماري', 'فرص استثمارية', 'فندق شيراتون', 3500, '2026-09-10', 'PENDING'),
('حفلة أطفال', 'يوم المرح', 'مدينة الملاهي', 600, '2026-06-18', 'PENDING'),
('معرض تكنولوجيا', 'أحدث الابتكارات', 'مركز المعارض', 2000, '2026-07-25', 'PENDING'),
('دورة برمجة', 'Flutter و Dart', 'أونلاين', 300, '2026-05-20', 'COMPLETED'),
('جلسة تصوير', 'جلسة تصوير عائلية', 'استوديو', 250, '2026-05-12', 'COMPLETED'),
('رحلة ترفيهية', 'رحلة إلى الشاطئ', 'الشاطئ', 1500, '2026-07-05', 'PENDING');

-- الآن نقوم بإدخال الأحداث الفعلية مع اختيار عشوائي للعملاء والمنسقين
-- سنحصل على عدد كبير من الأحداث (30+)
INSERT INTO Events (event_name, description, location, budget, event_date, client_id, coordinator_id, status)
SELECT 
    e.event_name,
    e.description,
    e.location,
    e.budget,
    e.event_date,
    (SELECT user_id FROM Users WHERE role_name = 'client' ORDER BY RAND() LIMIT 1) AS client_id,
    (SELECT user_id FROM Users WHERE role_name = 'coordinator' ORDER BY RAND() LIMIT 1) AS coordinator_id,
    e.status
FROM temp_events e
WHERE NOT EXISTS (SELECT 1 FROM Events LIMIT 1) -- فقط للتأكد من عدم التكرار
LIMIT 30;

DROP TEMPORARY TABLE temp_events;

-- الآن لدينا أكثر من 30 حدثًا (الموجودين سابقًا + الجدد). سنقوم بحساب العدد لاحقًا.

-- ============================================================
-- 6. إضافة مهام كثيرة (لكل حدث عدة مهام) لضمان 30+
-- ============================================================

-- سنضيف لكل حدث من 2 إلى 5 مهام، بأنواع متنوعة وحالات عشوائية
-- نستخدم جدول مؤقت بأنواع المهام
DROP TEMPORARY TABLE IF EXISTS temp_task_types;
CREATE TEMPORARY TABLE temp_task_types (type_task VARCHAR(255));
INSERT INTO temp_task_types (type_task) VALUES
('تأمين قاعة'), ('تجهيز ديكور'), ('تنسيق الزهور'), ('تصوير وفيديو'), ('تجهيز الصوتيات'),
('توفير وجبات'), ('تنسيق الإضاءة'), ('تأمين نقل'), ('طباعة دعوات'), ('تنظيف الموقع'),
('استقبال الضيوف'), ('تجهيز الكوشة'), ('توفير هدايا'), ('تأمين الأمن'), ('تسجيل الحضور');

-- نقوم بإدخال مهام لكل حدث موجود (جميع الأحداث)
-- نستخدم إجراء مخزن مؤقت لتوليد المهام بكمية كافية
-- هنا سنقوم بإدخال مهام باستخدام CROSS JOIN مع الحدث ونوع المهمة مع احتمالية
INSERT INTO Tasks (event_id, coordinator_id, status, type_task, date_start, date_due)
SELECT 
    e.event_id,
    e.coordinator_id,
    CASE FLOOR(1 + RAND()*5)
        WHEN 1 THEN 'PENDING'
        WHEN 2 THEN 'IN_PROGRESS'
        WHEN 3 THEN 'COMPLETED'
        WHEN 4 THEN 'UNDER_REVIEW'
        ELSE 'CANCELLED'
    END AS status,
    tt.type_task,
    DATE_ADD(e.event_date, INTERVAL -FLOOR(1 + RAND()*10) DAY) AS date_start,
    DATE_ADD(e.event_date, INTERVAL -FLOOR(RAND()*5) DAY) AS date_due
FROM Events e
CROSS JOIN temp_task_types tt
WHERE RAND() < 0.4   -- احتمالية 40% لكل حدث ونوع مهمة لإضافة مهمة (سيولد عدد كبير من المهام)
  AND NOT EXISTS (SELECT 1 FROM Tasks WHERE event_id = e.event_id AND type_task = tt.type_task)
LIMIT 500;   -- سنحد العدد ليكون كافيًا

DROP TEMPORARY TABLE temp_task_types;

-- بعد هذه الإضافة، سيكون لدينا عدد كبير من المهام (يمكن أن يتجاوز 1000)

-- ============================================================
-- 7. تعيين المهام (Task_Assigns) لكل مهمة
-- ============================================================

-- لكل مهمة نقوم بتعيينها لمورد أو منسق (يجب أن يكون المستخدم المعين من دور مناسب)
-- نستخدم جدول مؤقت للمستخدمين المؤهلين (منسقين وموردين)
DROP TEMPORARY TABLE IF EXISTS temp_assignable_users;
CREATE TEMPORARY TABLE temp_assignable_users (user_id INT);
INSERT INTO temp_assignable_users SELECT user_id FROM Users WHERE role_name IN ('coordinator', 'supplier') AND deleted_at IS NULL AND is_active = 1;

-- نقوم بتعيين كل مهمة لشخص من القائمة أعلاه بشكل عشوائي، مع تكلفة عشوائية وملاحظات
-- سنقوم بإدخال تعيين لكل مهمة (لأن Task_Assigns يجب أن يكون لكل مهمة على الأقل تعيين واحد)
-- ولكن هناك احتمال أن تكون المهمة قد تم تعيينها بالفعل (في الكود السابق) لذا سنستخدم IGNORE
INSERT IGNORE INTO Task_Assigns (task_id, coordinator_id, user_assign_id, description, cost, notes, url_image, reminder_type, reminder_value, reminder_unit)
SELECT 
    t.task_id,
    t.coordinator_id,
    (SELECT user_id FROM temp_assignable_users ORDER BY RAND() LIMIT 1) AS assign_user,
    CONCAT('تعيين لمهمة: ', t.type_task) AS description,
    ROUND(100 + RAND() * 2000, 2) AS cost,
    CASE WHEN RAND() > 0.7 THEN 'ملاحظة خاصة' ELSE NULL END AS notes,
    CASE WHEN RAND() > 0.8 THEN 'https://example.com/task_image.jpg' ELSE NULL END AS url_image,
    CASE FLOOR(1 + RAND()*2) WHEN 1 THEN 'INTERVAL' WHEN 2 THEN 'BEFORE_DUE' END AS reminder_type,
    FLOOR(1 + RAND()*30) AS reminder_value,
    CASE FLOOR(1 + RAND()*3) WHEN 1 THEN 'MINUTE' WHEN 2 THEN 'HOUR' ELSE 'DAY' END AS reminder_unit
FROM Tasks t
WHERE NOT EXISTS (SELECT 1 FROM Task_Assigns WHERE task_id = t.task_id)
LIMIT 500;

DROP TEMPORARY TABLE temp_assignable_users;

-- ============================================================
-- 8. إضافة تقييمات للمهام المكتملة (30+)
-- ============================================================

-- نقوم بإضافة تقييمات للمهام التي حالتها COMPLETED في Tasks
-- نحتاج إلى task_assign_id لكل مهمة مكتملة
INSERT INTO Ratings_Task (task_id, coordinator_id, value_rating, comment, rated_at)
SELECT 
    ta.task_assign_id,
    t.coordinator_id,
    FLOOR(1 + RAND()*5) AS rating,
    CASE FLOOR(1 + RAND()*4)
        WHEN 1 THEN 'عمل ممتاز'
        WHEN 2 THEN 'جيد جداً'
        WHEN 3 THEN 'مرضٍ'
        WHEN 4 THEN 'يحتاج تحسين'
    END AS comment,
    NOW() - INTERVAL FLOOR(RAND()*30) DAY AS rated_at
FROM Tasks t
JOIN Task_Assigns ta ON t.task_id = ta.task_id
WHERE t.status = 'COMPLETED'
  AND NOT EXISTS (SELECT 1 FROM Ratings_Task r WHERE r.task_id = ta.task_assign_id)
LIMIT 50;  -- على الأقل 50 تقييمًا

-- ============================================================
-- 9. إضافة إشعارات كثيرة (30+)
-- ============================================================

-- نضيف إشعارات عشوائية للمستخدمين حول مهام وأحداث
INSERT INTO Notifications (user_id, task_id, type, title, message, is_read)
SELECT 
    u.user_id,
    NULL AS task_id,
    'SYSTEM',
    'تحديث النظام',
    CONCAT('مرحباً ', u.full_name, '، تم تحديث النظام بإضافة ميزات جديدة.'),
    IF(RAND() > 0.3, 1, 0) AS is_read
FROM Users u
WHERE u.deleted_at IS NULL
  AND u.user_id NOT IN (SELECT user_id FROM Notifications WHERE type = 'SYSTEM')
LIMIT 50;

-- إشعارات متعلقة بتعيين مهام (لكل Task_Assigns)
INSERT INTO Notifications (user_id, task_id, type, title, message, is_read)
SELECT 
    ta.user_assign_id,
    ta.task_assign_id,
    'TASK_ASSIGNED',
    'تم تعيين مهمة جديدة',
    CONCAT('تم تعيين مهمة: ', t.type_task, ' في حدث ', e.event_name),
    0
FROM Task_Assigns ta
JOIN Tasks t ON ta.task_id = t.task_id
JOIN Events e ON t.event_id = e.event_id
WHERE NOT EXISTS (SELECT 1 FROM Notifications n WHERE n.task_id = ta.task_assign_id)
LIMIT 100;

-- إشعارات حول تغيير حالة الحدث
INSERT INTO Notifications (user_id, task_id, type, title, message, is_read)
SELECT 
    e.client_id,
    NULL,
    'EVENT_STATUS',
    'تغيير حالة الحدث',
    CONCAT('الحدث ', e.event_name, ' تغيرت حالته إلى ', e.status),
    0
FROM Events e
WHERE NOT EXISTS (SELECT 1 FROM Notifications n WHERE n.user_id = e.client_id AND n.type = 'EVENT_STATUS' AND n.created_at > DATE_SUB(NOW(), INTERVAL 1 DAY))
LIMIT 50;

-- ============================================================
-- 10. إضافة إيرادات للأحداث (30+)
-- ============================================================

-- نضيف إيرادات لكل حدث بقيمة عشوائية وطريقة دفع متنوعة
INSERT INTO Incomes (event_id, amount, payment_method, payment_date, description, url_image)
SELECT 
    e.event_id,
    ROUND(500 + RAND() * 5000, 2) AS amount,
    CASE FLOOR(1 + RAND()*4)
        WHEN 1 THEN 'نقدي'
        WHEN 2 THEN 'تحويل بنكي'
        WHEN 3 THEN 'شيك'
        ELSE 'بطاقة ائتمان'
    END AS payment_method,
    DATE_ADD(e.event_date, INTERVAL -FLOOR(RAND()*30) DAY) AS payment_date,
    CONCAT('دفعة للحدث ', e.event_name) AS description,
    CASE WHEN RAND() > 0.8 THEN 'https://example.com/receipt.jpg' ELSE NULL END AS url_image
FROM Events e
WHERE NOT EXISTS (SELECT 1 FROM Incomes i WHERE i.event_id = e.event_id)
LIMIT 50;

-- -----------------------------------------------------------------
-- التحقق من عدد السجلات (اختياري)
-- -----------------------------------------------------------------
SELECT 'Users' AS TableName, COUNT(*) AS RecordCount FROM Users
UNION ALL
SELECT 'User_Detail_Values', COUNT(*) FROM User_Detail_Values
UNION ALL
SELECT 'Events', COUNT(*) FROM Events
UNION ALL
SELECT 'Services', COUNT(*) FROM Services
UNION ALL
SELECT 'Supplier_Services', COUNT(*) FROM Supplier_Services
UNION ALL
SELECT 'Tasks', COUNT(*) FROM Tasks
UNION ALL
SELECT 'Task_Assigns', COUNT(*) FROM Task_Assigns
UNION ALL
SELECT 'Ratings_Task', COUNT(*) FROM Ratings_Task
UNION ALL
SELECT 'Notifications', COUNT(*) FROM Notifications
UNION ALL
SELECT 'Incomes', COUNT(*) FROM Incomes;

-- ============================================================
-- انتهى كود التعبئة
-- ============================================================

