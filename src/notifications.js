import { supaDB } from './db.js'

// Get user's notifications
export async function getNotifications(userId, limit = 20) {
  return await supaDB
    .from('notifications')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(limit)
}

// Get unread count
export async function getUnreadCount(userId) {
  const { count, error } = await supaDB
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('is_read', false)
  
  return { count: count || 0, error }
}

// Mark as read
export async function markAsRead(notificationId) {
  return await supaDB
    .from('notifications')
    .update({ is_read: true })
    .eq('id', notificationId)
}

// Mark all as read
export async function markAllAsRead(userId) {
  return await supaDB
    .from('notifications')
    .update({ is_read: true })
    .eq('user_id', userId)
    .eq('is_read', false)
}

// Toggle expanded
export async function toggleExpanded(notificationId, expanded) {
  return await supaDB
    .from('notifications')
    .update({ is_expanded: expanded })
    .eq('id', notificationId)
}

// Delete notification
export async function deleteNotification(notificationId) {
  return await supaDB
    .from('notifications')
    .delete()
    .eq('id', notificationId)
}

// Create notification (for admin/system use)
export async function createNotification(userId, type, title, message, data = {}) {
  return await supaDB
    .from('notifications')
    .insert({
      user_id: userId,
      type: type,
      title: title,
      message: message,
      data: data
    })
}

// Real-time subscription
export function subscribeToNotifications(userId, callback) {
  return supaDB
    .channel('notifications')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'notifications',
        filter: `user_id=eq.${userId}`
      },
      (payload) => callback(payload.new)
    )
    .subscribe()
}