import { onAuthChange, supaAuth } from './auth.js'
import { getUnreadCount, subscribeToNotifications } from './notifications.js'
import { supaDB } from './db.js'

export function headerPartial(user) {
  const nav = document.querySelector('#nav')
  if (!nav) return

  const isAdmin = user?.email === 'your-email@example.com'

  nav.innerHTML = `
    <a href="/" class="logo-link">
      <img src="/logo1.png" alt="Arduino Store" class="logo">
    </a>
    <div class="nav-links">
      <a href="/"><img src="/home.png" alt="Home" class="nav-icon"></a>
      <a href="/products.html"><img src="/product.png" alt="Products" class="nav-icon"></a>
      ${isAdmin ? '<a href="/admin.html">Add</a><a href="/admin-manage.html">Manage</a>' : ''}
      ${user ? `
        <div class="notification-bell" onclick="toggleNotifications()" title="Notifications">
          <div class="bell-icon-placeholder"></div>
          <span class="notification-badge" id="notif-badge" style="display:none;">0</span>
        </div>
        <span class="user-name">Hi ${user.email.split('@')[0]}</span>
        <button id="logout" class="btn-small">Logout</button>
      ` : `<a href="/login.html"><img src="/user.png" alt="Login" class="nav-icon"></a>`}
      <a href="/cart.html">
        <div class="cart-icon-wrap">
          <img src="/shopping-cart.png" alt="Cart" class="nav-icon">
          <span class="cart-badge" id="cart-badge" style="display:none;">0</span>
        </div>
      </a>
      ${user ? '<a href="/wishlist.html"><img src="/heart.png" alt="Wishlist" class="nav-icon"></a>' : ''}
    </div>
  `

  if (user) {
    setupNotifications(user.id)
    setupCartBadge(user.id)
  }

  document.getElementById('logout')?.addEventListener('click', async () => {
    await supaAuth.auth.signOut()
    location.reload()
  })
}

// ── Notifications ──────────────────────────────────────────────
async function setupNotifications(userId) {
  const { count } = await getUnreadCount(userId)
  updateNotifBadge(count)

  subscribeToNotifications(userId, () => {
    const badge = document.getElementById('notif-badge')
    const current = parseInt(badge?.textContent || '0')
    updateNotifBadge(current + 1)
  })
}

function updateNotifBadge(count) {
  const badge = document.getElementById('notif-badge')
  if (!badge) return
  badge.textContent = count > 99 ? '99+' : count
  badge.style.display = count > 0 ? 'flex' : 'none'
}

// ── Cart Badge ─────────────────────────────────────────────────
async function setupCartBadge(userId) {
  const { data } = await supaDB
    .from('cart_items')
    .select('qty')
    .eq('user_id', userId)

  const total = data?.reduce((sum, item) => sum + (item.qty || 0), 0) || 0
  updateCartBadge(total)
}

export function updateCartBadge(count) {
  const badge = document.getElementById('cart-badge')
  if (!badge) return
  badge.textContent = count > 99 ? '99+' : count
  badge.style.display = count > 0 ? 'flex' : 'none'
}

// ── Notification Panel ─────────────────────────────────────────
window.toggleNotifications = () => {
  const panel = document.getElementById('notification-panel')
  if (panel) {
    panel.remove()
  } else {
    showNotificationPanel()
  }
}

async function showNotificationPanel() {
  const { data: { session } } = await supaAuth.auth.getSession()
  if (!session) return

  const { data: notifications } = await supaDB
    .from('notifications')
    .select('*')
    .eq('user_id', session.user.id)
    .order('created_at', { ascending: false })
    .limit(20)

  const panel = document.createElement('div')
  panel.id = 'notification-panel'
  panel.className = 'notification-panel'

  panel.innerHTML = `
    <div class="notification-header">
      <h3>Notifications</h3>
      <button onclick="markAllRead()" class="btn-text">Mark all read</button>
    </div>
    <div class="notification-list">
      ${notifications?.length
        ? notifications.map(n => renderNotification(n)).join('')
        : '<p class="no-notifs">🔔 No notifications yet</p>'
      }
    </div>
  `

  document.body.appendChild(panel)

  setTimeout(() => {
    document.addEventListener('click', function close(e) {
      if (!panel.contains(e.target) && !e.target.closest('.notification-bell')) {
        panel.remove()
        document.removeEventListener('click', close)
      }
    })
  }, 100)
}

function renderNotification(n) {
  const icons = {
    welcome: '🎉',
    promo: '🏷️',
    wishlist_sale: '💰',
    cart_stock: '📦',
    system: '📢'
  }
  const preview = n.message?.substring(0, 60) + (n.message?.length > 60 ? '...' : '')

  return `
    <div class="notification-item ${n.is_read ? 'read' : 'unread'}" data-id="${n.id}" onclick="expandNotif('${n.id}')">
      <div class="notification-icon">${icons[n.type] || '🔔'}</div>
      <div class="notification-content">
        <div class="notification-title">${n.title || 'Notification'}</div>
        <div class="notification-preview" id="prev-${n.id}">${preview}</div>
        <div class="notification-meta">
          <span>${timeAgo(n.created_at)}</span>
        </div>
      </div>
      <button onclick="deleteNotif('${n.id}', event)" class="notif-delete" title="Delete">×</button>
    </div>
  `
}

function timeAgo(date) {
  const seconds = Math.floor((new Date() - new Date(date)) / 1000)
  if (seconds < 60) return 'just now'
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) return `${minutes}m ago`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  return `${Math.floor(hours / 24)}d ago`
}

window.expandNotif = async (id) => {
  const item = document.querySelector(`[data-id="${id}"]`)
  if (!item) return

  await supaDB.from('notifications').update({ is_read: true }).eq('id', id)
  item.classList.remove('unread')
  item.classList.add('read')

  // Refresh badge
  const { data: { session } } = await supaAuth.auth.getSession()
  if (session) {
    const { count } = await getUnreadCount(session.user.id)
    updateNotifBadge(count)
  }
}

window.markAllRead = async () => {
  const { data: { session } } = await supaAuth.auth.getSession()
  if (!session) return

  await supaDB.from('notifications').update({ is_read: true })
    .eq('user_id', session.user.id).eq('is_read', false)

  updateNotifBadge(0)
  document.querySelectorAll('.notification-item.unread').forEach(el => {
    el.classList.remove('unread')
    el.classList.add('read')
  })
}

window.deleteNotif = async (id, event) => {
  event.stopPropagation()
  await supaDB.from('notifications').delete().eq('id', id)
  document.querySelector(`[data-id="${id}"]`)?.remove()

  // Show empty state if no items left
  const list = document.querySelector('.notification-list')
  if (list && !list.querySelector('.notification-item')) {
    list.innerHTML = '<p class="no-notifs">🔔 No notifications yet</p>'
  }
}