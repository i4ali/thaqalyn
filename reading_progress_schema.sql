-- Reading Progress Schema for Thaqalayn App
-- This table stores user reading progress, streaks, badges, and statistics
-- with cloud sync support via Supabase

-- Create the reading_progress table
CREATE TABLE IF NOT EXISTS reading_progress (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    verse_progress JSONB NOT NULL DEFAULT '[]'::jsonb,
    reading_streak JSONB NOT NULL DEFAULT '{}'::jsonb,
    badges JSONB NOT NULL DEFAULT '[]'::jsonb,
    stats JSONB NOT NULL DEFAULT '{}'::jsonb,
    preferences JSONB NOT NULL DEFAULT '{}'::jsonb,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_reading_progress_user_id ON reading_progress(user_id);

-- Create index on updated_at for sync operations
CREATE INDEX IF NOT EXISTS idx_reading_progress_updated_at ON reading_progress(updated_at);

-- Enable Row Level Security (RLS)
ALTER TABLE reading_progress ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only view their own progress
CREATE POLICY "Users can view their own progress"
    ON reading_progress
    FOR SELECT
    USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own progress
CREATE POLICY "Users can insert their own progress"
    ON reading_progress
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own progress
CREATE POLICY "Users can update their own progress"
    ON reading_progress
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own progress
CREATE POLICY "Users can delete their own progress"
    ON reading_progress
    FOR DELETE
    USING (auth.uid() = user_id);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_reading_progress_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at on row updates
DROP TRIGGER IF EXISTS set_reading_progress_updated_at ON reading_progress;
CREATE TRIGGER set_reading_progress_updated_at
    BEFORE UPDATE ON reading_progress
    FOR EACH ROW
    EXECUTE FUNCTION update_reading_progress_updated_at();

-- Add comments for documentation
COMMENT ON TABLE reading_progress IS 'Stores user reading progress including verse completion, streaks, badges, and statistics';
COMMENT ON COLUMN reading_progress.user_id IS 'Foreign key to auth.users - identifies the user';
COMMENT ON COLUMN reading_progress.verse_progress IS 'Array of VerseProgress objects (read verses with timestamps)';
COMMENT ON COLUMN reading_progress.reading_streak IS 'ReadingStreak object (current streak, longest streak, dates)';
COMMENT ON COLUMN reading_progress.badges IS 'Array of BadgeAward objects (earned achievements)';
COMMENT ON COLUMN reading_progress.stats IS 'ProgressStats object (totals, sawab, etc.)';
COMMENT ON COLUMN reading_progress.preferences IS 'ProgressPreferences object (notification settings)';
COMMENT ON COLUMN reading_progress.updated_at IS 'Last update timestamp for conflict resolution';
COMMENT ON COLUMN reading_progress.created_at IS 'Record creation timestamp';

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON reading_progress TO authenticated;
GRANT ALL ON reading_progress TO service_role;

-- Example usage (for testing - DO NOT run in production):
-- INSERT INTO reading_progress (user_id, verse_progress, reading_streak, badges, stats, preferences)
-- VALUES (
--     'user-uuid-here',
--     '[]'::jsonb,
--     '{"currentStreak": 0, "longestStreak": 0}'::jsonb,
--     '[]'::jsonb,
--     '{"totalVersesRead": 0, "totalSurahsCompleted": 0}'::jsonb,
--     '{"notificationsEnabled": false}'::jsonb
-- );
