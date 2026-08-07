-- Enable Row Level Security on all tables
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE registration_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE registration_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

-- Helper functions for RLS
CREATE OR REPLACE FUNCTION is_admin() RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_profiles WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_super_admin() RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_profiles WHERE id = auth.uid() AND role = 'super_admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_student() RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM student_profiles WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Departments
-- Everyone can read departments
CREATE POLICY "Departments are viewable by everyone" ON departments FOR SELECT USING (true);
CREATE POLICY "Only super admins can manage departments" ON departments FOR ALL USING (is_super_admin());

-- Student Profiles
-- Students can read/update their own profile
CREATE POLICY "Students can view their own profile" ON student_profiles FOR SELECT USING (auth.uid() = id OR is_admin());
CREATE POLICY "Students can insert their own profile" ON student_profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Students can update their own profile" ON student_profiles FOR UPDATE USING (auth.uid() = id);

-- Admin Profiles
-- Admins can see other admins, super admins can manage all
CREATE POLICY "Admins can view admins" ON admin_profiles FOR SELECT USING (is_admin());
CREATE POLICY "Super admins can manage admins" ON admin_profiles FOR ALL USING (is_super_admin());

-- Events Categories
CREATE POLICY "Categories are viewable by everyone" ON event_categories FOR SELECT USING (true);
CREATE POLICY "Only admins can manage categories" ON event_categories FOR ALL USING (is_admin());

-- Events
-- Students can view published events, admins can view all
CREATE POLICY "Anyone can view published events" ON events FOR SELECT USING (visibility = 'published' OR is_admin());
CREATE POLICY "Admins can manage events" ON events FOR ALL USING (is_admin());

-- Registration Forms & Questions
-- Students can view forms for published events
CREATE POLICY "Anyone can view forms" ON registration_forms FOR SELECT USING (true);
CREATE POLICY "Anyone can view form sections" ON form_sections FOR SELECT USING (true);
CREATE POLICY "Anyone can view form questions" ON form_questions FOR SELECT USING (true);
CREATE POLICY "Anyone can view question options" ON question_options FOR SELECT USING (true);
-- Admins can manage forms
CREATE POLICY "Admins can manage forms" ON registration_forms FOR ALL USING (is_admin());
CREATE POLICY "Admins can manage form sections" ON form_sections FOR ALL USING (is_admin());
CREATE POLICY "Admins can manage form questions" ON form_questions FOR ALL USING (is_admin());
CREATE POLICY "Admins can manage question options" ON question_options FOR ALL USING (is_admin());

-- Registrations
-- Students can view their own registrations. Admins can view all.
CREATE POLICY "Students can view their own registrations" ON registrations FOR SELECT USING (auth.uid() = student_id OR is_admin());
CREATE POLICY "Students can create registrations" ON registrations FOR INSERT WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Admins can manage registrations" ON registrations FOR ALL USING (is_admin());

-- Registration Answers
CREATE POLICY "Students can view/insert their own answers" ON registration_answers FOR ALL USING (
    EXISTS (SELECT 1 FROM registrations WHERE id = registration_id AND student_id = auth.uid()) OR is_admin()
);

-- Attendance
CREATE POLICY "Students can view their own attendance" ON attendance FOR SELECT USING (auth.uid() = student_id OR is_admin());
CREATE POLICY "Admins can manage attendance" ON attendance FOR ALL USING (is_admin());

-- Certificates
CREATE POLICY "Students can view their own certificates" ON certificates FOR SELECT USING (auth.uid() = student_id OR is_admin());
-- Public verification policy (using a stored procedure or edge function is better, but this allows direct read if needed)
CREATE POLICY "Anyone can verify certificates" ON certificates FOR SELECT USING (true); 
CREATE POLICY "Admins can manage certificates" ON certificates FOR ALL USING (is_admin());

-- Announcements
CREATE POLICY "Anyone can view announcements" ON announcements FOR SELECT USING (true);
CREATE POLICY "Admins can manage announcements" ON announcements FOR ALL USING (is_admin());
