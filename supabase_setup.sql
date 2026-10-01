-- Run this SQL in your Supabase SQL Editor (https://supabase.com/dashboard/project/xxhqgultqcnnwxjwytgk/sql)

-- 1. Create the locations table
CREATE TABLE IF NOT EXISTS public.locations (
    device_id TEXT PRIMARY KEY,
    name TEXT,
    device_ip TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    accuracy_meters DOUBLE PRECISION,
    altitude DOUBLE PRECISION,
    gps_timestamp TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;

-- 3. Create policy to allow anonymous/public users to insert or update their device location
CREATE POLICY "Allow public read and upsert"
ON public.locations
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);
