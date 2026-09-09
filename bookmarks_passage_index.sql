-- Passage bookmarks for Thaqalayn (ships with the build after v8.6 (113))
--
-- Adds an optional passage index to the existing bookmarks table. A row with
-- passage_index set bookmarks a whole passage (one ruku). verse_number then holds
-- the passage's first verse, verse_text that verse's Arabic and verse_translation
-- the passage title, so older app versions read the row as a plain verse bookmark.
-- A verse bookmark and a passage bookmark may share (surah_number, verse_number).
--
-- Run in the Supabase SQL editor BEFORE the build that writes this column reaches
-- TestFlight: PostgREST rejects an upsert naming an unknown column (PGRST204),
-- which aborts the whole bookmark sync for any user with a pending passage bookmark.

-- 1. Inspect first. Verse and passage bookmarks may share (surah_number, verse_number),
--    so a UNIQUE constraint or unique index on those columns must be dropped before step 2.
SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'public.bookmarks'::regclass;

SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'bookmarks';

-- If either lists a UNIQUE over (user_id, surah_number, verse_number):
-- ALTER TABLE public.bookmarks DROP CONSTRAINT <name>;   -- or: DROP INDEX <name>;

-- 2. The column. NULL means a verse bookmark; passage indices are 1-based.
ALTER TABLE public.bookmarks ADD COLUMN IF NOT EXISTS passage_index INTEGER NULL;

ALTER TABLE public.bookmarks DROP CONSTRAINT IF EXISTS bookmarks_passage_index_positive;
ALTER TABLE public.bookmarks ADD CONSTRAINT bookmarks_passage_index_positive
    CHECK (passage_index IS NULL OR passage_index >= 1);

COMMENT ON COLUMN public.bookmarks.passage_index IS
    '1-based ruku index when the bookmark saves a whole passage; NULL for a single verse';

-- No new index: reads are by user_id over at most 10 rows per user. No unique index
-- on (user_id, surah_number, passage_index) either: the app dedupes on the client,
-- and a server-side unique would turn a two-device race into a permanent 409 that
-- makes every later sync of that user fail (the upload is one batched upsert).

-- 3. Make PostgREST pick up the new column without waiting for its schema cache.
NOTIFY pgrst, 'reload schema';
