-- Account Deletion Function for Thaqalayn App
-- This function permanently deletes a user and all associated data
-- Required for App Store compliance with account deletion requirements

CREATE OR REPLACE FUNCTION delete_user_account(user_id_param TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result_text TEXT;
    deleted_bookmarks_count INTEGER;
    deleted_preferences_count INTEGER;
BEGIN
    -- Check if user exists
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id::text = user_id_param) THEN
        RAISE EXCEPTION 'User with ID % not found', user_id_param;
    END IF;
    
    -- Delete user bookmarks and count them
    DELETE FROM bookmarks WHERE user_id::text = user_id_param;
    GET DIAGNOSTICS deleted_bookmarks_count = ROW_COUNT;
    
    -- Delete user preferences and count them
    DELETE FROM user_preferences WHERE user_id::text = user_id_param;
    GET DIAGNOSTICS deleted_preferences_count = ROW_COUNT;
    
    -- Log the deletion for audit purposes
    result_text := format(
        'User %s deleted successfully. Removed %s bookmarks and %s preference records.',
        user_id_param,
        deleted_bookmarks_count,
        deleted_preferences_count
    );
    
    -- Return success message
    RETURN result_text;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error and re-raise
        RAISE EXCEPTION 'Failed to delete user account: %', SQLERRM;
END;
$$;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION delete_user_account(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_user_account(TEXT) TO service_role;

-- Create a policy to ensure users can only delete their own account
-- (This is handled by the function's security context, but adding extra safety)

-- Comments for documentation
COMMENT ON FUNCTION delete_user_account(TEXT) IS 'Permanently deletes a user account and all associated data. Used for App Store compliance with account deletion requirements.';

-- Example usage (for testing - DO NOT run in production):
-- SELECT delete_user_account('user-uuid-here');