-- Create the event-posters bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('event-posters', 'event-posters', true)
ON CONFLICT (id) DO NOTHING;

-- Publicly readable
CREATE POLICY "Public Access" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'event-posters');

-- Only admins can insert/update/delete event posters
CREATE POLICY "Admin Upload" 
ON storage.objects FOR INSERT 
WITH CHECK (
    bucket_id = 'event-posters' 
    AND EXISTS (SELECT 1 FROM admin_profiles WHERE id = auth.uid())
);

CREATE POLICY "Admin Update" 
ON storage.objects FOR UPDATE 
WITH CHECK (
    bucket_id = 'event-posters' 
    AND EXISTS (SELECT 1 FROM admin_profiles WHERE id = auth.uid())
);

CREATE POLICY "Admin Delete" 
ON storage.objects FOR DELETE 
USING (
    bucket_id = 'event-posters' 
    AND EXISTS (SELECT 1 FROM admin_profiles WHERE id = auth.uid())
);
