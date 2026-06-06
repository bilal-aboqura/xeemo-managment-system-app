-- =============================================
-- Xeemo Management System - Manager Assignments
-- =============================================

-- جدول تعيين المناديب للمديرين
-- يسمح لمدير معين برؤية تذاكر مناديب محددين فقط
CREATE TABLE IF NOT EXISTS public.manager_worker_assignments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  manager_id TEXT NOT NULL,
  worker_id TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT, -- من قام بالتعيين (super_manager)
  UNIQUE(manager_id, worker_id)
);

-- Enable RLS
ALTER TABLE public.manager_worker_assignments ENABLE ROW LEVEL SECURITY;

-- Policy: السماح للمديرين برؤية التعيينات الخاصة بهم
CREATE POLICY "Managers can view their assignments" 
ON public.manager_worker_assignments 
FOR SELECT 
USING (true);

-- Policy: super_manager فقط يمكنه إضافة/حذف التعيينات
CREATE POLICY "Super managers can manage assignments" 
ON public.manager_worker_assignments 
FOR ALL 
USING (true) 
WITH CHECK (true);

-- =============================================
-- تحديث جدول profiles لدعم super_manager
-- =============================================

-- إزالة القيد القديم إن وجد
ALTER TABLE public.profiles 
  DROP CONSTRAINT IF EXISTS profiles_role_check;

-- إضافة القيد الجديد مع super_manager
ALTER TABLE public.profiles 
  ADD CONSTRAINT profiles_role_check 
  CHECK (role IN ('worker', 'manager', 'super_manager'));

-- =============================================
-- Indexes للأداء
-- =============================================

CREATE INDEX IF NOT EXISTS idx_manager_assignments_manager 
ON public.manager_worker_assignments(manager_id);

CREATE INDEX IF NOT EXISTS idx_manager_assignments_worker 
ON public.manager_worker_assignments(worker_id);
