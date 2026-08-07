-- Seed Departments
INSERT INTO departments (id, name, code) VALUES 
('d0000000-0000-0000-0000-000000000001', 'Computer Science', 'CS'),
('d0000000-0000-0000-0000-000000000002', 'Information Technology', 'IT'),
('d0000000-0000-0000-0000-000000000003', 'Mechanical Engineering', 'ME'),
('d0000000-0000-0000-0000-000000000004', 'Civil Engineering', 'CE')
ON CONFLICT (name) DO NOTHING;

-- Seed Event Categories
INSERT INTO event_categories (id, name, description) VALUES
('c0000000-0000-0000-0000-000000000001', 'Technical', 'Hackathons, coding challenges, tech talks.'),
('c0000000-0000-0000-0000-000000000002', 'Cultural', 'Dance, music, drama, and art events.'),
('c0000000-0000-0000-0000-000000000003', 'Sports', 'Outdoor and indoor games.')
ON CONFLICT (name) DO NOTHING;

-- Seed an Event
INSERT INTO events (id, title, short_description, long_description, department_id, category_id, start_date, end_date, visibility)
VALUES (
    'e0000000-0000-0000-0000-000000000001',
    'Tech Innovators Hackathon 2026',
    'A 24-hour hackathon to build innovative solutions for the future.',
    'Join us for the most exciting hackathon of the year. Build apps, solve problems, and win prizes!',
    'd0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    NOW() + INTERVAL '7 days',
    NOW() + INTERVAL '8 days',
    'published'
) ON CONFLICT (id) DO NOTHING;

-- Seed a Dynamic Registration Form for the event
INSERT INTO registration_forms (id, event_id, auto_approval) 
VALUES ('f0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Seed Form Sections
INSERT INTO form_sections (id, form_id, title, order_index)
VALUES 
('a0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 'Team Information', 1),
('a0000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000001', 'Technical Skills', 2)
ON CONFLICT (id) DO NOTHING;

-- Seed Form Questions
INSERT INTO form_questions (id, section_id, question_type, title, is_required, order_index)
VALUES 
('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'short_answer', 'Team Name', TRUE, 1),
('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'number', 'Number of Members (1-4)', TRUE, 2),
('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000002', 'dropdown', 'Primary Tech Stack', TRUE, 3),
('b0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000002', 'yes_no', 'Do you need accommodation?', FALSE, 4)
ON CONFLICT (id) DO NOTHING;

-- Seed Dropdown Options
INSERT INTO question_options (id, question_id, value, label, order_index)
VALUES 
('10000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000003', 'flutter', 'Flutter/Dart', 1),
('10000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000003', 'react', 'React/Node', 2),
('10000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000003', 'python', 'Python/Django', 3)
ON CONFLICT (id) DO NOTHING;
