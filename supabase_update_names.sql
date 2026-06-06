-- ============================================================
-- SQL Script to Update User Names in public.profiles table
-- Run this in the Supabase SQL Editor
-- ============================================================

-- 1. Update/Insert 'ahmedtaye3@xeemo-eg.com'
INSERT INTO public.profiles (user_id, email, name, role)
SELECT id, email, 'أحمد طايع', 'worker'
FROM auth.users
WHERE email = 'ahmedtaye3@xeemo-eg.com'
ON CONFLICT (user_id) DO UPDATE
SET name = 'أحمد طايع', role = 'worker';

-- 2. Update/Insert 'ahmedyamna@xeemo-eg.com'
INSERT INTO public.profiles (user_id, email, name, role)
SELECT id, email, 'أحمد اليمنى', 'worker'
FROM auth.users
WHERE email = 'ahmedyamna@xeemo-eg.com'
ON CONFLICT (user_id) DO UPDATE
SET name = 'أحمد اليمنى', role = 'worker';

-- 3. Update/Insert 'khaledgamal@xeemo-eg.com'
INSERT INTO public.profiles (user_id, email, name, role)
SELECT id, email, 'خالد جمال', 'worker'
FROM auth.users
WHERE email = 'khaledgamal@xeemo-eg.com'
ON CONFLICT (user_id) DO UPDATE
SET name = 'خالد جمال', role = 'worker';

-- 4. Update/Insert 'manager@xeemo-eg.com'
INSERT INTO public.profiles (user_id, email, name, role)
SELECT id, email, 'المدير العام', 'manager'
FROM auth.users
WHERE email = 'manager@xeemo-eg.com'
ON CONFLICT (user_id) DO UPDATE
SET name = 'المدير العام', role = 'manager';


-- ============================================================
-- OPTIONAL: Create Trigger to Automatically Create Profiles
-- This ensures future users automatically get a profile
-- ============================================================

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (user_id, email, name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    SPLIT_PART(NEW.email, '@', 1), -- Default name is username part of email
    'worker' -- Default role
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
