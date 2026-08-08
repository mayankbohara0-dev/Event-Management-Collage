-- =====================================================================
-- SEED: DEMO EVENTS  (Run this in Supabase SQL Editor)
-- Deletes all events and re-seeds with 6 realistic college events.
-- =====================================================================

-- 1. CLEAN SLATE
DELETE FROM events;

-- 2. ENSURE CATEGORIES EXIST
INSERT INTO event_categories (name, description) VALUES
  ('Hackathon',    'Coding and innovation competitions'),
  ('Cultural',     'Arts, music, dance and cultural fests'),
  ('Seminar',      'Guest lectures and professional talks'),
  ('Workshop',     'Hands-on skill-building sessions'),
  ('Sports',       'Athletic and outdoor competitions'),
  ('Competition',  'Academic and creative contests')
ON CONFLICT (name) DO NOTHING;

-- =====================================================================
-- EVENT 1: TechNova Hackathon 2026 (Hackathon)
-- =====================================================================
DO $$
DECLARE
  cat_id UUID; evt_id UUID; frm_id UUID; sec1_id UUID; sec2_id UUID; sec3_id UUID;
  q1_id UUID; q2_id UUID; q3_id UUID; q4_id UUID; q5_id UUID; q6_id UUID; q7_id UUID; q8_id UUID;
BEGIN
  SELECT id INTO cat_id FROM event_categories WHERE name = 'Hackathon' LIMIT 1;
  INSERT INTO events (
    title, short_description, long_description,
    venue, eligibility, category_id,
    start_date, end_date,
    prize_details, coordinator, faculty_in_charge, contact_number,
    rules, requirements, max_seats, visibility, cover_image_url, tags
  ) VALUES (
    'TechNova 2026 — 36-Hour National Hackathon',
    'Build. Break. Innovate. Join 200+ teams competing for Rs.2 Lakh in prizes.',
    'TechNova is our flagship annual hackathon — a grueling 36-hour sprint.' || chr(10) || chr(10) ||
    'PRIZE POOL: Rs.2,00,000' || chr(10) ||
    '  1st Place: Rs.80,000 + Internship fast-track' || chr(10) ||
    '  2nd Place: Rs.50,000' || chr(10) ||
    '  3rd Place: Rs.30,000' || chr(10) ||
    '  Best UI/UX: Rs.20,000' || chr(10) ||
    '  Best Social Impact: Rs.20,000' || chr(10) || chr(10) ||
    'THEMES: Smart Cities | HealthTech | FinTech | AI/ML | Open Innovation' || chr(10) || chr(10) ||
    'Free food, beverages, energy drinks, and midnight snacks provided throughout.' || chr(10) ||
    'Mentors from Google, Microsoft, and top startups will be available for guidance.' || chr(10) || chr(10) ||
    'Register as a team of 2-4 members. Solo registrations are also accepted.',
    'Innovation Hub, Block D, Ground Floor',
    'Open to all undergraduate and postgraduate students (2nd year and above). Team size: 1-4 members.',
    cat_id,
    NOW() + INTERVAL '18 days',
    NOW() + INTERVAL '19 days 12 hours',
    '1st: Rs.80,000 | 2nd: Rs.50,000 | 3rd: Rs.30,000 | Best UI/UX: Rs.20,000 | Best Social Impact: Rs.20,000',
    'Rohan Mehta (CSE Dept)',
    'Dr. Priya Sharma',
    '+91-98765-43210',
    'Teams must consist of 1-4 members.' || chr(10) ||
    'All code must be written during the hackathon.' || chr(10) ||
    'Projects must be submitted via GitHub with a public repository.' || chr(10) ||
    'Each team gets a 5-minute demo slot before judges.' || chr(10) ||
    'Use of AI coding tools is permitted but must be disclosed.' || chr(10) ||
    'Plagiarism or copied work will lead to immediate disqualification.' || chr(10) ||
    'Participants must carry their college ID cards.',
    'Laptop (mandatory)' || chr(10) ||
    'Phone charger and power bank (recommended)' || chr(10) ||
    'Development environment set up beforehand' || chr(10) ||
    'GitHub account',
    240, 'published',
    'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=80&fit=crop',
    ARRAY['hackathon', 'coding', 'innovation', 'prizes', 'teams']
  ) RETURNING id INTO evt_id;

  INSERT INTO registration_forms (event_id, confirmation_message, auto_approval, max_responses, one_response_only)
  VALUES (evt_id,
    'You are registered for TechNova 2026! Check your email for the Discord invite link. See you there!',
    TRUE, 240, TRUE)
  RETURNING id INTO frm_id;

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Team Information', 'Tell us about your team. If you are solo, just fill in your own details.', 0)
  RETURNING id INTO sec1_id;

  INSERT INTO form_questions (section_id, question_type, title, description, is_required, placeholder, order_index)
  VALUES (sec1_id, 'short_answer', 'Team Name', 'Pick a cool name! (E.g. "404 Found")', TRUE, 'Your team name', 0)
  RETURNING id INTO q1_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'dropdown', 'Number of Team Members', TRUE, 1)
  RETURNING id INTO q2_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q2_id, '1 (Solo)', 0), (q2_id, '2 Members', 1), (q2_id, '3 Members', 2), (q2_id, '4 Members', 3);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec1_id, 'short_answer', 'Team Leader GitHub Profile URL', TRUE, 'https://github.com/yourusername', 2);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'dropdown', 'Preferred Hackathon Theme', TRUE, 3)
  RETURNING id INTO q3_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q3_id, 'Smart Cities and Sustainability', 0),
    (q3_id, 'HealthTech and Wellness', 1),
    (q3_id, 'FinTech and Financial Inclusion', 2),
    (q3_id, 'AI/ML for Social Good', 3),
    (q3_id, 'Open Innovation (Any domain)', 4);

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Technical Background', 'Help our mentors prepare for you.', 1)
  RETURNING id INTO sec2_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec2_id, 'checkbox', 'Tech Stack Your Team Plans to Use', TRUE, 0)
  RETURNING id INTO q4_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q4_id, 'Flutter / Dart', 0), (q4_id, 'React / Next.js', 1),
    (q4_id, 'Python / FastAPI', 2), (q4_id, 'Node.js / Express', 3),
    (q4_id, 'AI/ML (TensorFlow, PyTorch)', 4), (q4_id, 'Blockchain / Web3', 5),
    (q4_id, 'Other', 6);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec2_id, 'radio', 'Team Overall Experience Level', TRUE, 1)
  RETURNING id INTO q5_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q5_id, 'Beginner (First hackathon)', 0),
    (q5_id, 'Intermediate (1-3 hackathons)', 1),
    (q5_id, 'Advanced (4+ hackathons)', 2),
    (q5_id, 'Expert (Won hackathons before)', 3);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, character_limit, order_index)
  VALUES (sec2_id, 'paragraph', 'Briefly describe your project idea (helps with mentor matching)', FALSE,
    'We plan to build a...', 300, 2);

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Logistics and Dietary Preferences', 'We want to keep you fueled!', 2)
  RETURNING id INTO sec3_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec3_id, 'radio', 'Dietary Preference (For Meals)', TRUE, 0)
  RETURNING id INTO q6_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q6_id, 'Vegetarian', 0), (q6_id, 'Non-Vegetarian', 1), (q6_id, 'Vegan', 2), (q6_id, 'Jain', 3);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec3_id, 'radio', 'T-Shirt Size', TRUE, 1)
  RETURNING id INTO q7_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q7_id, 'S', 0), (q7_id, 'M', 1), (q7_id, 'L', 2), (q7_id, 'XL', 3), (q7_id, 'XXL', 4);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec3_id, 'yes_no', 'Do you have any food allergies?', FALSE, 2)
  RETURNING id INTO q8_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec3_id, 'short_answer', 'Emergency Contact Name and Number', TRUE, 'Parent/Guardian: +91-XXXXX-XXXXX', 3);
END $$;

-- =====================================================================
-- EVENT 2: Symphony Annual Cultural Fest 2026 (Cultural)
-- =====================================================================
DO $$
DECLARE
  cat_id UUID; evt_id UUID; frm_id UUID; sec1_id UUID; sec2_id UUID;
  q1_id UUID; q2_id UUID; q3_id UUID; q4_id UUID; q5_id UUID;
BEGIN
  SELECT id INTO cat_id FROM event_categories WHERE name = 'Cultural' LIMIT 1;
  INSERT INTO events (
    title, short_description, long_description,
    venue, eligibility, category_id,
    start_date, end_date,
    prize_details, coordinator, faculty_in_charge, contact_number,
    dress_code, max_seats, visibility, cover_image_url, tags
  ) VALUES (
    'Symphony 2026 — Annual Cultural Fest',
    'Three days of music, dance, art and drama. The biggest cultural extravaganza of the year!',
    'SYMPHONY is back — bigger, louder, and more spectacular than ever!' || chr(10) || chr(10) ||
    'MAIN STAGE EVENTS:' || chr(10) ||
    '  Battle of Bands (Live band competition)' || chr(10) ||
    '  Solo Singing Competition (Bollywood and Western)' || chr(10) ||
    '  Group Dance Championship (8-16 members)' || chr(10) ||
    '  Solo Contemporary Dance' || chr(10) ||
    '  Stand-Up Comedy Night' || chr(10) ||
    '  Fashion Show — Threads of Tradition' || chr(10) || chr(10) ||
    'EXHIBITIONS AND ACTIVITIES:' || chr(10) ||
    '  Art Exhibition and Live Painting' || chr(10) ||
    '  Photography Contest — Frames of Life' || chr(10) ||
    '  Poetry and Spoken Word Slam' || chr(10) ||
    '  Rangoli and Mehendi Competition' || chr(10) ||
    '  Food Festival with 40+ stalls' || chr(10) || chr(10) ||
    'TOTAL PRIZE POOL: Rs.1,50,000' || chr(10) || chr(10) ||
    'Special Guest Performances each evening. DJ Night on the final day.',
    'College Main Grounds and Open Air Theatre',
    'Open to all students and faculty. External participants welcome for audience passes.',
    cat_id,
    NOW() + INTERVAL '25 days',
    NOW() + INTERVAL '27 days',
    'Rs.1,50,000 total prize pool across all events. Individual prizes from Rs.5,000 to Rs.40,000.',
    'Ananya Singh (Cultural Committee Head)',
    'Dr. Rajesh Kumar',
    '+91-98123-45678',
    'Traditional/Ethnic wear encouraged on Day 1. Western/Smart Casual for Day 2 and 3.',
    1500, 'published',
    'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&q=80&fit=crop',
    ARRAY['cultural', 'fest', 'music', 'dance', 'drama', 'food']
  ) RETURNING id INTO evt_id;

  INSERT INTO registration_forms (event_id, confirmation_message, auto_approval, max_responses)
  VALUES (evt_id,
    'You are on the guest list for Symphony 2026! Your festival pass will be emailed 2 days before the event.',
    TRUE, 1500)
  RETURNING id INTO frm_id;

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Festival Pass Details', 'This info will be printed on your festival pass.', 0)
  RETURNING id INTO sec1_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'radio', 'Pass Type', TRUE, 0)
  RETURNING id INTO q1_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q1_id, 'All 3 Days (Full Access)', 0),
    (q1_id, 'Day 1 Only — Opening Ceremony and Competitions', 1),
    (q1_id, 'Day 2 Only — Main Events and Exhibitions', 2),
    (q1_id, 'Day 3 Only — Finals and DJ Night', 3);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'radio', 'T-Shirt Size (Complimentary for Full Pass Holders)', FALSE, 1)
  RETURNING id INTO q2_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q2_id, 'S', 0), (q2_id, 'M', 1), (q2_id, 'L', 2), (q2_id, 'XL', 3), (q2_id, 'XXL', 4);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'radio', 'Dietary Preference (For Complimentary Food Coupons)', TRUE, 2)
  RETURNING id INTO q3_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q3_id, 'Vegetarian', 0), (q3_id, 'Non-Vegetarian', 1), (q3_id, 'Jain', 2);

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Event Participation', 'Are you participating as a performer or just attending?', 1)
  RETURNING id INTO sec2_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec2_id, 'radio', 'Are you participating in any competition?', TRUE, 0)
  RETURNING id INTO q4_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q4_id, 'Yes, as a Performer / Competitor', 0),
    (q4_id, 'No, I am attending as an audience', 1);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec2_id, 'dropdown', 'Which Event Are You Participating In?', FALSE, 1)
  RETURNING id INTO q5_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q5_id, 'Battle of Bands', 0), (q5_id, 'Solo Singing', 1),
    (q5_id, 'Group Dance Championship', 2), (q5_id, 'Solo Contemporary Dance', 3),
    (q5_id, 'Stand-Up Comedy Night', 4), (q5_id, 'Fashion Show', 5),
    (q5_id, 'Photography Contest', 6), (q5_id, 'Poetry and Spoken Word', 7),
    (q5_id, 'Rangoli Competition', 8), (q5_id, 'Mehendi Competition', 9),
    (q5_id, 'Not applicable', 10);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, character_limit, order_index)
  VALUES (sec2_id, 'paragraph', 'Special Requirements or Requests (Stage setup, instruments, etc.)', FALSE,
    'e.g., I need a keyboard setup on stage...', 250, 2);
END $$;

-- =====================================================================
-- EVENT 3: AI Industry Seminar (Seminar)
-- =====================================================================
DO $$
DECLARE
  cat_id UUID; evt_id UUID; frm_id UUID; sec1_id UUID; sec2_id UUID;
  q1_id UUID; q2_id UUID; q3_id UUID;
BEGIN
  SELECT id INTO cat_id FROM event_categories WHERE name = 'Seminar' LIMIT 1;
  INSERT INTO events (
    title, short_description, long_description,
    venue, eligibility, category_id,
    start_date, end_date,
    coordinator, faculty_in_charge, contact_number,
    max_seats, visibility, cover_image_url, tags
  ) VALUES (
    'The Future of Artificial Intelligence — Industry Seminar',
    'Hear from AI leaders at Google DeepMind, Microsoft Research and OpenAI partners.',
    'A landmark seminar bringing together AI researchers, engineers, and product leaders.' || chr(10) || chr(10) ||
    'SCHEDULE (Single Day Event):' || chr(10) ||
    '  09:30 AM — Registration and Networking Breakfast' || chr(10) ||
    '  10:00 AM — Keynote: LLMs Beyond ChatGPT by Dr. Kavya Nair (Google DeepMind)' || chr(10) ||
    '  11:15 AM — Talk: Building Responsible AI at Scale — Arjun Menon (Microsoft Research)' || chr(10) ||
    '  12:30 PM — Panel: AI in Indian Industry — Challenges and Opportunities' || chr(10) ||
    '  01:30 PM — Lunch Break and Networking' || chr(10) ||
    '  02:30 PM — Workshop: Hands-on with Gemini API and Azure OpenAI' || chr(10) ||
    '  04:00 PM — Talk: Career Paths in AI' || chr(10) ||
    '  05:00 PM — Q and A, Certificates and Closing' || chr(10) || chr(10) ||
    'All attendees receive a Certificate of Participation.' || chr(10) ||
    'Limited to 120 seats to ensure quality interaction with speakers.',
    'Seminar Hall A, Academic Block',
    'Open to CS, IT, AI and DS, and Electronics students (2nd year and above). Faculty welcome.',
    cat_id,
    NOW() + INTERVAL '8 days 9 hours 30 minutes',
    NOW() + INTERVAL '8 days 17 hours',
    'Shreya Patel (AI Club)',
    'Dr. Amit Verma, Head of CS Dept',
    '+91-97654-32109',
    120, 'published',
    'https://images.unsplash.com/photo-1677442135703-1787eea5ce01?w=800&q=80&fit=crop',
    ARRAY['AI', 'machine learning', 'seminar', 'industry', 'careers', 'certificate']
  ) RETURNING id INTO evt_id;

  INSERT INTO registration_forms (event_id, confirmation_message, auto_approval, max_responses)
  VALUES (evt_id,
    'Your seat is confirmed for the AI Seminar! Please arrive by 9:15 AM. Bring your college ID. Certificate issued at the end.',
    TRUE, 120)
  RETURNING id INTO frm_id;

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Attendee Details', 'Help our speakers tailor content to the audience.', 0)
  RETURNING id INTO sec1_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'radio', 'Your Current Year of Study', TRUE, 0)
  RETURNING id INTO q1_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q1_id, '2nd Year (Sophomore)', 0), (q1_id, '3rd Year (Junior)', 1),
    (q1_id, '4th Year (Senior)', 2), (q1_id, 'Postgraduate (M.E./M.Tech/MCA)', 3),
    (q1_id, 'Faculty', 4);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'radio', 'Your AI/ML Experience Level', TRUE, 1)
  RETURNING id INTO q2_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q2_id, 'Beginner — just started exploring AI', 0),
    (q2_id, 'Intermediate — built some projects', 1),
    (q2_id, 'Advanced — working on research or production AI', 2);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'checkbox', 'Which sessions interest you the most? (Select all)', TRUE, 2)
  RETURNING id INTO q3_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q3_id, 'LLMs and Generative AI', 0), (q3_id, 'Responsible AI and Ethics', 1),
    (q3_id, 'AI Career Paths', 2), (q3_id, 'Hands-on API Workshop', 3),
    (q3_id, 'AI in Indian Industry', 4);

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Questions for Speakers', 'Submit your questions in advance — top questions get featured in the Q and A.', 1)
  RETURNING id INTO sec2_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, character_limit, order_index)
  VALUES (sec2_id, 'paragraph', 'What is your burning question for our AI speakers?', FALSE,
    'e.g., How do hallucinations in LLMs affect safety-critical applications?', 300, 0);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec2_id, 'short_answer', 'Your LinkedIn Profile URL (Optional — for networking)', FALSE,
    'https://linkedin.com/in/yourname', 1);
END $$;

-- =====================================================================
-- EVENT 4: UI/UX Design Bootcamp (Workshop)
-- =====================================================================
DO $$
DECLARE
  cat_id UUID; evt_id UUID; frm_id UUID; sec1_id UUID; sec2_id UUID;
  q1_id UUID; q2_id UUID; q3_id UUID; q4_id UUID; q5_id UUID;
BEGIN
  SELECT id INTO cat_id FROM event_categories WHERE name = 'Workshop' LIMIT 1;
  INSERT INTO events (
    title, short_description, long_description,
    venue, eligibility, category_id,
    start_date, end_date,
    coordinator, faculty_in_charge, contact_number,
    requirements, max_seats, visibility, cover_image_url, tags
  ) VALUES (
    'UI/UX Design Bootcamp — From Wireframes to Figma',
    '2-day hands-on workshop. Learn Figma, Design Thinking and build a portfolio project.',
    'A practical, hands-on workshop designed for anyone who wants to break into UI/UX design.' || chr(10) || chr(10) ||
    'DAY 1 — Design Thinking and Wireframing:' || chr(10) ||
    '  10:00 AM — What is UX? Understanding user psychology' || chr(10) ||
    '  11:00 AM — Design Thinking: Empathize, Define, Ideate, Prototype, Test' || chr(10) ||
    '  12:30 PM — Lunch' || chr(10) ||
    '  01:30 PM — Wireframing techniques (pen and paper to digital)' || chr(10) ||
    '  03:00 PM — Team challenge: Redesign a bad UI' || chr(10) ||
    '  04:30 PM — Wrap-up and day 1 assignments' || chr(10) || chr(10) ||
    'DAY 2 — Figma Mastery and Portfolio:' || chr(10) ||
    '  10:00 AM — Figma fundamentals: Components, Auto-layout, Variants' || chr(10) ||
    '  12:00 PM — Lunch' || chr(10) ||
    '  01:00 PM — Building a real app mockup (Zomato clone challenge)' || chr(10) ||
    '  03:30 PM — Prototyping and user testing basics' || chr(10) ||
    '  04:30 PM — Portfolio tips and how to get a UX internship' || chr(10) ||
    '  05:00 PM — Certificate distribution' || chr(10) || chr(10) ||
    'All participants receive: Certificate of Completion + Figma Pro license (3 months free) + Resource pack.',
    'Computer Lab 3, Engineering Block (Air-conditioned)',
    'Open to all students. No prior design experience required. Laptop mandatory.',
    cat_id,
    NOW() + INTERVAL '12 days 10 hours',
    NOW() + INTERVAL '13 days 17 hours',
    'Meera Joshi (Design Club)',
    'Prof. Sunil Rao',
    '+91-96321-54870',
    'Personal laptop (mandatory)' || chr(10) ||
    'Figma account (free — create at figma.com before the workshop)' || chr(10) ||
    'Chrome or Firefox browser' || chr(10) ||
    'Mouse recommended',
    60, 'published',
    'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800&q=80&fit=crop',
    ARRAY['design', 'figma', 'UX', 'UI', 'workshop', 'certificate', 'portfolio']
  ) RETURNING id INTO evt_id;

  INSERT INTO registration_forms (event_id, confirmation_message, auto_approval, max_responses)
  VALUES (evt_id,
    'You are in for the UI/UX Bootcamp! Create your Figma account at figma.com before Day 1. Bring your laptop charged.',
    TRUE, 60)
  RETURNING id INTO frm_id;

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Background and Experience', 'Help us tailor the content to your level.', 0)
  RETURNING id INTO sec1_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'radio', 'Your Current Field/Department', TRUE, 0)
  RETURNING id INTO q1_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q1_id, 'Computer Science / IT', 0), (q1_id, 'Electronics / ECE', 1),
    (q1_id, 'Mechanical / Civil', 2), (q1_id, 'Commerce / Arts', 3), (q1_id, 'Other', 4);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'radio', 'Prior Design Experience', TRUE, 1)
  RETURNING id INTO q2_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q2_id, 'None — complete beginner', 0),
    (q2_id, 'A little — made posters or social media graphics', 1),
    (q2_id, 'Some — used Canva or basic Figma', 2),
    (q2_id, 'Experienced — have portfolio projects', 3);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'checkbox', 'What do you hope to achieve? (Select all that apply)', TRUE, 2)
  RETURNING id INTO q3_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q3_id, 'Learn Figma from scratch', 0),
    (q3_id, 'Build a UI portfolio for internships', 1),
    (q3_id, 'Understand UX research methods', 2),
    (q3_id, 'Transition to a design career', 3),
    (q3_id, 'Improve my app/web projects visually', 4);

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Laptop and Setup', 'Ensure you come prepared.', 1)
  RETURNING id INTO sec2_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec2_id, 'radio', 'Do you have a personal laptop?', TRUE, 0)
  RETURNING id INTO q4_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q4_id, 'Yes, I will bring my own laptop', 0),
    (q4_id, 'No — I need a lab computer (limited availability)', 1);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec2_id, 'yes_no', 'Have you already created a Figma account?', FALSE, 1);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec2_id, 'radio', 'Dietary Preference (For Lunch on Both Days)', TRUE, 2)
  RETURNING id INTO q5_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q5_id, 'Vegetarian', 0), (q5_id, 'Non-Vegetarian', 1), (q5_id, 'Jain', 2), (q5_id, 'Vegan', 3);
END $$;

-- =====================================================================
-- EVENT 5: CupShot Football Tournament (Sports)
-- =====================================================================
DO $$
DECLARE
  cat_id UUID; evt_id UUID; frm_id UUID; sec1_id UUID; sec2_id UUID;
  q1_id UUID; q2_id UUID; q3_id UUID;
BEGIN
  SELECT id INTO cat_id FROM event_categories WHERE name = 'Sports' LIMIT 1;
  INSERT INTO events (
    title, short_description, long_description,
    venue, eligibility, category_id,
    start_date, end_date,
    prize_details, coordinator, faculty_in_charge, contact_number,
    rules, max_seats, visibility, cover_image_url, tags
  ) VALUES (
    'CupShot 2026 — Inter-College Football Tournament',
    '16 teams. 3 days. 1 champion. The biggest college football tournament of the year!',
    'CUPSHOT 2026 is back with a bang!' || chr(10) || chr(10) ||
    'PRIZE DISTRIBUTION:' || chr(10) ||
    '  Champion: Rs.40,000 + Trophy + Gold Medals' || chr(10) ||
    '  Runner-Up: Rs.20,000 + Trophy + Silver Medals' || chr(10) ||
    '  3rd Place: Rs.10,000 + Bronze Medals' || chr(10) ||
    '  Best Goalkeeper: Rs.3,000' || chr(10) ||
    '  Golden Boot (Best Striker): Rs.3,000' || chr(10) ||
    '  Fair Play Award: Rs.2,000' || chr(10) || chr(10) ||
    'FORMAT:' || chr(10) ||
    '  Day 1: Group Stage — 8 matches' || chr(10) ||
    '  Day 2: Quarterfinals — 4 matches' || chr(10) ||
    '  Day 3: Semifinal, 3rd Place Playoff and FINAL' || chr(10) || chr(10) ||
    'Each team: 11 players + 4 substitutes (max 15 per squad)' || chr(10) ||
    'Complimentary sports kit (jersey + shorts) for all registered players.' || chr(10) ||
    'Refreshments provided on match days.' || chr(10) ||
    'Entry free for students with ID.',
    'College Synthetic Turf Ground, Block E',
    'Any enrolled college student. Must bring college ID. One team per college. Age limit: 18-26.',
    cat_id,
    NOW() + INTERVAL '30 days',
    NOW() + INTERVAL '32 days',
    'Champion: Rs.40,000 | Runner-Up: Rs.20,000 | 3rd Place: Rs.10,000 | Individual awards: Rs.8,000',
    'Vikas Yadav (Sports Committee)',
    'Coach Ramesh Patil',
    '+91-99123-87654',
    'Each team must have exactly 11 starting players and up to 4 substitutes.' || chr(10) ||
    'Players must wear the provided kit.' || chr(10) ||
    'Studs/cleats are mandatory. Bare feet or flat shoes NOT allowed.' || chr(10) ||
    'Match duration: 2 x 40 minutes with a 10-minute break.' || chr(10) ||
    'Yellow/Red card rules follow standard FIFA regulations.' || chr(10) ||
    'All players must submit a signed medical fitness form before the tournament.',
    150, 'published',
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80&fit=crop',
    ARRAY['football', 'sports', 'tournament', 'inter-college', 'prizes']
  ) RETURNING id INTO evt_id;

  INSERT INTO registration_forms (event_id, confirmation_message, auto_approval, max_responses)
  VALUES (evt_id,
    'Your team is registered for CupShot 2026! The draw ceremony and schedule will be shared 5 days before the tournament.',
    FALSE, 150)
  RETURNING id INTO frm_id;

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Team Registration', 'Register your full team details. Only the Team Captain should fill this form.', 0)
  RETURNING id INTO sec1_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec1_id, 'short_answer', 'Team / College Name', TRUE, 'e.g., VIT Vellore FC', 0);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec1_id, 'short_answer', 'Team Captain Full Name', TRUE, 'Full name as on ID card', 1);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec1_id, 'paragraph', 'List All Player Names and Jersey Numbers (one per line)', TRUE,
    '1. Rahul Sharma — #10', 2);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec1_id, 'short_answer', 'Team Captain Phone Number', TRUE, '+91-XXXXX-XXXXX', 3);

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Kit and Logistics', '', 1)
  RETURNING id INTO sec2_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec2_id, 'short_answer', 'Preferred Jersey Color (1st choice)', TRUE, 'e.g., Blue', 0);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec2_id, 'short_answer', 'Preferred Jersey Color (2nd choice)', TRUE, 'e.g., Red', 1);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec2_id, 'yes_no', 'Has your team participated in CupShot in previous years?', FALSE, 2);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec2_id, 'radio', 'Dietary Preference for Team (for match-day snacks)', TRUE, 3)
  RETURNING id INTO q3_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q3_id, 'Vegetarian', 0), (q3_id, 'Non-Vegetarian', 1), (q3_id, 'Mixed (both options please)', 2);
END $$;

-- =====================================================================
-- EVENT 6: SIH Internal Qualifier (Competition)
-- =====================================================================
DO $$
DECLARE
  cat_id UUID; evt_id UUID; frm_id UUID; sec1_id UUID; sec2_id UUID; sec3_id UUID;
  q1_id UUID; q2_id UUID; q3_id UUID;
BEGIN
  SELECT id INTO cat_id FROM event_categories WHERE name = 'Competition' LIMIT 1;
  INSERT INTO events (
    title, short_description, long_description,
    venue, eligibility, category_id,
    start_date, end_date,
    coordinator, faculty_in_charge, contact_number,
    rules, max_seats, visibility, cover_image_url, tags
  ) VALUES (
    'SIH 2026 — Internal College Qualifier Round',
    'Select your team for the national Smart India Hackathon. Top 3 teams represent our college.',
    'The Smart India Hackathon (SIH) is India biggest national hackathon with 1 Lakh+ participants.' || chr(10) || chr(10) ||
    'ABOUT SIH:' || chr(10) ||
    '  Government of India initiative to solve real problems' || chr(10) ||
    '  Problem statements from Central and State Ministries, PSUs, and private organizations' || chr(10) ||
    '  National prize pool: Rs.1,00,000 per winning team' || chr(10) ||
    '  Winning teams get certificates signed by the Ministry of Education' || chr(10) || chr(10) ||
    'INTERNAL QUALIFIER FORMAT:' || chr(10) ||
    '  Duration: 6 hours (10 AM to 4 PM)' || chr(10) ||
    '  Teams present a PPT and prototype/demo' || chr(10) ||
    '  Judges: Faculty panel + Industry mentor' || chr(10) ||
    '  Top 3 teams advance to the national round' || chr(10) || chr(10) ||
    'PROBLEM STATEMENT DOMAINS:' || chr(10) ||
    '  Education | Agriculture | Smart Cities | Cybersecurity | Healthcare | Disaster Management | Transport' || chr(10) || chr(10) ||
    'Selected teams will get dedicated mentoring sessions before the national round.' || chr(10) ||
    'All participants receive a participation certificate.',
    'Seminar Hall B and C, Academic Block',
    'All students (1st year to Final year). Teams of exactly 6 members from the SAME college.',
    cat_id,
    NOW() + INTERVAL '14 days 10 hours',
    NOW() + INTERVAL '14 days 16 hours',
    'Dr. Neha Gupta (Innovation Cell)',
    'Dr. Rakesh Singh (Innovation Cell Head)',
    '+91-98001-23456',
    'Strict team size: exactly 6 members.' || chr(10) ||
    'All members must be enrolled students of this college.' || chr(10) ||
    'Each student can be part of only ONE team.' || chr(10) ||
    'Presentation: 10-minute PPT + 5-minute Q and A per team.' || chr(10) ||
    'A working prototype is strongly recommended.' || chr(10) ||
    'No plagiarism — all work must be original.',
    80, 'published',
    'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800&q=80&fit=crop',
    ARRAY['SIH', 'hackathon', 'government', 'national', 'competition', 'teams']
  ) RETURNING id INTO evt_id;

  INSERT INTO registration_forms (event_id, confirmation_message, auto_approval, max_responses)
  VALUES (evt_id,
    'Your team is registered for the SIH 2026 Internal Qualifier! You will receive the schedule 3 days before the event.',
    FALSE, 80)
  RETURNING id INTO frm_id;

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Team and Leader Details', 'One person registers on behalf of the entire team of 6.', 0)
  RETURNING id INTO sec1_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec1_id, 'short_answer', 'Team Name', TRUE, 'e.g., Team Innovate6', 0);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec1_id, 'short_answer', 'Team Leader Full Name', TRUE, 'As on college ID card', 1);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec1_id, 'email', 'Team Leader Email (Official)', TRUE, 'leader@college.edu', 2);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec1_id, 'short_answer', 'Team Leader Phone Number', TRUE, '+91-XXXXX-XXXXX', 3);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec1_id, 'dropdown', 'Chosen Problem Statement Domain', TRUE, 4)
  RETURNING id INTO q1_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q1_id, 'Education and Skill Development', 0),
    (q1_id, 'Agriculture and Rural Development', 1),
    (q1_id, 'Smart Cities and Urban Infrastructure', 2),
    (q1_id, 'Cybersecurity and Digital Governance', 3),
    (q1_id, 'Healthcare and Biomedical Devices', 4),
    (q1_id, 'Disaster Management and Resilience', 5),
    (q1_id, 'Smart Vehicles and Transport', 6);

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'All 6 Team Members', 'Provide details for each member. This will be used for certificates.', 1)
  RETURNING id INTO sec2_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, order_index)
  VALUES (sec2_id, 'paragraph',
    'List all 6 team members (Name, Department, Year, Roll No.) — one per line', TRUE,
    '1. Ravi Kumar, CSE, 3rd Year, Roll: CSE301', 0);

  INSERT INTO form_sections (form_id, title, description, order_index)
  VALUES (frm_id, 'Project and Prototype', 'Tell us about what you plan to build.', 2)
  RETURNING id INTO sec3_id;

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, character_limit, order_index)
  VALUES (sec3_id, 'paragraph', 'Problem Statement Title', TRUE,
    'One-line title for your solution', 150, 0);

  INSERT INTO form_questions (section_id, question_type, title, is_required, placeholder, character_limit, order_index)
  VALUES (sec3_id, 'paragraph', 'Brief Description of Your Solution', TRUE,
    'Describe the problem you are solving and your approach...', 500, 1);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec3_id, 'radio', 'Type of Prototype/Demo You Plan to Present', TRUE, 2)
  RETURNING id INTO q2_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q2_id, 'Working Web Application (Live Demo)', 0),
    (q2_id, 'Working Mobile App (APK)', 1),
    (q2_id, 'Hardware Prototype with Software', 2),
    (q2_id, 'Figma/UI Mockup with Explanation', 3),
    (q2_id, 'Presentation Only (No prototype yet)', 4);

  INSERT INTO form_questions (section_id, question_type, title, is_required, order_index)
  VALUES (sec3_id, 'checkbox', 'Technologies You Plan to Use', TRUE, 3)
  RETURNING id INTO q3_id;
  INSERT INTO question_options (question_id, value, order_index) VALUES
    (q3_id, 'Artificial Intelligence / ML', 0), (q3_id, 'IoT / Embedded Systems', 1),
    (q3_id, 'Blockchain / Web3', 2), (q3_id, 'Cloud Computing (AWS/Azure/GCP)', 3),
    (q3_id, 'Mobile Development (Flutter/React Native)', 4),
    (q3_id, 'Web Development (React/Node/Django)', 5),
    (q3_id, 'Data Analytics / Visualization', 6), (q3_id, 'AR/VR', 7);
END $$;
